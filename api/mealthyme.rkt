#lang racket

(require db
         (planet dmac/spin)
         web-server/servlet
         web-server/http
         web-server/http/request-structs
         json
         racket/match)
(require (prefix-in jwt: net/jwt))
(require (prefix-in bcrypt: bcrypt))

;; Config

(define db-conn
  (virtual-connection
   (connection-pool
    (lambda ()
      (mysql-connect #:server "localhost"
                     #:port 3306
                     #:database "mealthyme"
                     #:user "mealthyme")))))

(define jwt-secret "ThisIsTheBestSecretEver")

;; Helpers

(define (get-jwt userid)
  (jwt:encode/sign "HS256" jwt-secret
                   #:exp (+ (current-seconds) 172800)
                   #:iat (current-seconds)
                   #:sub (number->string userid)))

(define cors-header (header #"Access-Control-Allow-Origin" #"*"))
(define json-header (header #"Content-Type" #"application/json; charset=utf-8"))

(define (ok json-body)
  (list 200
        (list cors-header json-header)
        (jsexpr->string json-body)))

(define (bad-request er)
  (list 400
        (list cors-header json-header)
        (jsexpr->string (hash 'error er))))

(define (server-error msg)
  (list 500
        (list cors-header json-header)
        (jsexpr->string (hash 'error msg))))

(define unauthed
  (list 401
        (list cors-header)
        ""))

(define (cors-handler path)
  (define-handler "OPTIONS" path
    (lambda (req)
      (list 200
            (list
             cors-header
             (header #"Access-Control-Allow-Methods" #"POST, GET")
             (header #"Access-Control-Allow-Headers" #"X-JWT, Content-Type")
             (header #"Access-Control-Allow-Credentials" #"true"))
            ""))))

(define (cors method path handler)
  (method path handler)
  (cors-handler path))

(define (json-body req)
  (match (request-post-data/raw req)
    [#f ""]
    [body (bytes->jsexpr body)]))

(define (get-token req)
  (string-trim (cdr (assoc (string->symbol "x-jwt") (request-headers req)))
               "Bearer: "))

(define (empty-string? s)
  (zero? (string-length s)))

(define (token-user-id token)
  (let ([verified (jwt:decode/verify token "HS256" jwt-secret)])
    (if verified
        (jwt:subject verified)
        verified)))

;;;;;; Entities

;;; User

; queries

(define (get-user username)
  (query-maybe-row db-conn
                   "select user_id, username, password_hash from users where username = ?"
                   username))

(define (register username password)
  (with-handlers ([exn:fail:sql? identity])
    (query-value db-conn
                 "select register(?, ?)"
                 username
                 (bcrypt:encode (string->bytes/utf-8 password)))))

; routes

(cors post "/users"
      (lambda (req)
        (let* ([user (hash-ref (json-body req) 'user)]
               [username (hash-ref user 'username)]
               [password (hash-ref user 'password)]
               [user-id (register username password)])
          (cond
            [(not (exn:fail:sql? user-id))
             (ok (hasheq 'user (hasheq 'token (get-jwt user-id)
                       'username username)))]
            [(string=? "23000" (cdr (assoc 'code (exn:fail:sql-info user-id))))
             (bad-request (hasheq 'username "Username taken"))]
            [else
             (begin (display (cdr (assoc 'code (exn:fail:sql-info user-id))))
                    (display (string=? "23000" (cdr (assoc 'code (exn:fail:sql-info user-id)))))
                    (server-error "idk"))]))))

(cors post "/users/login"
     (lambda (req)
       (let* ([user (hash-ref (json-body req) 'user)]
              [username (hash-ref user 'username)]
              [password (hash-ref user 'password)]
              [user-record (get-user username)])
         (if (and user-record (bcrypt:check (vector-ref user-record 2)
                                     (string->bytes/utf-8 password)))
             (ok (hasheq 'user
                         (hasheq 'username username
                                 'token (get-jwt (vector-ref user-record 0)))))
             (bad-request (hasheq 'username "No such username password combination"))))))

;;; Food

; queries

(define (search-food pattern offset count)
  (query-rows db-conn
              "select food_id, food_name from foods where food_name like ? order by length(food_name) limit ?, ?"
              pattern offset count))

(define (get-food-by-name name)
  (query-maybe-row db-conn "select * from foods where food_name = ?"
                   name))

(define (create-food name img-path)
  (query-exec db-conn
              "insert into foods (food_name, img_path) value(?, ?)"
              name img-path))

(define (delete-food id)
  (query-exec db-conn
              "delete from foods where food_id = ?" id))

; routes

(cors get "/foods"
      (lambda (req)
        (let* ([pattern (string-append "%" (params req 'q) "%")]
               [offset (params req 'offset)]
               [count (params req 'count)]
               [response (search-food pattern
                                      (if (empty-string? offset) 0 offset)
                                      (if (empty-string? count) 20 count))]
               [encoder (lambda (row)
                          (hasheq 'food_id (vector-ref row 0)
                                  'food_name (vector-ref row 1)))])
          (ok (hasheq 'foods
                      (map encoder response))))))

(cors post "/foods"
      (lambda (req)
        (begin
          (create-food (params req 'food_name) (params req 'img_path))
          (ok ""))))

(cors delete "/food/:foodid"
      (lambda (req)
        (begin
          (delete-food (params req 'foodid))
          (ok ""))))

;; Pantry

; queries

(define (get-pantry user-id)
  (map (lambda (row)
         (hasheq 'name (vector-ref row 0)
                 'id (string->number (vector-ref row 1))))
       (query-rows
        db-conn
        (string-append
         "call get_user_pantry(" user-id ")"))))

(define (add-to-pantry user-id food-id)
  (query-exec db-conn
              (string-append
               "call add_to_pantry(" user-id ", " food-id ")")))

(define (delete-from-pantry user-id food-id)
  (query-exec db-conn
              "delete ignore from pantry_contents where user_id = ? and food_id = ?"
              user-id
              food-id))

;routes

(cors get "/pantry"
     (lambda (req)
       (let* ([token (get-token req)]
              [user-id (token-user-id token)])
         (if user-id
             (ok (hasheq 'pantry (get-pantry user-id)))
             unauthed))))

(cors post "/pantry"
      (lambda (req)
        (let* ([token (get-token req)]
               [user-id (token-user-id token)])
          (if user-id
              (begin
                (add-to-pantry user-id (params req 'id))
                (ok (hasheq 'pantry (get-pantry user-id))))
              unauthed))))

(cors delete "/pantry/:foodid"
      (lambda (req)
        (let* ([token (get-token req)]
               [user-id (token-user-id token)])
          (if user-id
              (begin
                (delete-from-pantry
                            user-id
                            (params req 'foodid))
                (ok (hasheq 'pantry (get-pantry user-id))))
              unauthed))))

;;;; Run

(run)
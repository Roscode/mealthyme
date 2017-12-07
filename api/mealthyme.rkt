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


(define db-conn
  (virtual-connection
   (connection-pool
    (lambda ()
      (mysql-connect #:server "localhost"
                     #:port 3306
                     #:database "mealthyme"
                     #:user "mealthyme")))))

(define jwt-secret "ThisIsTheBestSecretEver")

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

(define (register username password)
  (with-handlers ([exn:fail:sql? identity])
    (query-value db-conn
                 "select register(?, ?)"
                 username
                 (bcrypt:encode (string->bytes/utf-8 password)))))

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

(define (get-user username)
  (query-maybe-row db-conn "select user_id, username, password_hash from users where username = ?"
             username))

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

(define (get-token req)
  (string-trim (cdr (assoc (string->symbol "x-jwt") (request-headers req)))
               "Bearer: "))

(define (token-user-id token)
  (let ([verified (jwt:decode/verify token "HS256" jwt-secret)])
    (if verified
        (jwt:subject verified)
        verified)))

(define (get-pantry user-id)
  (map (lambda (row)
         (hasheq 'name (vector-ref row 0)
                 'id (vector-ref row 1)))
       (query-rows
        db-conn
        "select food_name, food_id from foods join pantry_contents using (food_id) where user_id = ?"
        user-id)))

(cors get "/pantry"
     (lambda (req)
       (let* ([token (get-token req)]
              [user-id (token-user-id token)])
         (if user-id
             (ok (hasheq 'pantry (get-pantry user-id)))
             unauthed))))

(get "/foods"
     (lambda (req)
       (ok (hasheq 'foods
                   (map
                    (lambda (row)
                      (hasheq 'name (vector-ref row 0)
                              'id (vector-ref row 1)))
                    (query-rows
                     db-conn
                     (string-append
                      "select food_name, food_id from foods where food_name like '%"
                      (params req 'q)
                      "%' limit 15")))))))

(get "/add"
     (lambda (req)
       (begin
         (query-exec db-conn
                     "insert ignore into pantry_contents (user_id, food_id) values (?, ?)"
                     (params req 'u)
                     (params req 'f))
         (ok (hash 'items
                   (query-list db-conn
                               (string-append "call user_pantry("
                                              (params req 'u)
                                              ")")))))))

(post "/food"
      (lambda (req)
        (ok
         (query-exec db-conn
                     "insert into foods (food_name) values (?)"
                     (params req 'food_name)))))

(run)
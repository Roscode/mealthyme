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

(define (get-jwt userid)
  (jwt:encode/sign "HS256" "HaroldTheBallPlayer"
                   #:exp (+ (current-seconds) 172800)
                   #:iat (current-seconds)
                   #:other (hasheq 'uid userid)))

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
             (header #"Access-Control-Allow-Methods" #"POST")
             (header #"Access-Control-Allow-Headers" #"Content-Type")
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

(get "/pantry"
     (lambda (req)
       (ok (hash 'items
                 (query-list db-conn
                             (string-append "call user_pantry("
                                            (params req 'uid)
                                            ")"))))))

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

(get "/foods"
     (lambda (req)
       (ok (hash 'foods
                 (make-hasheq
                  (for/list
                      ([row
                        (in-list (query-rows
                                  db-conn
                                  (string-append
                                   "select food_id, food_name from foods where food_name like '%"
                                   (params req 'q)
                                   "%' limit 15")))])
                    (cons (string->symbol (vector-ref row 1)) (vector-ref row 0))))))))

(post "/food"
      (lambda (req)
        (ok
         (query-exec db-conn
                     "insert into foods (food_name) values (?)"
                     (params req 'food_name)))))

(run)
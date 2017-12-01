#lang racket

(require db
         (planet dmac/spin)
         web-server/servlet
         web-server/http
         web-server/http/request-structs
         json)


(define db
  (mysql-connect #:server "localhost"
                 #:port 3306
                 #:database "mealthyme"
                 #:user "mealthyme"))

(define cors-header (header #"Access-Control-Allow-Origin" #"*"))

(get "/login"
      (lambda (req)
        (list 200
              (list cors-header)
              (jsexpr->string
                (hash 'userId
                      (query-value db
                                   "select login_signup(?)" (params req 'username)))))))
(get "/foods"
     (lambda (req)
       (list 200
             (list cors-header)
             (jsexpr->string
              (hash 'foods
                    (make-hasheq (for/list
                                   ([row
                                     (in-list (query-rows
                                               db
                                               (string-append
                                                "select food_id, food_name from foods where food_name like '%"
                                                (params req 'q)
                                                "%' and food_id not in (Select food_id from pantry_contents where user_id = "
                                                (params req 'u)
                                                ")
 limit 15")))])
                      (cons (string->symbol (vector-ref row 1)) (vector-ref row 0)))))))))

(get "/pantry"
     (lambda (req)
       (list 200
             (list cors-header)
             (jsexpr->string
              (hash 'foods
                    (make-hasheq
                     (for/list
                         ([row (in-list (query-rows db
                                                    "select food_id, food_name from foods join pantry_contents using (food_id) where user_id = ?"
                                                    (params req 'uid)))])
                       (cons (string->symbol (vector-ref row 1)) (vector-ref row 0)))))))))

(get "/add"
     (lambda (req)
       (list 200
             (list cors-header)
             (begin
               (query-exec db
                           "insert ignore into pantry_contents (user_id, food_id) values (?, ?)"
                           (params req 'u)
                           (params req 'f))
               (jsexpr->string
                (hash 'foods
                    (make-hasheq
                     (for/list
                         ([row (in-list (query-rows db
                                                    "select food_id, food_name from foods join pantry_contents using (food_id) where user_id = ?"
                                                    (params req 'u)))])
                       (cons (string->symbol (vector-ref row 1)) (vector-ref row 0))))))))))

(get "/remove"
     (lambda (req)
       (list 200
             (list cors-header)
             (begin
               (query-exec db
                           "delete from pantry_contents where user_id = ? and food_id = ?"
                           (params req 'u)
                           (params req 'f))
               (jsexpr->string
                (hash 'foods
                      (make-hasheq
                       (for/list
                           ([row (in-list (query-rows db
                                                      "select food_id, food_name from foods join pantry_contents using (food_id) where user_id = ?"
                                                      (params req 'u)))])
                         (cons (string->symbol (vector-ref row 1)) (vector-ref row 0))))))))))



(post "/food"
      (lambda (req)
        (query-exec db "insert into foods (food_name) values (?)" (params req 'food_name))))

(define (json-response-maker status headers body)
  (response status
            (status->message status)
            (current-seconds)
            #"application/json; charset=utf-8"
            headers
            (let ([jsexpr-body (string->jsexpr body)])
              (lambda (op) (write-json (force jsexpr-body) op)))))

(run #:response-maker json-response-maker)

(disconnect db)
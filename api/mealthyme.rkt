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

(get "/login"
      (lambda (req)
        (define h (header #"Access-Control-Allow-Origin" #"*"))
        (list 200
              (list h)
              (jsexpr->string
                (hash 'userId
                      (query-value db
                                   "select login_signup(?)" (params req 'username)))))))

(get "/pantry"
     (lambda (req)
       (define h (header #"Access-Control-Allow-Origin" #"*"))
       (list 200
             (list h)
             (jsexpr->string
              (hash 'items
                    (query-list db
                                (string-append "call user_pantry("
                                               (params req 'uid)
                                               ")")))))))

(get "/foods"
     (lambda (req)
       (define h (header #"Access-Control-Allow-Origin" #"*"))
       (list 200
             (list h)
             (jsexpr->string
              (hash 'foods
                    (make-hasheq (for/list
                                   ([row
                                     (in-list (query-rows
                                               db
                                               (string-append
                                                "select food_id, food_name from foods where food_name like '%"
                                                (params req 'q)
                                                "%' limit 15")))])
                      (cons (string->symbol (vector-ref row 1)) (vector-ref row 0)))))))))

(post "/food"
      (lambda (req)
        (query-exec db "insert into foods (food_name) values (?)" (params req 'food_name))))

(get "/food/:id"
     (lambda (req)
       (jsexpr->string (query-value
                        db
                        "select food_name from foods where food_id = ?"
                        (params req 'id)))))

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
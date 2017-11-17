#lang racket

(require db
         (planet dmac/spin)
         web-server/servlet
         json)


(define db
  (mysql-connect #:server "localhost"
                 #:port 3306
                 #:database "mealthyme"
                 #:user "mealthyme"))


(get "/food"
     (lambda ()
       (jsexpr->string (query-list db "select food_name from foods;"))))

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
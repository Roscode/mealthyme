#lang racket

(require db)

(define mydb
  (mysql-connect #:server "localhost"
                 #:port 3306
                 #:database "mealthyme"
                 #:user "mealthyme"))

(call-with-input-file "foods.txt"
  (lambda (in)
    (for ([line (in-lines in)])
      (query-exec mydb "insert into new_food_test (food_name) values (?)" line)))
  #:mode 'text)

(disconnect mydb)
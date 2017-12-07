#lang racket

(require db)

(define db-conn
  (mysql-connect #:server "localhost"
                  #:port 3306
                  #:database "mealthyme"
                  #:user "mealthyme"))



(displayln (query-exec db-conn "call add_to_pantry(1, 5)"))
(displayln (query-rows db-conn "call get_user_pantry(1)"))
(displayln (query db-conn "delete from pantry_contents where user_id = 1 and food_id = 5"))
(displayln (query-rows db-conn "call get_user_pantry(1)"))
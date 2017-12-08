#lang racket

(require db
         json)

(define db-conn
  (mysql-connect #:server "localhost"
                  #:port 3306
                  #:database "mealthyme"
                  #:user "mealthyme"))

(define (safe val)
  (if (eq? val 'null)
      0
      val))

(define (add-ingredients filename)
  (let* ([full (call-with-input-file filename read-json)]
       [matches (hash-ref full 'matches)])
  (for ([m (in-list matches)])
    (let ([ingredients (hash-ref m 'ingredients)]
          [rid (hash-ref m 'id)])
      (for ([i (in-list ingredients)])
        (query-exec db-conn
                  "call add_ingredient_to_recipe(?, ?)"
                  rid
                  i))))))

(define (add-recipes filename)
  (let* ([full (call-with-input-file filename read-json)]
       [matches (hash-ref full 'matches)])
  (for ([m (in-list matches)])
    (query-exec db-conn
                "insert into recipes value (?, ?, ?, ?, ?)"
                (hash-ref m 'id)
                (hash-ref m 'recipeName)
                (hash-ref m 'rating)
                (hash-ref m 'sourceDisplayName)
                (hash-ref (hash-ref full 'attribution) 'html)))))

(define (add-all filename)
  (add-recipes filename)
  (add-ingredients filename))

(add-all "panresponse")

(disconnect db-conn)
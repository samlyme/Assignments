(define (max-vec v)
  (define (max-iter v champ i)
    (if (= i (vector-length v))
        champ
        (if (> (vector-ref v i) champ)
            (max-iter v (vector-ref v i) (+ i 1)) 
            (max-iter v champ (+ i 1)))))         
  
  (max-iter v (vector-ref v 0) 0))

(define (max-vec-vec vv)
  (define (max-iter vv champ i)
    (if (= i (vector-length vv))
        champ
        (let ((m (max-vec (vector-ref vv i))))
          (if (> m champ)
              (max-iter vv m (+ i 1))
              (max-iter vv champ (+ i 1))))))
  (if (= (vector-length vv) 0)
      (error "Empty vector")
      (max-iter vv (max-vec (vector-ref vv 0)) 1)))

(define (cycle-to-word cycles)
    (define m (+ 1 (max-vec-vec cycles)))
    (define word (make-vector m 0))
    (define (cycle-iter cycle i) 
        (define n (vector-length cycle))
        (if (< i n)
            (begin 
                (vector-set!
                    word
                    (vector-ref cycle i)
                    (vector-ref cycle (modulo (+ 1 i) n)))
                (cycle-iter cycle (+ 1 i))
            )))
    (define l (vector-length cycles))
    (define (cycles-iter i)
        (if (< i l) 
            (begin
                (cycle-iter (vector-ref cycles i) 0)
                (cycles-iter (+ 1 i))
            )
        )
    )
    (cycles-iter 0)
    word
)
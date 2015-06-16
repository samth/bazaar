#lang racket/base

(require racket/dict
         math/flonum
         racket/fixnum
         racket/extflonum
         math/bigfloat
         racket/unsafe/ops)

(provide use-numeric-kind)

(module+ test
  (require rackunit))

;; In case we receive a float, convert it.
(define (fx x)
  (fl->fx (fl x)))

(define (unsafe-fx x)
  (unsafe-fl->fx (fl x)))

(define op-dict
  (list
   (list '$?   real?   fixnum?     flonum?  extflonum?      bigfloat?         fixnum?            flonum?      extflonum?)
   (list '$    values  fx          fl       real->extfl     bf                unsafe-fx          fl           real->extfl) ; real->$
   (list '$->  values  fx->fl      values   extfl->inexact  bigfloat->flonum  unsafe-fx->fl      values       extfl->inexact) ; $->real
   (list '$+   +       fx+         fl+      extfl+          bf+               unsafe-fx+         unsafe-fl+   unsafe-extfl+)
   (list '$-   -       fx-         fl-      extfl-          bf-               unsafe-fx-         unsafe-fl-   unsafe-extfl-)
   (list '$*   *       fx*         fl*      extfl*          bf*               unsafe-fx*         unsafe-fl*   unsafe-extfl*)
   (list '$/   /       fxquotient  fl/      extfl/          bf/               unsafe-fxquotient  unsafe-fl/   unsafe-extfl/)
   (list '$=   =       fx=         fl=      extfl=          bf=               unsafe-fx=         unsafe-fl=   unsafe-extfl=)
   (list '$>   >       fx>         fl>      extfl>          bf>               unsafe-fx>         unsafe-fl>   unsafe-extfl>)
   (list '$<   <       fx<         fl<      extfl<          bf<               unsafe-fx<         unsafe-fl<   unsafe-extfl<)
   (list '$>=  >=      fx>=        fl>=     extfl>=         bf>=              unsafe-fx>=        unsafe-fl>=  unsafe-extfl>=)
   (list '$<=  <=      fx<=        fl<=     extfl<=         bf<=              unsafe-fx<=        unsafe-fl<=  unsafe-extfl<=)
   ; to complete...
   ))

(define (subindex e l [= equal?])
  (let loop ([l l] [idx 0])
    (cond [(null? l) #f]
          [(member e (car l) =) idx]
          [else (loop (cdr l) (+ idx 1))])))

(define (get-op op-sym kind)
  (define idx
    (subindex kind '((default generic real #f)
                     (fixnum fx)
                     (flonum fl)
                     (extflonum extfl)
                     (bigfloat bf)
                     (unsafe-fixnum unsafe-fx)
                     (unsafe-flonum unsafe-fl)
                     (unsafe-extflonum unsafe-extfl)
                     )))
  (unless idx
    (error "Could not find numeric kind: " kind))
  (list-ref (dict-ref op-dict op-sym) idx))

(define-syntax-rule (use-numeric-kind num-kind (op ...) body ...)
  (let ([op (get-op 'op num-kind)] ...)
    body ...))

(module+ test
  (define (test-kind kind)
    (use-numeric-kind
     kind ($ $? $= $+ $- $* $/ $> $< $>= $<=)
     (define n ($/ ($- ($+ ($ 3) ($ 2)) ($ 15))
                   ($ 2)))
     (check-pred $? n)
     (check $= n ($ -5))))
  (for ([kind '(real fx fl extfl bf)])
    (test-kind kind)))

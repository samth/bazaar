#lang racket/base
;;; Copyright (C) Laurent Orseau, 2010-2013
;;; GNU Lesser General Public Licence (http://www.gnu.org/licenses/lgpl.html)

(provide (all-defined-out))

;; Defines a function or a variable and provides it at the same time.
;(provide define/provide)
(define-syntax define/provide 
  (syntax-rules ()
    ; function case:
    [(_ (name args ... . l) body ...)
     (begin (provide name)
            (define (name args ... . l) body ...))]
    ; variable case:
    [(_ name val)
     (begin (provide name)
            (define name val))]
    ))

#lang racket/base
;;; Copyright (C) Laurent Orseau, 2010-2013
;;; GNU Lesser General Public Licence (http://www.gnu.org/licenses/lgpl.html)

(require (for-syntax syntax/parse
                     racket/base))

(provide debug-var)

(begin-for-syntax
  ; From unstable/syntax
  (define (syntax-source-file-name stx)
    (let* ([f (syntax-source stx)])
      (and (path-string? f)
           (let-values ([(base file dir?) (split-path f)]) file)))))

(define-syntax debug-var
  (syntax-parser 
   [(_ var:id)
    (with-syntax ([line (syntax-line #'var)]
                  [file (syntax-source-file-name #'var)])
      #'(printf "~a:~a ~a=~a" file line 'var var))]))
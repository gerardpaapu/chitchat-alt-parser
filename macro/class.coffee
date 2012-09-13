###

conexpr   := the constructor expression
superexpr := the superclass expression
%beget is a primitive that compiles to `Object.beget(expr)`

In my imaginarium where I have a macro system, this is what
the class macro looks like.

(define-macro (class body)
  (let ( ... )
    (with-gensyms (Constructor Super proto))
        `(define name (let (;; eval conexpr and superexpr once-only
                            (,Constructor (function ,@conexpr))
                            (,Super ,superexpr)

                           ;; create the prototype from the super class
                           (,proto (#,%beget Super:prototype)))

            (set-property! ,Constructor 'prototype' ,proto)

            ;; define each instance method
            ,@(map (lambda ()
                     (let ((name ...)
                           (body ...))
                      `(set-property! ,proto ,name (function ,@body)))
                    ,instanceMethods)

            ;; define each static method
            ,@(map (lambda ()
                     (let ((name ...)
                           (body ...))
                      `(set-property! ,name (function ,@body)))
                    ,staticMethods)

            ,Constructor))))


// which will compile to something like this
var name = (function (Constructor, Super, proto) {
    proto = Object.beget(Super.prototype);

    Constructor.prototype = Object.beget(Super.prototype);

    Constructor.prototype.method = function () {};

    Constructor.staticMethod = function () {};

    return Constructor;
}(conexpr, superexpr));

###


Macro.define['class'] = (body) ->

###
Accessors
---------

An expression in Chitchat can be suffixed with an accessor

An accessor is an accessor-operator followed by a key

the three types of accessor-operators are:

    - pass-message, written as '.'
    - primitive-get, written as ':'
    - primitive-get-prototype, written as '::'

the key is written either as an expression or a symbol

    - if written as a symbol, the string value of the symbol is the key
    - if written as an expression, it is an arbitrary chitchat expression
      delimited by '[' and ']'

Except in a 'set' expression, an accessor is either translated to a message-pass
or a get-property! call

    foo.bar    -> (foo bar)
    foo.[bar]  -> (foo getItem bar)
    foo:bar    -> (get-property! foo 'bar')
    foo:[bar]  -> (get-property! foo bar)
    foo::bar   -> (get-property! foo:prototype 'bar')
    foo::[bar] -> (get-property! foo:prototype bar)

get-property! is a primitive that compiles from `(get-property! foo 'bar')`
to `foo['bar']` (roughly).

Inside of a 'set' expression an accessor is transformed into either a
primitive 'set' operation or the message 'set' passed with the appropriate=
arguments.

    (set foo.bar baz)    -> (foo set 'bar' baz)
    (set foo.[bar] baz)  -> (foo setItem bar baz)
    (set foo:bar baz)    -> (set-property! foo 'bar' baz)
    (set foo:[bar] baz)  -> (set-property! foo bar baz)
    (set foo::bar baz)   -> (set-property! foo:prototype 'bar' baz) 
    (set foo::[bar] baz) -> (set-property! foo:prototype bar baz) 

set-property! is a primitive that compiles from `(set-property! foo 'bar' baz)`
to `foo['bar'] = baz` (roughly).
###
{Parser, SequenceIW, OR} = require './Parser'
{symbolParser} = require './symbol'

class DotAccessor
    constructor: (@root, @key) ->

class PrimitiveAccessor
    constructor: (@root, @key) ->

class PrototypeAccessor
    constructor: (@root, key) ->

wrap = (Klass) ->
    (key) ->
        (root) -> new Klass(root, key)

expressionParser = (simpleExpressionParser) ->
    subexp = Parser.delay -> 
        expressionParser(simpleExpressionParser)

    simpleExpressionParser()
        .plus(suffixParser subexp)
        .convert (arr) -> 
            [root, wrapper] = arr
            wrapper(root)

suffixParser = (expressionParser) ->
    OR(accessorParser('.', expressionParser).convert(wrap DotAccessor),
       accessorParser(':', expressionParser).convert(wrap PrimitiveAccessor),
       accessorParser('::', expressionParser).convert(wrap PrototypeAccessor),
       new Parser.Result (root) -> root)

accessorParser = (operator, expressionParser) ->
    Parser(operator)
        .ignoreWhitespace()
        .and(keyParser expressionParser)

keyParser = (expressionParser) ->
    OR(symbolParser().convert((x) -> x.value), 
       expressionParser.surroundedByIW('[', ']'))

exports.expressionParser = expressionParser
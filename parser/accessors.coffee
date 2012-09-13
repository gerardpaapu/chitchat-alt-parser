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
{DotAccessor, PrimitiveAccessor, PrototypeAccessor, AtomLiteral} = require('../common/common')

wrap = (Klass) ->
    (key) ->
        (root) -> new Klass(root, key)

expressionParser = (simpleExpressionParser) ->
    ###
    given simple expression parser 's'
    this grammar is used over (expr := expr | expr rest)
    or similar because it's difficult to remove the 
    left-side recursion without affecting the associativity

    exp  := <s> ( <tail> )*
    tail := <op> <key>
    op   := '.' | '::' | '.'
    key  := <symbol> | '[' <exp> ']'

    ###
    simpleExpressionParser()
        .plus(suffixParser simpleExpressionParser)
        .convert (arr) ->
            ###
            then you have to unwrap the list, to restore
            left associativity.

            wrap root []     = root
            wrap root [x:xs] = wrap x(root) xs
            ###
            _wrap = (root, suffixes) ->
                if suffixes.length is 0
                    root
                else
                    [fn, rest...] = suffixes
                    _wrap fn(root), rest
  
            [root, suffixes] = arr
            _wrap root, suffixes

suffixParser = (expressionParser) ->
    OR(
        accessorParser('.', expressionParser).convert(wrap DotAccessor),
        accessorParser(':', expressionParser).convert(wrap PrimitiveAccessor),
        accessorParser('::', expressionParser).convert(wrap PrototypeAccessor)
    ).zeroOrMore()

accessorParser = (operator, expressionParser) ->
    Parser(operator)
        .ignoreWhitespace()
        .and(keyParser expressionParser)

keyParser = (simpleExpressionParser) ->
    expr = Parser.delay ->
        expressionParser(simpleExpressionParser)

    OR(symbolParser().convert((x) -> new AtomLiteral(x.value)), 
       expr.surroundedBy('[', ']'))

exports.expressionParser = expressionParser
exports.DotAccessor = DotAccessor
exports.PrimitiveAccessor = PrimitiveAccessor
exports.PrototypeAccessor = PrototypeAccessor
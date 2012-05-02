# A Parser from A to B is a function that takes A and returns
# a Parsing Result where the 'value' is a Tree of B and the 'rest'
# is a B
# 
# e.g. a Parser<String, Syntax> will consume a string and return a Parsing
# Result that contains a Tree of Syntax and a String of the Remainder to 
# Parse.

# Parser<A, B> := Function<A, ParsingResult<B, A>
# 
# ParsingResult<B, A> := { Tree<B> value, A rest }

type = (obj) ->
    switch obj
        when null then 'Null'
        when undefined then 'Undefined'
        else
            Object::toString.call(obj).slice(8, -1)

class Parser
    parse: (input) ->
        throw new Error 'Not Implemented'

    @wrap: (parse) ->
        parser = new Parser()
        parser.parse = parse

        return parser

    @from: (obj) ->
        return obj if obj instanceof Parser

        switch type obj
            when 'String'
                new Parser.Exactly obj
            when 'Regexp'
                new Parser.RegExp obj
            when 'Function'
                Parser.wrap obj
            else
                throw new TypeError()

class ParseResult
    constructor: (@value, @rest) ->

    then: (_function) ->
        _function(@value, @rest)

class ParseFailure extends ParseResult
    constructor: ->
        ParseFailure.instance ?= @

    then: (makeParser) ->
        new ParseFailure

    toString: -> 
        '<ParseFailure>'

# Primitive Parsers (Result, Fail and Item)
class Parser.Result extends Parser
    constructor: (@value) ->

    parse: (input) ->
        new ParseResult(@value, input)

class Parser.Fail extends Parser
    parse: (input) ->
        new ParseFailure()

class Parser.Item extends Parser
    parse: (input) ->
        if input.length > 0
            new ParseResult(input[0], input[1..])
        else
            new ParseFailure()

# Simple Matching Parsers
class Parser.Exactly extends Parser
    constructor: (@str) ->

    parse: (input) ->
        len = @str.length
        chunk = input.slice(0, len)
        rest = input.slice(len)

        if chunk is @str
            new ParseResult(@str, rest)
        else
            new ParseFailure()

cloneRegexp = (source) ->
    destination = new RegExp(source.source)

    destination.global = source.global
    destination.ignoreCase = source.ignoreCase
    destination.multiline = source.multiline

    return destination

class Parser.RegExp extends Parser
    constructor: (pattern) ->
        @_pattern = pattern

    getPattern: ->
        # clone the RegExp each time we use it
        # because JS RegExp objects are stateful
        # and we don't want that baggage
        cloneRegexp @_pattern

    parse: (input) ->
        match = @getPattern().exec(input)

        if match?
            new ParseResult(match[0], input.slice(match[0].length))
        else
            new ParseFailure()

# Basic Combinator methods
Parser::bind = (makeParser) ->
    Parser.wrap (input) =>
        @parse(input).then (value, rest) ->
            makeParser(value).parse(rest)

Parser.Satisfies = (predicate) ->
    new Parser.Item().bind (x) ->
        if predicate(x)
            new Parser.Result(x)
        else
            new Parser.Fail() 

ParseResult::otherwise = (_function) ->
    this

ParseFailure::otherwise = (_function) ->
    _function()

Parser::inverse = (makeParser) ->
    Parser.wrap (input) =>
        @parse(input).otherwise () ->
            makeParser().parse(input)

OR = (parser, rest...) ->
    NOT(parser).bind (value) ->
        if rest.length is 0
            new Parser.Fail()
        else
            OR(rest...)

NOT = (parser) ->
    Parser.wrap (input) ->
        result = parser.parse input

        if result instanceof ParseFailure()
            new ParseResult(true, input)
        else
            new ParseFailure

AND = (parser, rest...) ->
    Parser.from(parser).bind (value) ->
        if rest.length is 0
            new Parser.Result(value)
        else
            AND(rest...)

DO = (table) ->
    returns = table.returns
    delete table.returns

    throw new TypeError() unless returns?

    pairs =([key, value] for key, value of table)
    env = {}

    _DO = (pairs) ->
        if pairs.length is 0
            returns.call env
        else
            [first, rest...] = pairs
            [key, _function] = first
            throw new TypeError unless _function?
            env[key] = _function.call(env)
            env[key].bind (value) ->
                _DO(rest)

    _DO(pairs)

eqChar = (char) ->
    new Parser.Item().bind (value) ->
        if value is char
            new Parser.Result(char)
        else
            new Parser.Fail()

eqString = (string) ->
    if string.length is 0
        new Parser.Result('')
    else
        DO
            ch: -> eqChar string[0]
            _ : -> eqString string[1..]

            returns: ->
                new Parser.Result(string)

foo = eqString('foo')

console.log foo.parse 'foobar'

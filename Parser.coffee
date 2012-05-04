###

A Parser from A to B is a function that takes A and returns
a Parsing Result where the 'value' is a Tree of B and the 'rest'
is a B
 
e.g. a Parser<String, Syntax> will consume a string and return a Parsing
Result that contains a Tree of Syntax and a String of the Remainder to 
Parse.
 
Parser<A, B> := Function<A, ParsingResult<B, A>>

ParsingResult<B, A> := { Tree<B> value, A rest }
###

type = (obj) ->
    switch obj
        when null then 'Null'
        when undefined then 'Undefined'
        else
            Object::toString.call(obj).slice(8, -1)

prepend = (item, array) ->
    throw new TypeError unless type(array) is 'Array'
    [ item ].concat(array)


class Parser
    constructor: (arg) ->
        if arguments.length > 0
            return Parser.from arg

    # A class to wrap a Function<string, ParseResult>
    # because of my OO religion
    parse: (input) ->
        throw new Error 'Not Implemented'

    # 'parse' should be a Function<string, ParseResult>
    @wrap: (parse) ->
        parser = new Parser()
        parser.parse = parse

        return parser

    # Shortcuts for defining the most common
    # simple parser types
    @from: (obj) ->
        return obj if obj instanceof Parser

        switch type obj
            when 'String'
                new Parser.Exactly obj

            when 'RegExp'
                new Parser.RegExp obj

            when 'Function'
                Parser.wrap obj

            when 'Array'
                Parser.Sequence obj...

            else
                throw new TypeError("wtf is #{obj}")

exports.Parser = Parser

class ParseResult
    constructor: (@value, @rest) ->

    failed: false

    then: (_function) ->
        _function(@value, @rest)

class ParseFailure extends ParseResult
    constructor: ->
        ParseFailure.instance ?= @

    failed: true

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
    constructor: (pattern, index) ->
        @_pattern = pattern
        @index = index ? 0

    getPattern: ->
        # clone the RegExp each time we use it
        # because JS RegExp objects are stateful
        # and we don't want that baggage
        cloneRegexp @_pattern

    parse: (input) ->
        match = @getPattern().exec(input)

        if match?
            val = match[@index]
            new ParseResult(val, input.slice(match[0].length))
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
    Parser.wrap (input) ->
        parser = Parser.from(parser)
        result = parser.parse(input)
        
        unless result instanceof ParseFailure
            return result

        if rest.length is 0
            new ParseFailure()
        else
            OR(rest...).parse(input)

Parser::or = (parsers...) ->
    OR(this, parsers...)

exports.OR = OR

Maybe = (parser, _default) ->
    Parser.wrap (input) ->
        parser = Parser.from(parser)
        result = parser.parse(input)
        if result instanceof ParseFailure
            new ParseResult(_default, input)
        else
            result

exports.Maybe = Maybe

Parser::maybe = (_default) ->
    Maybe this, _default

NOT = (parser) ->
    Parser.wrap (input) ->
        parser = Parser.from(parser)
        result = parser.parse input

        if result instanceof ParseFailure
            new ParseResult(true, input)
        else
            new ParseFailure

AND = (parser, rest...) ->
    Parser.from(parser).bind (value) ->
        if rest.length is 0
            new Parser.Result(value)
        else
            AND(rest...)

Parser::and = (parsers...) ->
    AND this, parsers...


DO = (table) ->
    cloneEnv = (obj) ->
        table = {}
        for key, value of obj
            table[key] = value

        table

    returns = table.returns
    delete table.returns

    throw new TypeError() unless returns?

    pairs =([key, value] for key, value of table)
    env = {}

    _DO = (pairs, env) ->

        if pairs.length is 0
            returns.call env
        else
            [first, rest...] = pairs
            [key, _function] = first

            throw new TypeError unless _function?

            parser = _function.call(env)

            unless parser?
                throw new TypeError "bad parser @ #{key}" 

            Parser.from(parser).bind (value) ->
                env[key] = value
                _DO(rest, cloneEnv(env))

    Parser.from (input) ->
        _DO(pairs, cloneEnv(env)).parse(input)

exports.DO = DO

OneOrMore = (parser) ->
    DO
        first: -> parser
        rest: -> OneOrMore(parser).maybe([])

        returns: ->
            new Parser.Result prepend(@first, @rest)

Parser::oneOrMore = -> 
    OneOrMore this

ZeroOrMore = (parser) ->
    OneOrMore(parser).maybe([])

Parser::zeroOrMore = ->
    ZeroOrMore this

ignoreWhitespace = (parser) ->
    DO 
        leading: -> /^\s*/,
        body: -> parser
        trailing: -> /^\s*/

        returns: ->
            new Parser.Result @body

Parser::ignoreWhitespace = ->
    ignoreWhitespace this

Sequence = Parser.Sequence = (parser, rest...) ->
    if rest.length is 0
        return Parser.from(parser).convert (x) -> [x]

    DO
        first: -> parser
        rest: -> Sequence rest...

        returns: ->
            new Parser.Result prepend(@first, @rest)

Parser.Sequence = Sequence

IS = (parser, predicate) ->
    parser.bind (value) ->
        if predicate value
            new Parser.Result value
        else
            new Parser.Fail()

ISNT = (parser, predicate) ->
    parser.bind (value) ->
        if predicate value
            new Parser.Fail()
        else
            new Parser.Result(value)

Parser::is = (predicate) ->
    IS this, predicate

Parser::isnt = (predicate) ->
    ISNT this, predicate

Parser::convert = (converter) ->
    @bind (value) ->
        new Parser.Result converter(value)

Parser::convertTo = (Klass) ->
    @bind (value) ->
        new Parser.Result new Klass(value)

Parser::surroundedBy = (open, close) ->
    parser = this
    DO
        open: -> open
        body: -> parser
        close: -> close

        returns: ->
            new Parser.Result @body

class Parser.Trace extends Parser
    constructor: (parser) ->
        @parser = Parser.from parser

    parse: (input) ->
        console.log "TRACE (before): #{input[0..10]}"
        @parser.parse(input).then (value, input) ->
            console.log "TRACE (value): #{value} "
            console.log "TRACE (after): #{input[0..10]}"
            new ParseResult value, input

Parser::trace = -> new Parser.Trace this

Parser::separatedBy = (comma) ->
    parser = this
    _comma = Parser.from(comma)

    DO
        first: -> parser
        rest: -> _comma.and(parser).zeroOrMore()

        returns: ->
            new Parser.Result prepend(@first, @rest)


Parser::followedBy = (suffix) ->
    parser = this

    DO
        x: -> parser
        _: -> suffix

        returns: ->
            new Parser.Result @x


Parser::plus = (parser) ->
    Sequence this, parser

Parser.delay = (makeParser) ->
    Parser.wrap (input) ->
        makeParser().parse(input)
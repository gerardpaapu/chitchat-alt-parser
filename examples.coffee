{Parser, DO, OR} = require './Parser'

digitsListParser = ->
    Parser(/\d+/).convert(Number)
        .ignoreWhitespace()
        .separatedBy(',')
        .surroundedBy('(', ')')


console.log digitsListParser().parse('(2 , 321 , 88,  1, 7)').value 
# logs [ 2, 321, 88, 1, 7 ]

simpleTableParser = (parser) ->
    # parse a single value for the table
    valueParser = ->
        OR(parser, simpleTableParser parser)
            .ignoreWhitespace()

    pairParser = -> DO
        key: -> /[a-z]+/
        colon: -> ':'
        value: -> valueParser()

        returns: ->
            new Parser.Result [@key, @value]

    associate = (pairs) ->
        # convert [[key, value], ...] to { key: value, ...}
        table = {}

        for [key, value] in pairs
            throw new SyntaxError() if table[key]?
            table[key] = value

        table

    pairParser()
        .ignoreWhitespace()
        .separatedBy(',')
        .surroundedBy('{', '}')
        .ignoreWhitespace()
        .convert(associate)
           


console.log simpleTableParser(digitsListParser()).parse("
{
    foo: (1, 3, 4),
    bar: (44, 7),
    baz: (000, 433),
    quux: { butt: (1), face: (3, 4)}
}
").value




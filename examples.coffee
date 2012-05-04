{Parser, DO} = require './Parser'

digitsListParser = ->
    Parser(/\d+/).convert(Number)
        .ignoreWhitespace()
        .separatedBy(',')
        .surroundedBy('(', ')')


console.log digitsListParser().parse('(2 , 321 , 88,  1, 7)').value 
# logs [ 2, 321, 88, 1, 7 ]

simpleTableParser = (parser) ->
    pairParser = -> DO
        key: -> /[a-z]+/
        colon: -> ':'
        value: -> parser.ignoreWhitespace()

        returns: ->
            new Parser.Result [@key, @value]

    pairParser()
        .ignoreWhitespace()
        .separatedBy(',')
        .surroundedBy('{', '}')
        .ignoreWhitespace()
        .convert (arr) ->
            table = {}
            for [key, value] in arr
                table[key] = value

            table


console.log simpleTableParser(digitsListParser()).parse("
{
    foo: (1, 3, 4),
    bar: (44, 7),
    baz: (000, 433)
}
").value




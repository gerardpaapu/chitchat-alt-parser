{Parser, OR} = require './Parser'
{stringParser} = require './stringParser'
{numberParser} = require './numberParser'
{symbolParser} = require './symbol'
{arrayParser, dictionaryParser} = require './collections'
{listParser} = require './lists'
{comment} = require './comments'
{whitespace} = require './whitespace'

comments = comment.zeroOrMore()

lazyOR = (parsers...) ->
    OR (Parser.delay f for f in parsers)...

expressionParser = ->
    lazyOR(
        stringParser,
        numberParser,
        symbolParser,
        -> arrayParser(expressionParser),
        -> dictionaryParser(expressionParser),
        -> listParser(expressionParser)
    )

expressionsParser =
    Parser.delay(expressionParser)

exports.expressionsParser = expressionsParser
exports.expressionParser = expressionParser

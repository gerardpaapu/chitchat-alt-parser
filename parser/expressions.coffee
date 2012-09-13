{Parser, OR} = require './Parser'
{stringParser} = require './stringParser'
{numberParser} = require './numberParser'
{symbolParser} = require './symbol'
{arrayParser, dictionaryParser} = require './collections'
{listParser} = require './lists'
{comment} = require './comments'
{whitespace} = require './whitespace'
_expressionParser = require('./accessors').expressionParser

comments = comment.zeroOrMore()

lazyOR = (parsers...) ->
    OR (Parser.delay f for f in parsers)...

simpleExpression = ->
    lazyOR(
        stringParser,
        numberParser,
        symbolParser,
        -> arrayParser(expressionParser()),
        -> dictionaryParser(expressionParser()),
        -> listParser(expressionParser())
    )

expressionParser = ->
    _expressionParser(simpleExpression)

expressionsParser =
    Parser.delay(expressionParser).separatedByWhitespace()

exports.expressionsParser = expressionsParser
exports.expressionParser = expressionParser

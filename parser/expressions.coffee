{Parser, OR} = require './Parser'
{stringParser} = require './stringParser'
{argumentLiteral} = require './argumentLiteral'
{numberParser} = require './numberParser'
{symbolParser} = require './symbol'
{arrayParser, dictionaryParser} = require './collections'
{argumentLiteral} = require('./argumentLiteral')
{listParser} = require './lists'
{lambda} = require('./lambda')
_expressionParser = require('./accessors').expressionParser

comment = Parser.Sequence(';', /^(.*)/).convert((a) -> a[1])
_whitespace = OR(/^(\s|,)+/, comment).zeroOrMore()


lazyOR = (parsers...) ->
    OR (Parser.delay f for f in parsers)...

simpleExpression = ->
    lazyOR(
        stringParser,
        numberParser,
        symbolParser,
        -> argumentLiteral,
        -> arrayParser(expressionParser(), _whitespace),
        -> dictionaryParser(expressionParser(), _whitespace),
        -> listParser(expressionParser(), _whitespace)
        -> lambda(expressionParser(), _whitespace)
    )

expressionParser = ->
    _expressionParser(simpleExpression)

expressionsParser =
    Parser.delay(expressionParser).separatedBy(_whitespace).ignore(_whitespace)

exports.expressionsParser = expressionsParser
exports.expressionParser = expressionParser

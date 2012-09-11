###
Complex syntax in chit-chat, (like most lisps) is expressed as
expressions in between parentheses
###

{Parser, OR} = require './Parser'
{symbolParser} = require './symbol'
{SyntaxList} = require '../common/common'

listParser = (parser) ->
    Parser.from(parser)
        .separatedByWhitespace()
        .surroundedByIW('(', ')')
        .convertTo(SyntaxList)

exports.listParser = listParser

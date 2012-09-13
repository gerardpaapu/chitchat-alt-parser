###
Complex syntax in chit-chat, (like most lisps) is expressed as
expressions in between parentheses
###

{Parser, OR} = require './Parser'
{symbolParser} = require './symbol'
{SyntaxList} = require '../common/common'

listParser = (parser, ws) ->
    Parser.from(parser)
        .separatedBy(ws)
        .surroundedByIW('(', ')', ws)
        .convertTo(SyntaxList)

exports.listParser = listParser

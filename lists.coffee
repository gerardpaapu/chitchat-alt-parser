###
Complex syntax in chit-chat, (like most lisps) is expressed as
expressions in between parentheses
###

{Parser, OR} = require './Parser'
{symbolParser} = require './symbol'

class SyntaxList
    constructor: (@items) ->

listParser = (parser) ->
    Parser.from(parser)
        .separatedByWhitespace()
        .surroundedByIW('(', ')')
        .convertTo SyntaxList

exports.SyntaxList = SyntaxList
exports.listParser = listParser
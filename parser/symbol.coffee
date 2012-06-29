{Parser} = require './Parser'
{Symbol} = require '../common/common'

symbolParser = ->
    Parser
        .from(/^[a-zA-Z\-_+=$&%@!?~`<>|][0-9a-zA-Z\-_+=$&%@!?~`<>|]*/)
        .convertTo Symbol

exports.Symbol = Symbol
exports.symbolParser = symbolParser
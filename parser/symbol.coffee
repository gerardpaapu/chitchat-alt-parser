{Parser} = require './Parser'

class Symbol
    constructor: (@value) ->

symbolParser = ->
    Parser
        .from(/^[a-zA-Z\-_+=$&%@!?~`<>|][0-9a-zA-Z\-_+=$&%@!?~`<>|]*/)
        .convertTo Symbol

exports.Symbol = Symbol
exports.symbolParser = symbolParser
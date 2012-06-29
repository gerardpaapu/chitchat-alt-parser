###

###

class SyntaxList
    constructor: (@children) ->

class AtomLiteral
    # number, string, null, undefined, true or false
    constructor: (@value) ->

class ArrayLiteral
    constructor: (@items) ->

class DictionaryLiteral
    constructor: (@table) ->

class FunctionLiteral
    constructor: (@args, @body) ->

class Symbol
    constructor: (@value) ->
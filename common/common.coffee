###
These classes are the common interface between the parser, the macros and the compiler

Broadly speaking:

    the parsers are string -> Syntax
    the macros are Syntax -> Syntax
    the compilers are Syntax -> JSEmitter
###

class Syntax 

class SyntaxList extends Syntax
    constructor: (@children) ->

class AtomLiteral extends Syntax
    # value is a number, string, null, undefined, true or false
    constructor: (@value) ->

class ArgumentLiteral extends Syntax
    constructor: (@value) ->

class ArrayLiteral extends Syntax
    # @items is an Array of Syntax
    constructor: (@items) ->

class DictionaryLiteral extends Syntax
    # @table is a dictionary of string, Syntax
    constructor: (@table) ->

class Symbol extends Syntax
    constructor: (@value) ->

module.exports =
    Syntax: Syntax
    SyntaxList: SyntaxList
    AtomLiteral: AtomLiteral
    ArgumentLiteral: ArgumentLiteral
    ArrayLiteral: ArrayLiteral
    DictionaryLiteral: DictionaryLiteral
    Symbol: Symbol
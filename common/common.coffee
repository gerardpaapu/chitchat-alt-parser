###
These classes are the common interface between the parser, the macros and the compiler

Broadly speaking:

    the parsers are string -> Syntax
    the macros are Syntax -> Syntax
    the compilers are Syntax -> JSEmitter
###

class Syntax 

class SyntaxList extends Syntax
    constructor: (@value) ->

    toJSON: -> 
        type: 'list'
        value: @value

class AtomLiteral extends Syntax
    # value is a number, string, null, undefined, true or false
    constructor: (@value) ->

    toJSON: ->
        type: 'atom'
        value: @value

class ArgumentLiteral extends Syntax
    constructor: (@value) ->

    toJSON: ->
        type: 'positional-argument'
        value: @value

class ArrayLiteral extends Syntax
    # @items is an Array of Syntax
    constructor: (@items) ->

    toJSON: ->
        type: 'array-literal'
        value: @items

class DictionaryLiteral extends Syntax
    # @table is a dictionary of string, Syntax
    constructor: (@table) ->

    toJSON: ->
        type: 'dictionary-literal'
        value: @table

class Symbol extends Syntax
    constructor: (@value) ->

    toJSON: -> 
        type: 'symbol'
        value: @value


class DotAccessor extends Syntax
    constructor: (@root, @key) ->

    toJSON: -> 
        type: 'dot-accessor'
        root: @root
        key: @key


class PrimitiveAccessor extends Syntax
    constructor: (@root, @key) ->

    toJSON: -> 
        type: 'primitive-accessor'
        root: @root
        key: @key

class PrototypeAccessor extends Syntax
    constructor: (@root, @key) ->

    toJSON: -> 
        type: 'prototype-accessor'
        root: @root
        key: @key

module.exports =
    Syntax: Syntax
    SyntaxList: SyntaxList
    AtomLiteral: AtomLiteral
    ArgumentLiteral: ArgumentLiteral
    ArrayLiteral: ArrayLiteral
    DictionaryLiteral: DictionaryLiteral
    Symbol: Symbol
    DotAccessor: DotAccessor
    PrimitiveAccessor: PrimitiveAccessor
    PrototypeAccessor: PrototypeAccessor

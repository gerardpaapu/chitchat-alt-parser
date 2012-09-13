vows = require 'vows'
assert = require 'assert'

{Parser} = require '../Parser'
{lambda} = require '../lambda'
{SyntaxList, Symbol} = require('../../common/common.coffee')
{whitespace} = require('../whitespace')

isAFunction = (stx) ->
    stx instanceof SyntaxList and
    stx.children and
    stx.children[0] instanceof Symbol and
    stx.children[0].value is 'function' and
    stx.children[1] instanceof SyntaxList and
    stx.children[1].children.every((t) -> t instanceof Symbol)

lambdaParser = lambda(Parser.from('1'), whitespace)

vows.describe('Parsing Lambdas')
    .addBatch(
        'Parsing a simple lambda':
            topic: -> lambdaParser.parse('^1 rest')

            'it succeeds': (t) -> assert.ok(t.succeeded)

            'with a function': (t) -> assert.ok(isAFunction(t.value))

        'Parsing a lambda with empty args':
            topic: -> lambdaParser.parse('^[]1 rest')

            'it succeeds': (t) -> assert.ok(t.succeeded)

            'with a function': (t) -> assert.ok(isAFunction(t.value))

        'Parsing a lambda with non-empty args':
            topic: -> lambdaParser.parse('^[a, b]1 rest')

            'it succeeds': (t) -> assert.ok(t.succeeded)

            'with a function': (t) -> assert.ok(isAFunction(t.value))
    ).export(module)
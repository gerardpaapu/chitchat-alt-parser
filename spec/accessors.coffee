vows = require 'vows'
assert = require 'assert'

{Parser} = require '../Parser'
{expressionParser} = require '../accessors'

simpleExpression = -> Parser.from '1'
complexParser = expressionParser(simpleExpression)

vows.describe('Parsing Numbers')
    .addBatch(
        'When Parsing a simple expression':
            topic: -> complexParser.parse '1 1'

        'When Parsing a simple expression':
            topic: -> complexParser.parse '1.foo 1'

        'When Parsing a simple expression':
            topic: -> complexParser.parse '1.[1] 1'

        'When Parsing a simple expression':
            topic: -> complexParser.parse '1.foo.bar 1'

        'When Parsing a simple expression':
            topic: -> complexParser.parse '1.[1.foo] 1'
    ).export(module)
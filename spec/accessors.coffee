vows = require 'vows'
assert = require 'assert'

{Parser} = require '../Parser'
{expressionParser, DotAccessor, PrimitiveAccessor, PrototypeAccessor} = require '../accessors'

simpleExpression = -> Parser.from '1'
complexParser = expressionParser(simpleExpression)

vows.describe('Parsing Numbers')
    .addBatch(
        'When Parsing a simple expression':
            topic: -> complexParser.parse '1 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) -> 
                assert.equal t.value, '1'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a dot accessor w/ symbol':
            topic: -> complexParser.parse '1.foo 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) -> 
                assert.ok t.value instanceof DotAccessor
                assert.equal t.value.root, '1'
                assert.equal t.value.key, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a dot accessor w/ expression':
            topic: -> 
                complexParser.parse '1.[1] 1'

            'Succeeds': (t) -> 
                assert.ok(t and t.succeeded)

            'With the correct value': (t) -> 
                assert.ok t.value instanceof DotAccessor
                assert.equal t.value.root, '1'
                assert.equal t.value.key, '1'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a chained dot accessor ':
            topic: -> complexParser.parse '1.foo.bar 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) -> 
                assert.ok t.value instanceof DotAccessor
                assert.equal t.value.root.root, '1'
                assert.equal t.value.root.key, 'foo'
                assert.equal t.value.key, 'bar'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest.toString(), ' 1'

        'When Parsing a dot accessor nested in a dot accessor':
            topic: -> complexParser.parse '1.[1.foo] 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) -> 
                assert.ok t.value instanceof DotAccessor
                assert.equal t.value.root, '1'
                assert.ok t.value.key instanceof DotAccessor
                assert.equal t.value.key.root, '1'
                assert.equal t.value.key.key, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        ###
        'When Parsing a primitive accessor w\\ symbol': 
            topic: -> complexParser.parse '1:foo 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) -> 
                assert.equal t.value, '1'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'
        
        'When Parsing a primitive accessor w\\ expression':
            topic: -> complexParser.parse '1:[1]'

        'When Parsing a primitive accessor w\\ expression':
            topic: -> complexParser.parse '1:foo:bar'

        'When Parsing a primitive accessor w\\ expression':
            topic: -> complexParser.parse '1:[1:foo]'

        'When Parsing a prototype accessor w\\ symbol': 
            topic: -> complexParser.parse '1::foo 1'

        'When Parsing a prototype accessor w\\ expression':
            topic: -> complexParser.parse '1::[1]'

        'When Parsing a prototype accessor w\\ expression':
            topic: -> complexParser.parse '1::foo::bar'

        'When Parsing a prototype accessor w\\ expression':
            topic: -> complexParser.parse '1::[1::foo]'
        ###
    ).export(module)
vows = require 'vows'
assert = require 'assert'

{Parser} = require '../Parser'
{expressionParser, DotAccessor, PrimitiveAccessor, PrototypeAccessor} = require '../accessors'

simpleExpression = -> Parser.from '1'
complexParser = expressionParser(simpleExpression)

vows.describe('Parsing Accessors')
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

            'With a DotAccessor': (t) ->
                assert.ok t.value instanceof DotAccessor

            'With the correct value': (t) ->
                assert.equal t.value.root, '1'
                assert.equal t.value.key.value, 'foo'

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
                assert.equal t.value.root.key.value, 'foo'
                assert.equal t.value.key.value, 'bar'

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
                assert.equal t.value.key.key.value, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'


        'When Parsing a primitive accessor w\\ symbol': 
            topic: -> complexParser.parse '1:foo 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof PrimitiveAccessor
                assert.equal t.value.root, '1'
                assert.equal t.value.key.value, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a primitive accessor w\\ expression':
            topic: -> complexParser.parse '1:[1] 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof PrimitiveAccessor
                assert.equal t.value.root, '1'
                assert.equal t.value.key, '1'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a chained primitive accessor':
            topic: -> complexParser.parse '1:foo:bar 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof PrimitiveAccessor

                simple = t.value.root
                assert.ok simple instanceof PrimitiveAccessor
                assert.equal simple.root, '1'
                assert.equal simple.key.value, 'foo'

                assert.equal t.value.key.value, 'bar'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a primitive accessor nested in a primitive accessor':
            topic: -> complexParser.parse '1:[1:foo] 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof PrimitiveAccessor
                assert.equal t.value.root, '1'

                nested = t.value.key

                assert.ok nested instanceof PrimitiveAccessor
                assert.equal nested.root, '1'
                assert.equal nested.key.value, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a prototype accessor w\\ symbol': 
            topic: -> complexParser.parse '1::foo 1'

            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof PrototypeAccessor
                assert.equal t.value.root, '1'
                assert.equal t.value.key.value, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a prototype accessor w\\ expression':
            topic: -> complexParser.parse '1::[1] 1'

            'Succeeds': (t) -> assert.ok t.succeeded
            
            'With the correct value': (t) ->
                assert.ok t.value instanceof PrototypeAccessor
                assert.equal t.value.root, '1'
                assert.equal t.value.key, '1'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a chained prototype accessor':
            topic: -> complexParser.parse '1::foo::bar 1'
        
            'With the correct value': (t) ->
                assert.ok t.value instanceof PrototypeAccessor

                simple = t.value.root
                assert.ok simple instanceof PrototypeAccessor
                assert.equal simple.root, '1'
                assert.equal simple.key.value, 'foo'

                assert.equal t.value.key.value, 'bar'

            'Succeeds': (t) -> assert.ok t.succeeded

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'

        'When Parsing a nested prototype accessor':
            topic: -> complexParser.parse '1::[1::foo] 1'
            
            'Succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof PrototypeAccessor
                assert.equal t.value.root, '1'

                nested = t.value.key

                assert.ok nested instanceof PrototypeAccessor
                assert.equal nested.root, '1'
                assert.equal nested.key.value, 'foo'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' 1'
    ).export(module)

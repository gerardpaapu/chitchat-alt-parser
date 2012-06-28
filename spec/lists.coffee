vows = require 'vows'
assert = require 'assert'

{Parser} = require '../Parser'
{listParser, SyntaxList} = require '../lists'

parseOne = Parser('1').convert((str) -> 1)

parseOneList = listParser(parseOne)

vows.describe('Parsing Syntax lists')
    .addBatch(
        'Parsing an Empty List':
            topic: -> parseOneList.parse '() rest'

            'It succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof SyntaxList
                assert.equal JSON.stringify(t.value.items), '[]'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' rest'

        'Parsing an List of ones':
            topic: -> parseOneList.parse '(1 1) rest'

            'It succeeds': (t) -> assert.ok t.succeeded

            'With the correct value': (t) ->
                assert.ok t.value instanceof SyntaxList
                assert.equal JSON.stringify(t.value.items), '[1,1]'

            'Leaving the remainder for the next parser': (t) ->
                assert.equal t.rest, ' rest'
    ).export(module)
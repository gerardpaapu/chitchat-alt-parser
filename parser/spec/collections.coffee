vows = require 'vows'
assert = require 'assert'

{arrayParser, dictionaryParser} = require '../collections'
{ArrayLiteral, DictionaryLiteral} = require('../../common/common.coffee')
{whitespace} = require('../whitespace')

vows.describe('Parsing arrays')
	.addBatch(
		'When parsing an empty Array':
			topic: -> arrayParser('1', whitespace).parse('#[] rest')

			'It succeeds': (t) ->
                assert.ok(not t.failed)

            'With an ArrayLiteral': (t) ->
                assert.ok(t.value instanceof ArrayLiteral)

			'With the correct value': (t) ->
                literal = t.value
                assert.equal(JSON.stringify(literal.items), '[]')

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'


		'When parsing a non-empty array':
			topic: -> arrayParser('1', whitespace).parse '#[1 1 1] rest'

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                literal = t.value
                assert.ok(literal instanceof ArrayLiteral)
                assert.equal(JSON.stringify(literal.items), '["1","1","1"]')

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'
	)
	.addBatch(
		'When parsing an empty dictionary':
			topic: -> dictionaryParser('1', whitespace).parse('#{} rest')

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                                literal = t.value
                                assert.ok(literal instanceof DictionaryLiteral)
                                assert.equal(JSON.stringify(literal.table), '{}')

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest.toString(), ' rest'

		'When parsing an non-empty dictionary':
			topic: -> dictionaryParser('1', whitespace).parse('#{"poop": 1 "cat": 1} rest')

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                                literal = t.value
                                assert.ok(literal instanceof DictionaryLiteral)
                                assert.equal(JSON.stringify(literal.table), '{"poop":"1","cat":"1"}')

			'Leaving the remainder for the next parser': (t) ->
                                assert.equal t.rest.toString(), ' rest'
	)
	.export(module)

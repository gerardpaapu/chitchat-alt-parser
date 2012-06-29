vows = require 'vows'
assert = require 'assert'

{arrayParser, dictionaryParser} = require '../collections'

vows.describe('Parsing arrays')
	.addBatch(
		'When parsing an empty Array':
			topic: -> arrayParser('1').parse('#[] rest')

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal JSON.stringify(t.value), '[]'

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'


		'When parsing a non-empty array':
			topic: -> arrayParser('1').parse '#[1 1 1] rest'

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal JSON.stringify(t.value), '["1","1","1"]'

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'
	)
	.addBatch(
		'When parsing an empty dictionary':
			topic: -> dictionaryParser('1').parse('#{} rest')

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal JSON.stringify(t.value), '{}'

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest.toString(), ' rest'

		'When parsing an non-empty dictionary':
			topic: -> dictionaryParser('1').parse('#{"poop": 1 "cat": 1} rest')

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal JSON.stringify(t.value), '{"poop":"1","cat":"1"}'

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest.toString(), ' rest'
	)
	.export(module)
vows = require 'vows'
assert = require 'assert'
{AtomLiteral} = require('../../common/common.coffee')

{stringParser} = require '../stringParser'

vows.describe('Parsing Strings')
	.addBatch(
		'When parsing an empty string':
			topic: -> stringParser().parse '"" rest'

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                                atom = t.value
                                assert.ok(atom instanceof AtomLiteral)
                                assert.equal(atom.value, '')

			'Leaving the remainder for the next parse': (t) ->
				assert.equal t.rest,' rest'

		'When parsing a unicode literal':
			topic: -> stringParser().parse '"\\u99ff" rest'

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                                atom = t.value
                                assert.ok(atom instanceof AtomLiteral)
                                assert.equal(atom.value, '\u99ff')

			'Leaving the remainder for the next parse': (t) ->
				assert.equal t.rest, ' rest'

		'When parsing a non-string':
			topic: -> stringParser().parse 'lolercoasters'

			'It fails': (t) -> assert.ok t.failed
	).export(module)

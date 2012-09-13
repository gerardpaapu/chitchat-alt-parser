vows = require 'vows'
assert = require 'assert'
{symbolParser} = require('../symbol.coffee')
{Symbol} = require('../../common/common.coffee')

vows.describe('Parsing Symbols')
	.addBatch(
		'When parsing `set!`':
			topic: -> symbolParser().parse 'set! rest'

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                                atom = t.value
                                assert.ok(atom instanceof Symbol)
                                assert.equal(atom.value, 'set!')

		'When parsing `ordered?`':
			topic: -> symbolParser().parse 'ordered? rest'

			'It succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
                                atom = t.value
                                assert.ok(atom instanceof Symbol)
                                assert.equal(atom.value, 'ordered?')
        ).export(module)


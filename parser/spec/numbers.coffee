vows = require 'vows'
assert = require 'assert'

{numberParser} = require '../numberParser'
{Port} = require '../Port'

vows.describe('Parsing Numbers')
	.addBatch(
		'When Parsing a binary':

			topic: -> numberParser().parse new Port('0b10101 rest')

			'Succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) -> 
				assert.equal t.value, parseInt('10101', 2)

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'

		'When Parsing an octal':

			topic: -> numberParser().parse new Port('0o777 rest')

			'Succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal t.value, parseInt('777', 8)

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'

		'When Parsing a hexadecimal':

			topic: -> numberParser().parse new Port('0xbada55 rest')

			'Succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal t.value, 0xbada55

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'

		'When Parsing a simple integer':

			topic: -> numberParser().parse new Port('8989923 rest')

			'Succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) -> 
				assert.equal t.value, 8989923

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'

		'When Parsing a float':

			topic: -> numberParser().parse new Port('04.89763 rest')

			'Succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) ->
				assert.equal t.value, parseFloat('04.89763', 10)

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'

		'When Parsing a float with Exponent':

			topic: -> numberParser().parse new Port('4.2e100 rest')

			'Succeeds': (t) -> assert.ok not t.failed

			'With the correct value': (t) -> 
				assert.equal t.value, parseFloat('4.2e100', 10)

			'Leaving the remainder for the next parser': (t) ->
				assert.equal t.rest, ' rest'

		'When parsing a non-number':
			topic: -> numberParser().parse new Port('not a number')

			'Fails': (t) -> assert.ok t.failed
	).export(module)
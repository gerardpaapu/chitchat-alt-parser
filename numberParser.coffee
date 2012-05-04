###
Parsing Numbers
-------

We allow three types of number literals

- JSON numbers
- Hexadecimal integers start with '0x' followed by 0-9 a-f (case insensitive)
- Binary integers start with '0b' followed by '0' or '1'
- Octal integers start with '0o' followed by [0-7]+
###
{Parser, OR, DO, Maybe} = require './Parser'

jsonNumberParser = ->
	Parser.Sequence(
		Maybe('-', ''),
		OR('0', /^[1-9][0-9]*/),
		Maybe(/^\.[0-9]+/, ''),
		Maybe(/^e(\+|\-)?[0-9]+/i, '')
	).convert((x) -> parseFloat(x.join(''), 10))

binaryLiteralParser = ->
	new Parser.RegExp(/^0b([0-1]+)/, 1).trace()
		.convert((x) -> parseInt(x, 2))

hexLiteral = ->
	new Parser.RegExp(/^0x([0-9a-f]+)/i, 1)
		.convert((x) -> parseInt(x, 16))

octalLiteral = ->
	new Parser.RegExp(/^0o([0-7]+)/, 1)
		.convert((x) -> parseInt(x, 8))

numberParser = ->
	OR binaryLiteralParser(), hexLiteral(), octalLiteral(), jsonNumberParser()

exports.numberParser = numberParser

# TODO: Fail on bad leading zeros '00.7', '-00', '07'
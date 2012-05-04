###
Chitchat Arrays
---------------

Chitchat arrays start with '#[' and end with ']'
and contain zero or more Chitchat expressions
separated by whitespace
###

arrayParser = (parser) ->
	parser
		.zeroOrMore()
		.separatedBy(/^\s+/m)
		.surroundedBy('#[', ']')

exports.arrayParser = arrayParser

###
Chitchat Dictionaries
---------------------

Chitchat dictionaries

- Start with '#{'
- contain key-value pairs
- Ends with '}'

A key-value pair

- starts with a string-literal
- followed by a ':'
- ends with a chitchat value
###

{stringParser} = require './stringParser'
{Sequence} = require './Parser'

associate = (pairs) ->
	# convert from [[key, value], ...] -> { key: value, ...}
	table = {}
	for [key, value] in pairs
		if table[key]?
			throw new SyntaxError("'#{key}' already defined")

		table[key] = value

dictionaryParser = (parser) ->
	separator = Parser(':').skipWhitespace()

	keyValuePair = ->
		stringParser()
			.followedBy(separator)
			.plus(parser)

	keyValuePair()
		.separatedBy(/^\s+/m)
		.ignoreWhitespace()
		.surroundedBy('#{', '}')
		.convert(associate)

exports.dictionaryParser = dictionaryParser
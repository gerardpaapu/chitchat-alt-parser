###
Chitchat Arrays
---------------

Chitchat arrays start with '#[' and end with ']'
and contain zero or more Chitchat expressions
separated by whitespace
###

{Parser} = require './Parser'
{ArrayLiteral} = require '../common/common'

arrayParser = (parser, whitespace) ->
	Parser.from(parser)
		.separatedBy(whitespace)
		.surroundedByIW('#[', ']', whitespace)
		.convertTo(ArrayLiteral)

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
{DictionaryLiteral} = require '../common/common'

associate = (pairs) ->
        # convert from [[key, value], ...] -> { key: value, ...}
        table = {}
        for [key, value] in pairs
                if table[key]?
                        throw new SyntaxError("'#{key}' already defined")

                table[key] = value

        new DictionaryLiteral(table)

dictionaryParser = (parser, whitespace) ->
	separator = Parser(':').ignore(whitespace)

	keyValuePair = ->
		stringParser()
                        .convert((token) -> token.value)
			.followedBy(separator)
			.plus(parser)

	keyValuePair()
		.separatedBy(whitespace)
		.surroundedByIW('#{', '}', whitespace)
		.convert(associate)

exports.dictionaryParser = dictionaryParser

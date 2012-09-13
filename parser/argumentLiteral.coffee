{Parser} = require './Parser'
{ArgumentLiteral} = require('../common/common')

argumentLiteral = Parser.from(/^#\d+/)
                    .convert((match) -> Number(match.slice(1)))
                    .convertTo(ArgumentLiteral)

exports.argumentLiteral = argumentLiteral
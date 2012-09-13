{Parser} = require './Parser'

whitespace = Parser.from(/^[\s,]+/m)

exports.whitespace = whitespace

# lambdas provide a concise syntax for functions
# lambda := '^' expression
#        := '^' '[' args ']' expression
{symbolParser} = require('./symbol')
{Parser, Sequence} = require('./Parser')

args = (whitespace) ->
    symbolParser()
        .separatedBy(whitespace)
        .surroundedByIW('[', ']', whitespace)

lambda = (expression, whitespace) ->
    Parser.Sequence('^', args(whitespace), expression).ignore(whitespace)

exports.lambda = lambda
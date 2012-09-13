# lambdas provide a concise syntax for functions
# lambda := '^' expression
#        := '^' '[' args ']' expression
{symbolParser} = require('./symbol')
{Parser, Sequence} = require('./Parser')
{Symbol, SyntaxList} = require('../common/common')

parseArgs = (whitespace) ->
    symbolParser()
        .separatedBy(whitespace)
        .surroundedByIW('[', ']', whitespace)
        .maybe([])

lambda = (expression, whitespace) ->
    Parser.Sequence('^', parseArgs(whitespace), expression)
        .ignore(whitespace)
        .convert((arr) ->
            [_, args, expr] = arr
            new SyntaxList([new Symbol('function'), new SyntaxList(args), expr]))

exports.lambda = lambda

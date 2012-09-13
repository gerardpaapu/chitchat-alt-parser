{expressionsParser} = require('./parser/expressions.coffee')
{readFileSync} = require('fs')

src = readFileSync('./test/orderedset.ss', 'utf8')
result = expressionsParser.parse(src)
console.log(JSON.stringify(result.value))

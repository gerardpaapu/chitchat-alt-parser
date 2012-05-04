{Parser} = require './Parser'

onesListParser =
    Parser('1').convert(Number)
        .separatedBy(',')
        .surroundedBy('(', ')')


console.log onesListParser.parse('(1,1,1,1,1)').value 
# logs [1, 1, 1, 1, 1]
Chitchat Parser (take 2)
==

The current chitchat parser is a hand-written recursive descent parser and it 
was getting a bit unweildy, especially when passing location information 
through the lexer and then the parser.

My new approach is based on [an 
article](http://common-lisp.net/~dcrampsie/smug.html) about monadic parser 
combinators in common-lisp.  

This makes it easier for me to make the parser modular, easier to read and to 
plug in location-capture in the fewest places possible.

I've also got something of a test-suite...


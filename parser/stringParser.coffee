###
Parsing a String
----------------

a JSON string is zero or more characters surrounded 
by double quotes.

characters are either:

    - unescaped (not '\' or '"')
    - escaped characters starting with '\'

escaped characters are either:

    - '\u' followed by 4 hex digits (a unicode code point)
    - '\"',  followed by a single character (from the escape table)

our strings are JSON strings except that we allow either 
single quotes or double quotes and we allow for quoting
of single quotes (i.e. we added "'" to our escape table)
###
{Parser, OR} = require './Parser'

_stringParser = (quote) ->
    backslash = '\\'

    characterParser = ->
        OR escaped(), unescaped()

    unescaped = ->
        new Parser.Item().isnt (x) -> 
            x is quote or x is backslash

    escapeTable =
        '"': '"'
        '\'': '\''
        '\\': '\\'
        '/': '/'
        'b': '\b'
        'f': '\f'
        'n': '\n'
        'r': '\r'
        't': '\t'

    unicodeSeq = ->
        Parser(['\\u', /^[a-f0-9]{4}/i])
            # discard the '\u'
            .convert((x) -> x[1])
            .convert (code) ->
                String.fromCharCode parseInt(code, 16)

    simpleEscape = ->
        Parser(['\\', new Parser.Item() ])
            # discard the leading slash
            .convert((arr) -> arr[1])

            # fail unless it is in the table
            .is((code) -> escapeTable[code]?) 
            .convert((code) -> escapeTable[code])

    escaped = ->
        OR unicodeSeq(), simpleEscape()

    characterParser()
        .zeroOrMore()
        .surroundedBy(quote, quote)
        .convert (arr) -> arr.join('')

stringParser = ->
    OR(_stringParser('\''),
       _stringParser('\"'))

exports.stringParser = stringParser
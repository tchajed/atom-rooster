class Lexer
  @StringTok = class StringTok
    constructor: (@s) ->

  @END_COMMENT = END_COMMENT = new Object()
  @SENTENCE_TERM = SENTENCE_TERM = new Object()
  @EOF = EOF = new Object()

  constructor: (@s) ->
    @pos = 0
    @commentDepth = 0

  peek: () ->
    return @s[0]

  eat: (count=1) ->
    if @s.length == 0
      return EOF
    char = @s.slice(0, count)
    @s = @s.substr(count)
    @pos += count
    return char

  lex: () ->
    char = @eat()
    if char == "\""
      close = @s.indexOf("\"")
      if close == -1
        # eat rest
        return new StringTok(@eat(@s.length))
      s = @eat(close)
      @eat()
      return new StringTok(s)
    if char == "(" and @peek() == "*"
      @eat()
      @commentDepth += 1
      while @s.length > 0 and @commentDepth > 0
        # skip to an END_COMMENT
        while (lex = @lex()) != END_COMMENT
          if lex == EOF
            return EOF
        @commentDepth -= 1
      return @lex()
    if char == "*" and @peek() == ")"
      @eat()
      return END_COMMENT
    if char == "." and @peek() != "("
      return SENTENCE_TERM
    return char

sentences = (text) ->
  lexer = new Lexer(text)
  sentences = []
  while lexer.s.length > 0
    start = lexer.pos
    continue while lexer.lex() not in [Lexer.SENTENCE_TERM, Lexer.EOF]
    stop = lexer.pos
    sentences.push {start, stop}
  return sentences

module.exports =
  # exposed for testing
  Lexer: Lexer
  sentences: sentences

# See ide/coq_lex.mll for CoqIDE implementation.
class Lexer
  @StringTok = class StringTok
    constructor: (@s) ->

  @END_COMMENT = END_COMMENT = {t: "end-comment"}
  @SENTENCE_TERM = SENTENCE_TERM = {t: "term"}
  @EOF = EOF = {t: "eof"}
  @RECURSIVE_PATTERN = RECURSIVE_PATTERN = {t: "rec"}
  # {} and bullets '-'+ '+'+ '*'+
  @NONDOT_TERM = NONDOT_TERM = {t: "nondot-term"}

  constructor: (@s) ->
    @pos = 0
    @commentDepth = 0
    @initial = true

  peek: () ->
    return @s[0]

  eat: (count=1) ->
    if @s.length == 0
      return EOF
    char = @s.slice(0, count)
    @s = @s.substr(count)
    @pos += count
    return char

  isWhitespace = (char) ->
    /\s/.test(char) or char == EOF

  lex: () ->
    char = @eat()
    initial = @initial
    if @initial and not isWhitespace char
      @initial = false
    if char == "*" and @peek() == ")"
      @eat()
      return END_COMMENT
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
    # parse only begin and end comments within comments
    if @commentDepth > 0
      return char
    if char == "\""
      close = @s.indexOf("\"")
      if close == -1
        # eat rest
        return new StringTok(@eat(@s.length))
      s = @eat(close)
      @eat()
      return new StringTok(s)
    if char == "."
      if isWhitespace @peek()
        @initial = true
        return SENTENCE_TERM
      if @peek() == "."
        @eat()
        return RECURSIVE_PATTERN
    if initial and /{|}|\+|\-|\*/.test char
      if /\+|\-|\*/.test char
        # eat entire multi-char bullet
        while @peek() == char
          s += @eat()
      return NONDOT_TERM
    return char

sentence_split = (text) ->
  lexer = new Lexer(text)
  sentences = []
  while lexer.s.length > 0
    start = lexer.pos
    continue while lexer.lex() not in [Lexer.SENTENCE_TERM,
      Lexer.NONDOT_TERM, Lexer.EOF]
    stop = lexer.pos
    sentences.push {start, stop}
  return sentences

class Sentences
  constructor: (text="") ->
    @update_text(text)

  update_text: (text) ->
    @text = text
    @sentences = sentence_split text

  boundaries: (offset) ->
    for sentence in @sentences
      if sentence.stop > offset
        return sentence
    return null

module.exports =
  # exposed for testing
  Lexer: Lexer
  Sentences: Sentences

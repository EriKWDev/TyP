
import 'package:path/path.dart';
import 'package:typ/src/errors.dart';
import 'package:typ/src/peekable_stream.dart';

const String TT_CHARACTER = "CHARACTER";
const String TT_GLUE = "TT_GLUE";
const String TT_FAKE_NEWLINE = "FAKENEWLINE";
const String TT_NEWLINE = "NEWLINE";
const String TT_MACRO  = "MACRO";
const String TT_OPEN_BRACE  = "OPEN_BRACE";
const String TT_CLOSE_BRACE  = "CLOSE_BRACE";

const String MACRO_START_IDENTIFIER = "\$";
const String OPEN_BRACE_IDENTIFIER = "{";
const String CLOSE_BRACE_IDENTIFIER = "}";
const String NEWLINE_IDENTIFIER = "\n";
const String EXACT_CHARACTER_IDENTIFIER = "\\";
const String FAKE_NEWLINE_IDENTIFIER = "\\\\";

const int MACRO_MAX_LENGTH = 50;

final RegExp glueRegExp = RegExp(r"~\s~ug");

class Position {
  String code;
  String currentCharacter;
  int index;
  int column;
  int row;

  void setCurrentCharacter() {
    currentCharacter = index < code.length
      ? code[index]
      : null;
  }

  void advance() {
    index++;
    setCurrentCharacter();
    if(currentCharacter == NEWLINE_IDENTIFIER) {
      column = 0;
      row++;
    }
  }

  Position(String code, {index: 0}) {
    setCurrentCharacter();
  }
}

class Token {
  String type;
  dynamic value;

  String toString() {
    switch(type) {
      case TT_NEWLINE:
        return "Token<${this.type}> \\n";
        break;
      default:
        return this.value != null
          ? "Token<${this.type}> ${this.value.toString()}"
          : "Token<${this.type}>";
        break;
    }
  }

  Token({this.type, this.value = null});
}

List<Token> tokenize(String code) {
  // Make linebreaks consistent
  code = code.replaceAll("\\n", NEWLINE_IDENTIFIER);
  code = code.replaceAll("\r\n", NEWLINE_IDENTIFIER);
  code = code.replaceAll("\n", NEWLINE_IDENTIFIER);

  List<Token> tokens = [];
  PeekableStream characters = PeekableStream(code.split(""));

  void tokenizeMacro() {
    String macroName = "";
    bool macroDone = false;

    while(!macroDone) {
      characters.advance();

      if(characters.current == " ") {
        // TyPLogMessage(message: "Potentially malformatted macro-name. '${characters.current}' is not permitted", peekableStream: characters);
        return characters.advance(amount: -macroName.length);
      }

      macroName += characters.current;
      macroDone = characters.next == OPEN_BRACE_IDENTIFIER;
    }

    tokens.add(Token(type: TT_MACRO, value: macroName));
  }

  while(characters.current != null) {
    switch(characters.current) {

      case EXACT_CHARACTER_IDENTIFIER:
        if(characters.next != null && characters.next != NEWLINE_IDENTIFIER) {
          tokens.add(Token(type: TT_CHARACTER, value: characters.next));
          characters.advance();
        } else {
          tokens.add(Token(type: TT_CHARACTER, value: characters.current));
        }
        break;

      case MACRO_START_IDENTIFIER:
        tokenizeMacro();
        break;

      case NEWLINE_IDENTIFIER:
        tokens.add(Token(type: TT_NEWLINE, value: characters.current));
        break;

      case OPEN_BRACE_IDENTIFIER:
        tokens.add(Token(type: TT_OPEN_BRACE, value: characters.current));
        break;

      case CLOSE_BRACE_IDENTIFIER:
        tokens.add(Token(type: TT_CLOSE_BRACE, value: characters.current));
        break;

      default:

        var glueMatch = glueRegExp.allMatches(characters.current);

        if(glueMatch.length != 0) {
          tokens.add(Token(type: TT_GLUE, value: characters.current));
        } else {
          tokens.add(Token(type: TT_CHARACTER, value: characters.current));
        }

        break;
    }

    characters.advance();
  }

  return tokens;
}
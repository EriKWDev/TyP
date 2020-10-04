
import 'package:typ/src/tokenizer.dart';

dynamic parse(String code) {
  List<Token> tokens = tokenize(code);
  for(Token token in tokens) {
    print(token);
  }
}
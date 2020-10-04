
import 'package:typ/src/peekable_stream.dart';

class TyPException {
  String message;
  PeekableStream peekableStream;

  String toString() => "Error: $message";

  TyPException({String message = "", PeekableStream peekableStream = null}) {
    if(peekableStream != null) {
      message += "\n${peekableStream.current}";
    }

    this.message = message;
  }
}
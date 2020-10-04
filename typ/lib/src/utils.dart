
class TyPLogger {
  static final TyPLogger _tyPLogger = TyPLogger._internal();

  factory TyPLogger() {
    return _tyPLogger;
  }

  void log(String message, {int level}) {
    switch(level) {
      default:
        print(message);
        break;
    }
  }

  TyPLogger._internal();
}

class PeekableStream {
    List<dynamic> iterableList;
    int _index;
    dynamic current;
    dynamic next;
    dynamic previous;

    void advance({int amount = 1}) {
      _index += amount;

      try {
        current = iterableList[_index];
      } on RangeError {
        current = null;
      }

      try {
        next = iterableList[_index + 1];
      } on RangeError {
        next = null;
      }

      try {
        previous = iterableList[_index - 1];
      } on RangeError {
        previous = null;
      }
    }

    PeekableStream(List<dynamic> iterableList, {int startIndex = 0}) {
      this.iterableList = iterableList;
      this._index = startIndex;
      advance();
    }
}
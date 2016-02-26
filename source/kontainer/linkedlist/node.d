module kontainer.linkedlist.node;

struct Node(T) {
  Node* prevNode;
  Node* nextNode;
  private T _value;

  @property T value() {
    return _value;
  }

  @property void value(T val) {
    _value = val;
  }

  alias this value;
}

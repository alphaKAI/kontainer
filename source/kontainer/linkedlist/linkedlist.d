module kontainer.linkedlist.linkedlist;
import kontainer.linkedlist.node;
import kontainer.stack;
import core.memory;

struct LinkedList(T) {
  private {
    Node!T* _firstNode;
    Node!T* _thisNode;
    Node!T* _lastNode;
    Node!T* swap;
  }

  @property Node!T* firstNode() {
    return _firstNode;
  }

  @property Node!T* thisNode() {
    return _thisNode;
  }

  @property Node!T* lastNode() {
    return _lastNode;
  }

  void append(T value) {
    Node!T* newNode = cast(Node!T*)GC.malloc(Node!T.sizeof, GC.BlkAttr.NO_SCAN | GC.BlkAttr.APPENDABLE);

    newNode.value    = value;
    newNode.nextNode = null;

    if (lastNode !is null) {
      // ALready exists some value.
      lastNode.nextNode = newNode;
      newNode.prevNode  = lastNode;
      _lastNode         = newNode;
    } else {
      _firstNode = _lastNode = _thisNode = newNode;
      newNode.prevNode = null;
      newNode.nextNode = null;
    }
  }

  void freeNode(Node!T* node) {
    if (node !is null) {
      GC.free(node);
    }
  }

  void freeAllNode() {
    Stack!(Node!T*) stack;

    foreach (node; this) {
      stack.push(node);
    }

    foreach (node; stack) {
      GC.free(node);
    }
  }

  @property size_t length() {
    size_t idx;

    foreach (_; this) {
      idx++;
    }

    return idx;
  }

  @property bool empty() {
    bool ret = thisNode is null;

    if (ret && thisNode != _firstNode) {
      _thisNode = _firstNode;
    }

    return ret;
  }

  @property Node!T* front() {
    return thisNode;
  }

  @property void popFront() {
    _thisNode = thisNode.nextNode;
  }

  bool find(T value) {
    foreach (node; this) {
      if (node.value == value) {
        return true;
      }
    }

    return false;
  }

  private {
    void thisToSwap() {   
      swap = _thisNode;
    }

    void swapToThis() {
      _thisNode = swap;
    }
  }
}


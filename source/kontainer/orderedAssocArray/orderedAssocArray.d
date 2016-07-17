module kontainer.orderedAssocArray.orderedAssocArray;

 /**
 * The associative array that an order was guaranteed.
 *
 * Why this library was necessary:
 *   D's Associative Array has a (critical) trouble:
 *     int[string] foo = [
 *       "abc"    : 123,
 *       "k"      : 3874,
 *       "abcdef" : 0];
 *    foreach (key, value; foo) {
 *      writeln("[key : value] - ", [key : value]);
 *    }
 *  Then, We(at least I) expect naturally, the above codes will output as:
 *    [key : value] - ["abc":123]
 *    [key : value] - ["k":3874]
 *    [key : value] - ["abcdef":0]
 *  However, the above codes prints:
 *    [key : value] - ["abc":123]
 *    [key : value] - ["abcdef":0]
 *    [key : value] - ["k":3874]
 *
 *  The result means that D's Associative Array doesn't guarantee to keep the order(insert order).
 *  This container guarantee to keep the order.
 *
 *
 * Simple Usage:
 *  import kontainer.orderedAssocArray;
 * 
 *  void main() {
 *    OrderedAssocArray!(string, int) oaa = new OrderedAssocArray!(string, int);
 *    oaa["abc"] = 123;
 *    oaa["k"]   = 3874;
 *    oaa["abcdef"] = 0;
 *
 *    foreach (pair; oaa) {
 *      // Access key and value with each of it as property.
 *      writeln(pair.key, " - ", pair.value);
 *    }
 *
 *    // You can modify like D's associative array
 *    oaa["abc"] = 321;
 *    oaa["k"]   = 4783;
 *    oaa["abcdef"] = 999;
 *
 *    // Free the pointer of keys
 *    oaa.free;
 *  }
 */

import std.string,
       std.conv;
import core.memory;
import kontainer.linkedlist;

struct Pair(KeyType, ValueType) {
  KeyType key;
  ValueType value;
}

class OrderedAssocArray(KeyType, ValueType) {
  LinkedList!(KeyType*) _keys;
  private ValueType[KeyType] assoc;

  this() {}

  this(ValueType[KeyType] asc) {
    foreach (key, value; asc) {
      this.add(key, value);
    }
  }

  this(typeof(this) at) {
    foreach (pair; at) {
      this.add(pair);
    }
  }

  void free() {
    foreach (node; this._keys) {
      GC.free(node.value);
    }
  }

  void add(Pair!(KeyType, ValueType) pair) {
    this.add(pair.key, pair.value);
  }

  void add(KeyType key, ValueType value) {
    KeyType* _key;

    if (key !in this.assoc) {
      _key  = cast(KeyType*)GC.malloc(key.sizeof, GC.BlkAttr.NO_SCAN);
      *_key = key;
      this._keys.append(_key);
    }

    this.assoc[key] = value;
  }

  @property typeof(this) save() {
    return new typeof(this)(this);
  }

  bool contains(KeyType key) {
    return (key in this.assoc) ? true : false;
  }

  @property KeyType[] keys() {
    KeyType[] ar;

    foreach (node; _keys) {
      ar ~= *node.value;
    }

    return ar;
  }

  @property ValueType[] values() {
    ValueType[] ar;

    foreach (node; _keys) {
      ar ~= this[*node.value];
    }

    return ar;
  }

  /* Assign Operator Overloadings */
  ValueType opIndex(KeyType key) {
    if (key in this.assoc) {
      return this.assoc[key];
    } else {
      import std.conv : to;
      if (cast(ValueType)null) {
        return null;
      } else {
        throw new Error("Nu such a key : " ~ key.to!string);
      }
    }
  }

  typeof(this) opBinary(string s)(typeof(this) that) if (s == "~") {
    typeof(this) newThis = new typeof(this)(this);

    foreach (pair; that) {
      newThis.add(pair);
    }

    return newThis;
  }

  void opIndexAssign(ValueType value, KeyType key) {
    this.add(key, value);
  }

  @property size_t length() {
    return this._keys.length;
  }

  @property bool empty() {
    return this._keys.empty;
  }

  @property Pair!(KeyType, ValueType) front() {
    KeyType key = *(this._keys.front.value);
    return Pair!(KeyType, ValueType)(key, this.assoc[key]);
  }

  @property void popFront() {
    this._keys.popFront;
  }

  @property override string toString() {
    string[] strs;

    foreach (elem; this) {
      strs ~= elem.key.to!string ~ ":" ~ elem.value.to!string;
    }

    return "[" ~ strs.join(", ") ~ "]";
  }
}

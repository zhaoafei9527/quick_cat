/// 数组工具
class ArrayUtil {
  static bool isEmpty(List array) {
    return (array.isEmpty);
  }

  static bool isNotEmpty(List array) {
    // not use array.isNotEmpty to
    return (array.isNotEmpty);
  }

  static bool indexExists<T>(List<T> list, int index) {
    return index >= 0 && index < list.length;
  }
}

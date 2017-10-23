package com.karnos.commandscript;
import java.util.ArrayList;

//import java.util.Iterator;

//not extends Collection!
//all method synchronized (because for threaded use)
public class Multiset<Type extends Comparable<Type>> implements Iterable<Type> {
  // stores sorted elements
  ArrayList<Type> list;

  public Multiset() {
    list = new ArrayList<Type>();
  }

  synchronized public void reserve(int size) {
    list.ensureCapacity(size);
  }

  synchronized public void add(Type item) {
    list.add(getBeforeIndex(item), item);
  }

  synchronized public int getBeforeIndex(Type item) {
    if (list.size() == 0) {
      return 0;
    }
    // returns place after items<=item.
    int min = 0;
    int max = list.size() - 1;
    int mid = (min + max) / 2;
    while (true) {
      int result = item.compareTo(list.get(mid));
      if (result == 0 || min >= max) {
        return changePoint(mid, item);
      } else if (result > 0) {// bigger than mid
        min = mid + 1;
        mid = (min + max) / 2;
      } else {
        max = mid - 1;
        mid = (min + max) / 2;
      }
    }
  }

  private int changePoint(int index, Type item) {
    // AA[A]CCC(->) item=B -> returns first C's index
    // AAA[C]CC(<-)
    // AAAB[B]BCCC(<-)->returns first C's index.
    // find change point near by index.
    int result = item.compareTo(list.get(index));
    if (result >= 0) {// item is bigger(->)
      while (true) {
        if (index >= list.size()) {
          return list.size();
        }
        if (item.compareTo(list.get(index)) < 0) {
          return index;
        }
        index++;
      }
    } else {
      while (true) {
        if (index < 0) {
          return 0;
        }
        result = item.compareTo(list.get(index));
        if (result >= 0) {
          return index + 1;
        }
        index--;
      }
    }
  }

  synchronized public Type get(int index) {
    return list.get(index);
  }

  synchronized public void clear() {
    list.clear();
  }

  synchronized boolean contains(Type item) {
    return list.contains(item);
  }

  @SuppressWarnings("rawtypes")
    @Override
    synchronized public boolean equals(Object other) {
    if (other instanceof Multiset) {
      Multiset set = (Multiset) other;
      if (set.size() != list.size())
        return false;
      int index = 0;
      for (Type item : list) {
        if (!item.equals(set.get(index))) {
          return false;
        }
      }
    }
    return true;
  }

  @Override
    synchronized public int hashCode() {// get from java AbstractList
    int hashCode = 1;
    for (Type e : this)
      hashCode = 31 * hashCode + (e == null ? 0 : e.hashCode());
    return hashCode;
  }

  synchronized public boolean isEmpty() {
    return list.isEmpty();
  }

  @Override
    synchronized public java.util.Iterator<Type> iterator() {
    return list.iterator();
  }

  synchronized public void remove(int index) {
    list.remove(index);
  }

  synchronized public int size() {
    return list.size();
  }

  @SuppressWarnings("unchecked")
    synchronized Type[] toArray() {
    return (Type[]) list.toArray();
  }
}

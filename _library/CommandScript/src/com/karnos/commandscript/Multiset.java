package com.karnos.commandscript;
import java.util.ArrayList;
import java.util.List;
//import java.util.Iterator;
//not extends Collection!
//all method synchronized (because for threaded use)
public class Multiset<Type extends Comparable<Type>> implements Iterable<Type> {
  // stores sorted elements
  List<Type> list;
  public Multiset() {
    list=new ArrayList<Type>();
  }
  public Multiset(List<Type> list_) {
    list=list_;
  }
  synchronized public void reserve(int size) {
    if (list instanceof ArrayList) ((ArrayList)list).ensureCapacity(size);
  }
  synchronized public void add(Type item) {
    list.add(getBeforeIndex(item), item);
  }
  synchronized public int getBeforeIndex(Type item) {
    if (list.size() == 0) {
      return 0;
    }
    // returns place after items<=item.
    int min=0;
    int max=list.size() - 1;
    int mid=(min + max) / 2;
    while (true) {
      int result=item.compareTo(list.get(mid));
      if (result == 0 || min >= max) {
        return changePoint(mid, item);
      } else if (result > 0) {// bigger than mid
        min=mid + 1;
        mid=(min + max) / 2;
      } else {
        max=mid - 1;
        mid=(min + max) / 2;
      }
    }
  }
  private int changePoint(int index, Type item) {
    // item=B
    // AA[A]CCC(->) -> returns first C's index
    // AAA[C]CC(<-)
    // AAAB[B]BCCC(<-)->returns first C's index.
    // find change point near by index.
    int result=item.compareTo(list.get(index));
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
        result=item.compareTo(list.get(index));
        if (result >= 0) {
          return index + 1;
        }
        index--;
      }
    }
  }
  synchronized public int getFirstIndex(Type item) {
    if (list.size() == 0) {
      return -1;
    }
    // returns place after items<=item.
    int min=0;
    int max=list.size() - 1;
    int mid=(min + max) / 2;
    while (true) {
      int result=item.compareTo(list.get(mid));
      if (min > max) {
        return -1;
      } else if (result > 0) {// bigger than mid
        min=mid + 1;
        mid=(min + max) / 2;
      } else if (result < 0) {
        max=mid - 1;
        mid=(min + max) / 2;
      } else {//if (result == 0) {
        while (true) {
          result=item.compareTo(list.get(mid));
          if (result < 0) {
            if (mid + 1 < list.size()) {
              return -1;
            } else {
              return mid + 1;
            }
          }
          mid--;
          if (mid < 0) {
            return 0;
          }
        }
      }
    }
  }
  synchronized public Type get(int index) {
    return list.get(index);
  }
  synchronized public void set(int index, Type item) {
    remove(index);
    add(item);
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
      Multiset set=(Multiset)other;
      if (set.size() != list.size())
        return false;
      int index=0;
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
    int hashCode=1;
    for (Type e : this)
      hashCode=31 * hashCode + (e == null ? 0 : e.hashCode());
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
    return (Type[])list.toArray();
  }
}

package com.karnos.commandscript;
public abstract class Difference<Type>{
  int index=0;
  Type before;
  Type after;
  public Difference(Type before_,Type after_){
    before=befoer_;
    after=after_;
  }
  final Difference setIndex(int index_) {
    index=index_;
    return this;
  }
  abstract void undo();
  abstract void redo();
}

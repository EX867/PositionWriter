package com.karnos.commandscript;
public abstract class Difference<Type>{
  int index=0;
  public Type before;
  public Type after;
  public Difference(Type before_,Type after_){
    before=before_;
    after=after_;
  }
  final Difference setIndex(int index_) {
    index=index_;
    return this;
  }
  public abstract void undo();
  public abstract void redo();
}

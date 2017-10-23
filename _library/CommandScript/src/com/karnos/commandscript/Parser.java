package com.karnos.commandscript;
public class Parser{
  public Multiset<LineError> errors;
  private Error cacheError;
  public Parser(){
    errors=new Multiset<LineError>();
    cacheError=new Error(Error.PRIOR,0,"","");
  }
  public void addError(Error error){
    errors.add(error);
  }
  public void removeErrors(int line){
    cacheError.line=line;
    int index=errors.getBeforeIndex(cacheError)-1;//because this returns after same values.
    while(index>=0&&index<=errors.size()&&errors.get(index).line==line){
      errors.remove(index);
    }
  }
  //>>
}

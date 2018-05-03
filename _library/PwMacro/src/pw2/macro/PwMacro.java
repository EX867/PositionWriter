package pw2.macro;
public abstract class PwMacro {//this is main class for all macro
  //preproc will change all "internal things" to all method references.
  //simply, you can use all of public things in there.
  //ex) mcToTen(10) -> __parent.mcToTen(10)
  public PwMacro() {//you must use this
  }
  public abstract void initialize(Object param);//derived class must finalize this initialize method!!! or crash.
  public void setup() {
    System.out.println(getClass().getTypeName() + " macro setup!");
  }
}

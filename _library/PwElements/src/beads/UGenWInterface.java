package beads;
import kyui.util.Task;
import pw2.beads.KnobAutomation;

import java.util.List;
public interface UGenWInterface {
  public void changeParameter(UGenW.Parameter task, Double value);
  public List<KnobAutomation> getAutomations();
  public void setGui(boolean value);
  public boolean getGui();
}

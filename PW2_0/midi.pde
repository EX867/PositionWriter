import com.karnos.midimap.MidiCommand;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.ShortMessage;
import com.karnos.midimap.InputBehavior;
void midi_setup() {
  MidiCommand.setBase(this);
  MidiCommand.addInput("press", new PadPressCommand());
  MidiCommand.addInput("release", new PadReleaseCommand());
  MidiCommand.addInput("chain", new PadChainCommand());
  MidiCommand.reloadDevices(joinPath(path_global, path_midi));
}
void midiOffAll() {//only for lp...
  int a=0;
  while (a<8) {
    int b=0;
    while (b<8) {
      MidiCommand.execute("led", 0, a, b);
      b=b+1;
    }
    a=a+1;
  }
}
public class PadPressCommand implements InputBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, int[] params) {//params[0]=x, params[1]=y
    if (msg instanceof ShortMessage) {
      ShortMessage info=(ShortMessage)msg;
      if (info.getData2()!=0) {
        if (params.length!=2)return;
        if (mainTabs_selected==LED_EDITOR) {
            action_on.accept(null, new IntVector2());
          //currentLed.printLed(params[0], params[1], true, 0);
        } else if (mainTabs_selected==KS_EDITOR) {
          //keySoundPad.triggerButton(params[0], params[1], true);
        }
      } else {
        if (mainTabs_selected==KS_EDITOR) {
          //keySoundPad.noteOff(params[0], params[1]);
        }
      }
    }
  }
}
public class PadReleaseCommand implements InputBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, int[] params) {//params[0]=x, params[1]=y
    if (mainTabs_selected==KS_EDITOR) {
      //keySoundPad.noteOff(params[0], params[1]);
    }
  }
}
public class PadChainCommand implements InputBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, int[] params) {//params[0]=x, params[1]=y
    if (mainTabs_selected==KS_EDITOR) {
      //keySoundPad.triggerChain(params[0]);
    }
  }
}
import pw2.midimap.*;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.ShortMessage;
import pw2.midimap.Device;

void midi_setup() {
  Device.setBase(this);
  Device.addInput("press", new PadPressCommand());
  Device.addInput("chain", new PadChainCommand());
  ((ImageButton)KyUI.get("set_midi")).getPressListener().onEvent(null, 0);
}
void midiOffAll(Device device) {
  for (int a=0; a<8; a++) {
    for (int b=0; b<8; b++) {
      device.output("led", 0, a, b);
    }
  }
}
void midiOffAll() {//only for lp...
  for (Device device : Device.devices) {
    if(device.name.contains("pad")){
      midiOffAll(device);
    }
  }
}
public class PadPressCommand implements InputBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, Device device, int... params) {//params[0]=x, params[1]=y
    if (msg instanceof ShortMessage) {
      ShortMessage info=(ShortMessage)msg;
      if (info.getData2()!=0) {
        if (params.length!=2)return;
        if (mainTabs_selected==LED_EDITOR) {//change these to devicelink!
          if (0<=params[0]&&params[0]<currentLedEditor.info.buttonX&&0<=params[0]&&params[1]<currentLedEditor.info.buttonY) {
            action_autoInput.accept(new IntVector2(params[0], params[1]));
          }
        } else if (mainTabs_selected==KS_EDITOR) {
          if (0<=params[0]&&params[0]<currentKs.info.buttonX&&0<=params[0]&&params[1]<currentKs.info.buttonY) {
            IntVector2 vec=new IntVector2(params[0], params[1]);
            //println("midi on : ("+vec.x+", "+vec.y+")");
            ks_pad.buttonListener.accept(vec, vec, PadButton.PRESS_L);
          }
        }
      } else {
        if (mainTabs_selected==KS_EDITOR) {
          if (0<=params[0]&&params[0]<currentKs.info.buttonX&&0<=params[0]&&params[1]<currentKs.info.buttonY) {
            IntVector2 vec=new IntVector2(params[0], params[1]);
            //println("midi off : ("+vec.x+", "+vec.y+")");
            ks_pad.buttonListener.accept(vec, vec, PadButton.RELEASE_L);
          }
        }
      }
    }
  }
}
public class PadChainCommand implements InputBehavior {
  @Override public void execute(MidiMessage msg, long timeStamp, Device device, int... params) {
    if (mainTabs_selected==KS_EDITOR) {
      if (0<=params[0]&&params[0]<currentKs.info.chain) {
        currentKs.chain=params[0];
        currentKs.resetIndex(currentKs.chain);
        currentKs.textControl();
        ((PadButton)KyUI.get("ks_chain")).selected.set(0, currentKs.chain);
        KyUI.get("ks_chain").invalidate();
        ks_pad.invalidate();
      }
    }
  }
}
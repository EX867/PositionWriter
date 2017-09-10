package net.beadsproject.beads.ugens;

import com.breakfastquay.rubberband.RubberBandStretcher;
import beads.AudioContext;
import beads.UGen;
import beads.DataBead;
import beads.DataBeadReceiver;
import java.io.IOException;
import java.util.Arrays;
import be.tarsos.util.FileUtils;

public class RubberBandProcessor extends UGen  {
  static{
  	try {
  		FileUtils.loadLibrary();
  	} catch (IOException e) {
  		e.printStackTrace();
  	}
  }
	private float pitch = 1.0f;
	private float speed = 1.0f;
  private final RubberBandStretcher rbs;
	public RubberBandProcessor(AudioContext context, int sampleRate,double initialTimeRatio, double initialPitchScale) {
		super(context);
		int options = RubberBandStretcher.OptionProcessRealTime | RubberBandStretcher.OptionWindowShort | RubberBandStretcher.OptionPitchHighQuality;
		rbs = new RubberBandStretcher(sampleRate, 1, options, initialTimeRatio, initialPitchScale);
	}
	public float getPitch() {
		return pitch;
	}
	public float getSpeed() {
		return speed;
	}
	public void setPitch(float pitch) {
		this.pitch = pitch;
		rbs.setPitchScale(pitch);
	}
	public void setSpeed(float speed) {
		this.speed = speed;
    rbs.setTimeRatio(speed);
	}
	@Override
	public void calculateBuffer() {
    rbs.process(Arrays.copyOfRange(bufIn,0,ins), false);
	  int availableSamples = rbs.available();
			while(availableSamples ==0){
				availableSamples = rbs.available();
			}
			float[][] output = new float[ins][availableSamples];
			rbs.retrieve(output);
			bufOut=output;
   }
}

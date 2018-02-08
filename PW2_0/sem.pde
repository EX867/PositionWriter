import java.util.HashMap;
import beads.AudioContext;
import beads.Bead;
import beads.Sample;
import beads.SampleManager;
import beads.SamplePlayer;
import java.util.function.Predicate;
static class MultiSamplePlayer {
  PlayerState[] players;
  AudioContext ac;
  final HashMap<Sample, SampleState> samples;
  Predicate<SampleState> onEnd;

  public MultiSamplePlayer(AudioContext ac_, int size) {
    if (size <= 0) {
      throw new RuntimeException("SamplePlayerSemaphore size must be positive.");
    }
    ac = ac_;
    players = new PlayerState[size];
    for (int a = 0; a < size; a++) {
      players[a] = new PlayerState(new SamplePlayer(ac, 2));
      players[a].player.pause(true);
      players[a].player.setKillOnEnd(false);
    }
    samples = new HashMap<Sample, SampleState>(1000);
  }

  public Sample load(String path) {
    Sample sample = SampleManager.sample(path);
    println("[sem] sample loaded : " + path + " " + (sample != null));
    samples.put(sample, new SampleState(sample));
    return sample;
  }

  public void pause(Sample sample, boolean pause) {
    if (pause) {
      pause(sample);
    } else {
      play(sample);
    }
  }

  public void play(Sample sample) {
    //unpause the sample.
    synchronized (this) {
      SampleState state = samples.get(sample);
      if (!state.active) {
        if (!state.allocated) {
          allocate(state);
          state.ref.player.setPosition(state.pausePoint);
        }
        state.active = true;
        if (!state.ref.added) {
          ac.out.addInput(state.ref.player);
          state.ref.added = true;
        }
        state.ref.player.pause(false);
        println("[sem] sample play start" + state.sample.getFileName());
      }
    }
  }

  public void pause(Sample sample) {
    //pause the sample.
    synchronized (this) {
      SampleState state = samples.get(sample);
      if (state.active) {
        //assert state.ref != null
        state.ref.player.pause(true);
        state.pausePoint = state.ref.player.getPosition();
        state.active = false;
        println("[sem] sample pause " + state.sample.getFileName());
      }
    }
  }

  public void stop(Sample sample) {
    synchronized(this) {
      SampleState state = samples.get(sample);
      if (state.active) {
        //assert state.ref != null
        state.ref.player.pause(true);
        state.pausePoint = 0;
        state.active = false;
        state.loopIndex=1;
        println("[sem] sample stop " + state.sample.getFileName());
      }
    }
  }

  public boolean isActive(Sample sample) {
    SampleState state = samples.get(sample);
    return state.active;
  }

  public void togglePause(Sample sample) {
    SampleState state = samples.get(sample);
    // (duplicated)
    synchronized (this) {
      if (state.active) {//pause
        state.ref.player.pause(true);
        state.pausePoint = state.ref.player.getPosition();
        state.active = false;
      } else {//play
        if (!state.allocated) {
          allocate(state);
          state.ref.player.setPosition(state.pausePoint);
        }
        state.active = true;
        state.ref.player.pause(false);
      }
    }
  }

  public void rewind(Sample sample) {
    SampleState state = samples.get(sample);
    if (state.allocated) {
      state.ref.player.setPosition(0);
    } else {
      state.pausePoint = 0;
    }
  }

  public void setLoopCount(Sample sample, int loopCount) {
    SampleState state = samples.get(sample);
    state.loopCount=loopCount;
  }

  void allocate(SampleState state) {
    if (!state.allocated) {
      PlayerState min = players[0];
      //check there is not allocated or inactive player
      synchronized (this) {
        for (PlayerState ps : players) {
          SamplePlayer p = ps.player;
          if (p.getSample() == null) {
            println("[sem] new sampleplayer attached.");
            attach(state, ps);
            return;
          }
          SampleState s = samples.get(p.getSample());
          if (!s.active) {
            println("[sem] inactive sampleplayer attached.");
            s.allocated = false;
            attach(state, ps);
            return;
          }
          ps.left = p.getSample().getLength() - p.getPosition();
          if (min.left > ps.left) {
            min = ps;
          }
        }
      }     //no player is available. then force min to stop playing.
      println("[sem] player is force stopped. " + min.player.getSample().getFileName());
      samples.get(min.player.getSample()).allocated = false;
      samples.get(min.player.getSample()).active = false;
      //min.player.pause(true);
      attach(state, min);
    }
  }

  void attach(SampleState state, PlayerState ps) {
    state.allocated = true;
    ps.player.setSample(state.sample);
    state.ref = ps;
    ps.player.setPosition(state.pausePoint);
  }

  class SampleState {
    Sample sample;
    double pausePoint = 0;
    boolean active = false;
    boolean allocated = false;
    int loopCount=1;
    int loopIndex=1;
    PlayerState ref;
    KsButton link;//oh I had to find that sound is assigned to what button
    public SampleState(Sample sample_) {
      sample = sample_;
    }
  }

  class PlayerState {
    SamplePlayer player;
    double left;//temp var
    boolean added = false;

    public PlayerState(SamplePlayer player_) {
      player = player_;
      player.setEndListener(new Bead() {
        public void messageReceived(Bead message) {
          SampleState sample=samples.get(player.getSample());
          if (sample.loopCount==0||sample.loopIndex<sample.loopCount) {
            player.reTrigger();
            sample.loopIndex++;//started.
          } else {
            synchronized (MultiSamplePlayer.this) {
              if (onEnd==null||onEnd.test(sample)) {
                sample.active = false;
              }
            }
            sample.loopIndex=1;
          }
        }
      }
      );
    }
  }

  public void close() {
    for (PlayerState ps : players) {
      ps.player.kill();
    }
  }
}
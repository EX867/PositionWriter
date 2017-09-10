/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"
#include "PluginProcessor.h"


//==============================================================================
/**
*/
class KeySoundPlayerAudioProcessorEditor : public AudioProcessorEditor {
public:
  KeySoundPlayerAudioProcessorEditor (KeySoundPlayerAudioProcessor&);
  ~KeySoundPlayerAudioProcessorEditor ();
  String GlobalPath;

  //==============================================================================
  void paint (Graphics&) override;
  void resized () override;

  class LoadListener : public ImageButton::Listener {
    KeySoundPlayerAudioProcessorEditor* editor;
  public:
    LoadListener (KeySoundPlayerAudioProcessorEditor* editor_);
    void buttonClicked (Button* button);
    //void buttonStateChanged (Button * button);
  };
  class ChainListener : public ImageButton::Listener {
    KeySoundPlayerAudioProcessorEditor* editor;
  public:
    int chain;
    ChainListener (KeySoundPlayerAudioProcessorEditor* editor_,int chain_);
    void buttonClicked (Button* button);
    //void buttonStateChanged (Button * button);
  };
  KeySoundPlayerAudioProcessor& processor;
  int posToIndex (int chain,int x,int y) {
    return (chain-1)*64+(x-1)*8+(y-1);
  }
  int posToMidiNote (int x,int y) {
    return 8+(x-1)+(y-1)+10;
  }
  AudioFormatManager formatManager;
private:
  // This reference is provided as a quick way for your editor to
  // access the processor object that created it.
  TextEditor input;
  Label status;
  Label chainN;
  ImageButton load;
  ImageButton chain1;
  ImageButton chain2;
  ImageButton chain3;
  ImageButton chain4;
  ImageButton chain5;
  ImageButton chain6;
  ImageButton chain7;
  ImageButton chain8;
  Label midiin;

  JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (KeySoundPlayerAudioProcessorEditor)
};

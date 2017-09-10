/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#pragma once

#include "../JuceLibraryCode/JuceHeader.h"


//==============================================================================
/**
*/
struct KSLine {
  int chain;
  int x;
  int y;
  String filename;
  void set (int chain_,int x_,int y_,String filename_) {
    chain=chain_;
    x=x_;
    y=y_;
    filename=filename_;
  }
};
class KeySoundPlayerAudioProcessor : public AudioProcessor {
public:
  //==============================================================================
  KeySoundPlayerAudioProcessor ();
  ~KeySoundPlayerAudioProcessor ();
  KSLine data[512];//MODIFY!
  //==============================================================================
  void prepareToPlay (double sampleRate,int samplesPerBlock) override;
  void releaseResources () override;

#ifndef JucePlugin_PreferredChannelConfigurations
  bool isBusesLayoutSupported (const BusesLayout& layouts) const override;
#endif

  void processBlock (AudioSampleBuffer&,MidiBuffer&) override;

  //==============================================================================
  AudioProcessorEditor* createEditor () override;
  bool hasEditor () const override;

  //==============================================================================
  const String getName () const override;

  bool acceptsMidi () const override;
  bool producesMidi () const override;
  double getTailLengthSeconds () const override;

  //==============================================================================
  int getNumPrograms () override;
  int getCurrentProgram () override;
  void setCurrentProgram (int index) override;
  const String getProgramName (int index) override;
  void changeProgramName (int index,const String& newName) override;

  //==============================================================================
  void getStateInformation (MemoryBlock& destData) override;
  void setStateInformation (const void* data,int sizeInBytes) override;

  //==============================================================================
  int chain=1;
  Synthesiser* synth;
  Synthesiser synths[8];
  void initializeSynth ();
private:
  //==============================================================================
  JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (KeySoundPlayerAudioProcessor)
};

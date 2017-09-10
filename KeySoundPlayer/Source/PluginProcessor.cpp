/*
  ==============================================================================

    This file was auto-generated!

    It contains the basic framework code for a JUCE plugin processor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"


//==============================================================================
KeySoundPlayerAudioProcessor::KeySoundPlayerAudioProcessor ()
#ifndef JucePlugin_PreferredChannelConfigurations
  : AudioProcessor (BusesProperties ()
#if ! JucePlugin_IsMidiEffect
#if ! JucePlugin_IsSynth
                    .withInput ("Input",AudioChannelSet::stereo (),true)
#endif
                    .withOutput ("Output",AudioChannelSet::stereo (),true)
#endif
  )
#endif
{
  initializeSynth ();
}

KeySoundPlayerAudioProcessor::~KeySoundPlayerAudioProcessor () {
}

//==============================================================================
const String KeySoundPlayerAudioProcessor::getName () const {
  return JucePlugin_Name;
}

bool KeySoundPlayerAudioProcessor::acceptsMidi () const {
#if JucePlugin_WantsMidiInput
  return true;
#else
  return false;
#endif
}

bool KeySoundPlayerAudioProcessor::producesMidi () const {
#if JucePlugin_ProducesMidiOutput
  return true;
#else
  return false;
#endif
}

double KeySoundPlayerAudioProcessor::getTailLengthSeconds () const {
  return 0.0;
}

int KeySoundPlayerAudioProcessor::getNumPrograms () {
  return 1;   // NB: some hosts don't cope very well if you tell them there are 0 programs,
              // so this should be at least 1, even if you're not really implementing programs.
}

int KeySoundPlayerAudioProcessor::getCurrentProgram () {
  return 0;
}

void KeySoundPlayerAudioProcessor::setCurrentProgram (int index) {
}

const String KeySoundPlayerAudioProcessor::getProgramName (int index) {
  return{};
}

void KeySoundPlayerAudioProcessor::changeProgramName (int index,const String& newName) {
}

//==============================================================================
void KeySoundPlayerAudioProcessor::prepareToPlay (double sampleRate,int samplesPerBlock) {
  // Use this method as the place to do any pre-playback
  // initialisation that you need..
}

void KeySoundPlayerAudioProcessor::releaseResources () {
  // When playback stops, you can use this as an opportunity to free up any
  // spare memory, etc.
}

#ifndef JucePlugin_PreferredChannelConfigurations
bool KeySoundPlayerAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const {
#if JucePlugin_IsMidiEffect
  ignoreUnused (layouts);
  return true;
#else
  // This is the place where you check if the layout is supported.
  // In this template code we only support mono or stereo.
  if (layouts.getMainOutputChannelSet ()!=AudioChannelSet::mono ()
   &&layouts.getMainOutputChannelSet ()!=AudioChannelSet::stereo ())
    return false;

  // This checks if the input layout matches the output layout
#if ! JucePlugin_IsSynth
  if (layouts.getMainOutputChannelSet ()!=layouts.getMainInputChannelSet ())
    return false;
#endif

  return true;
#endif
}
#endif

void KeySoundPlayerAudioProcessor::processBlock (AudioSampleBuffer& buffer,MidiBuffer& midiMessages) {
  const int totalNumInputChannels=getTotalNumInputChannels ();
  const int totalNumOutputChannels=getTotalNumOutputChannels ();
  /*
  for (int i=totalNumInputChannels; i<totalNumOutputChannels; ++i)
    buffer.clear (i,0,buffer.getNumSamples ());
  */
  /*for (int channel=0; channel<totalNumInputChannels; ++channel) {
    float* channelData=buffer.getWritePointer (channel);

  }*/
  if (synth!=nullptr) {
    synth->renderNextBlock (buffer,midiMessages,0,buffer.getNumSamples ());
  }
  /*buffer.clear ();
  MidiBuffer processedMidi;
  int time;
  MidiMessage m;
  for (MidiBuffer::Iterator i (midiMessages); i.getNextEvent (m,time);) {
    if (m.isNoteOn ()) {
      m=MidiMessage::noteOn (m.getChannel (),m.getNoteNumber (),newVel);
    } else if (m.isNoteOff ()) {
    } else if (m.isAftertouch ()) {
    } else if (m.isPitchWheel ()) {
    }

    processedMidi.addEvent (m,time);
  }
  midiMessages.swapWith (processedMidi);*/
}

//==============================================================================
bool KeySoundPlayerAudioProcessor::hasEditor () const {
  return true; // (change this to false if you choose to not supply an editor)
}

AudioProcessorEditor* KeySoundPlayerAudioProcessor::createEditor () {
  return new KeySoundPlayerAudioProcessorEditor (*this);
}

//==============================================================================
void KeySoundPlayerAudioProcessor::getStateInformation (MemoryBlock& destData) {
  // You should use this method to store your parameters in the memory block.
  // You could do that either as raw data, or use the XML or ValueTree classes
  // as intermediaries to make it easy to save and load complex data.
}

void KeySoundPlayerAudioProcessor::setStateInformation (const void* data,int sizeInBytes) {
  // You should use this method to restore your parameters from this memory block,
  // whose contents will have been created by the getStateInformation() call.
}

//==============================================================================
// This creates new instances of the plugin..
AudioProcessor* JUCE_CALLTYPE createPluginFilter () {
  return new KeySoundPlayerAudioProcessor ();
}
void KeySoundPlayerAudioProcessor::initializeSynth () {
  const int numVoices=16;

  // Add some voices...
  int a=0;
  while (a<8) {//hardcoded!!!
    synths[a].setNoteStealingEnabled (true);
    for (int i=numVoices; --i>=0;)
      synths[a].addVoice (new SamplerVoice ());
    a=a+1;
  }
}
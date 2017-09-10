/*
==============================================================================

  This file was auto-generated!

  It contains the basic framework code for a JUCE plugin editor.

==============================================================================
*/
#include <shlobj.h>
#include <iostream>
#include <fstream>
#include "PluginProcessor.h"
#include "PluginEditor.h"


//==============================================================================
KeySoundPlayerAudioProcessorEditor::KeySoundPlayerAudioProcessorEditor (KeySoundPlayerAudioProcessor& p)
  : AudioProcessorEditor (&p),processor (p) {
  // Make sure that before the constructor has finished, you've set the
  // editor's size to whatever you need it to be.
  setSize (430,300);
  // these define the parameters of our slider object
  CHAR appdata[MAX_PATH];
  SHGetFolderPath (NULL,CSIDL_LOCAL_APPDATA,NULL,SHGFP_TYPE_CURRENT,appdata);
  String path=String (std::string (appdata)+std::string ("/PositionWriter/path.txt")).replace (String ("\\"),String ("/"));
  std::ifstream inf (path.toStdString ());
  char b[512];//FIX
  inf.getline (b,512,'\n');
  GlobalPath=String (b).replace (String ("\\"),String ("/"));
  CHAR my_documents[MAX_PATH];
  SHGetFolderPath (NULL,CSIDL_PERSONAL,NULL,SHGFP_TYPE_CURRENT,my_documents);
  //input.setPopupMenuEnabled (true);
  //input.setText (String (my_documents));
  input.setText (String ("C:/Users/user/Downloads/Store_Spectre_1013"));
  status.setText (String ("not loaded"),NotificationType::dontSendNotification);
  chainN.setText (String ("1"),NotificationType::dontSendNotification);
  PNGImageFormat format=PNGImageFormat ();
  String imagePath=GlobalPath+String ("/PositionWriter_KeySoundPlayer/images/");
  Image* loadImage=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("load.png")))));
  load.setImages (false,true,false,*loadImage,1.0f,Colour (0),*loadImage,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*loadImage,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage1=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain1.png")))));
  chain1.setImages (false,true,false,*chainImage1,1.0f,Colour (0),*chainImage1,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage1,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage2=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain2.png")))));
  chain2.setImages (false,true,false,*chainImage2,1.0f,Colour (0),*chainImage2,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage2,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage3=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain3.png")))));
  chain3.setImages (false,true,false,*chainImage3,1.0f,Colour (0),*chainImage3,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage3,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage4=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain4.png")))));
  chain4.setImages (false,true,false,*chainImage4,1.0f,Colour (0),*chainImage4,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage4,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage5=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain5.png")))));
  chain5.setImages (false,true,false,*chainImage5,1.0f,Colour (0),*chainImage5,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage5,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage6=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain6.png")))));
  chain6.setImages (false,true,false,*chainImage6,1.0f,Colour (0),*chainImage6,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage6,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage7=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain7.png")))));
  chain7.setImages (false,true,false,*chainImage7,1.0f,Colour (0),*chainImage7,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage7,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  Image* chainImage8=new Image (format.decodeImage (FileInputStream (File (imagePath+String ("chain8.png")))));
  chain8.setImages (false,true,false,*chainImage8,1.0f,Colour (0),*chainImage8,1.0f,Colour (0.0f,0.0f,0.0f,0.1f),*chainImage8,1.0f,Colour (0.0f,0.0f,0.0f,0.3f));
  // this function adds the slider to the editor
  addAndMakeVisible (&input);
  addAndMakeVisible (&status);
  addAndMakeVisible (&load);
  addAndMakeVisible (&chainN);
  addAndMakeVisible (&chain1);
  addAndMakeVisible (&chain2);
  addAndMakeVisible (&chain3);
  addAndMakeVisible (&chain4);
  addAndMakeVisible (&chain5);
  addAndMakeVisible (&chain6);
  addAndMakeVisible (&chain7);
  addAndMakeVisible (&chain8);
  load.addListener (new LoadListener (this));
  chain1.addListener (new ChainListener (this,1));
  chain2.addListener (new ChainListener (this,2));
  chain3.addListener (new ChainListener (this,3));
  chain4.addListener (new ChainListener (this,4));
  chain5.addListener (new ChainListener (this,5));
  chain6.addListener (new ChainListener (this,6));
  chain7.addListener (new ChainListener (this,7));
  chain8.addListener (new ChainListener (this,8));
  formatManager.registerBasicFormats ();
}

KeySoundPlayerAudioProcessorEditor::~KeySoundPlayerAudioProcessorEditor () {
}

//==============================================================================
void KeySoundPlayerAudioProcessorEditor::paint (Graphics& g) {
  // (Our component is opaque, so we must completely fill the background with a solid colour)
  g.fillAll (getLookAndFeel ().findColour (ResizableWindow::backgroundColourId));

  g.setColour (Colours::white);
  g.setFont (15.0f);
  g.drawFittedText ("KeySound Sample Player",getLocalBounds (),Justification::top,1);
}

void KeySoundPlayerAudioProcessorEditor::resized () {
  // This is generally where you'll want to lay out the positions of any
  // subcomponents in your editor..  
  input.setBounds (40,30,getWidth ()-80,30);
  status.setBounds (40,70,270,40);
  load.setBounds (320,70,40,40);
  chainN.setBounds (370,70,20,40);
  midiin.setBounds (390,70,20,40);
  chain1.setBounds (20,150,40,40);
  chain2.setBounds (70,150,40,40);
  chain3.setBounds (120,150,40,40);
  chain4.setBounds (170,150,40,40);
  chain5.setBounds (220,150,40,40);
  chain6.setBounds (270,150,40,40);
  chain7.setBounds (320,150,40,40);
  chain8.setBounds (370,150,40,40);
}

KeySoundPlayerAudioProcessorEditor::LoadListener::LoadListener (KeySoundPlayerAudioProcessorEditor* editor_):editor (editor_) {
}
void KeySoundPlayerAudioProcessorEditor::LoadListener::buttonClicked (Button* button) {
  String soundsPath=editor->input.getText ().replace ("\\","/");
  if (soundsPath.getLastCharacter ()=='/')soundsPath=soundsPath.substring (0,soundsPath.length ()-1);
  FileInputStream* keySound=new FileInputStream (File (soundsPath+String ("/keySound")));
  WavAudioFormat wav;
  //
  File file=File (soundsPath.toStdString ()+"/error.txt");
  file.create ();
  FileOutputStream* out=new FileOutputStream (file);
  //
  std::ifstream inf=std::ifstream (soundsPath.toStdString ()+"/keySound");
  editor->status.setText (soundsPath,NotificationType::dontSendNotification);
  int a=0;
  while (a<512) {
    editor->processor.data[a].chain=0;//nothing
    a=a+1;
  }
  while (inf.is_open ()) {//read and set
    if (inf.fail ()||inf.eof ())break;
    char b[256];//FIX
    memset (b,0,sizeof (char)*256);
    inf.getline (b,256,'\n');
    // 1 2 1 1_01.wav
    int chain=0;
    int pos_x=0;
    int pos_y=0;
    char filename[20];
    memset (filename,0,sizeof (char)*20);
    sscanf (b,"%d %d %d %s",&chain,&pos_y,&pos_x,filename);
    int index=editor->posToIndex (chain,pos_x,pos_y);
    if (chain>=1&&chain<=8&&pos_x>=1&&pos_x<=8&&pos_y>=1&&pos_y<=8) {
      if (editor->processor.data[index].chain==0)editor->processor.data[editor->posToIndex (chain,pos_x,pos_y)].set (chain,pos_x,pos_y,String (filename));
      out->writeText (String ("set : ")+String (chain)+" "+String (pos_x)+" "+String (pos_y)+" "+filename+" "+String (index)+"\r\n",false,false);
    } else {
      out->writeText (String ("skipped by range : ")+String (chain)+" "+String (pos_x)+" "+String (pos_y)+" "+filename+" "+String (index)+"\r\n",false,false);
    }
  }
  soundsPath=soundsPath+String ("/sounds/");
  ScopedPointer<AudioFormat> format=editor->formatManager.findFormatForFileExtension (".wav");
  if (format!=nullptr) {
    a=0;
    while (a<512) {//load sounds
      if (1<=editor->processor.data[a].chain&&editor->processor.data[a].chain<=8) {
        File file=File (soundsPath+editor->processor.data[a].filename);
        out->writeText (String ("try to load : ")+file.getFullPathName ()+"\r\n",false,false);
        out->flush ();
        if (file.existsAsFile ()==false) {//...?
          out->writeText ("file not exists! : "+file.getFileName (),false,false);
          out->flush ();
        } else {
          AudioFormatReader* reader=editor->formatManager.createReaderFor (file);
          if (reader==nullptr) {
            int note=editor->posToMidiNote (editor->processor.data[a].x,editor->processor.data[a].y);
            editor->processor.synths[editor->processor.data[a].chain-1].addSound (new SamplerSound (String ("sampler")+String (a),*reader,BigInteger (note),note,0.0,0.0,10.0));
            out->writeText (String ("loaded : ")+file.getFullPathName ()+"\r\n",false,false);
            out->flush ();
          } else {
            out->writeText (String ("reader is null : ")+file.getFullPathName ()+format->getFormatName ()+"\r\n",false,false);
            out->flush ();
          }
        }
      } else {
        out->writeText (String ("skipped : ")+String (a)+" : "+String (editor->processor.data[a].chain)+" "+String (editor->processor.data[a].x)+" "+String (editor->processor.data[a].y)+" "+editor->processor.data[a].filename+"\r\n",false,false);
      }
      a=a+1;
    }
  } else {
    out->writeText (String ("format is null : ")+file.getFullPathName ()+" >>"+file.getFileExtension ()+"\r\n",false,false);
    out->flush ();
  }
  out->~FileOutputStream ();
  editor->status.setText (String ("loaded/"+editor->input.getText ()),NotificationType::dontSendNotification);
  editor->processor.synth=&(editor->processor.synths[0]);
  delete keySound;
}
KeySoundPlayerAudioProcessorEditor::ChainListener::ChainListener (KeySoundPlayerAudioProcessorEditor* editor_,int chain_):editor (editor_),chain (chain_) {
}
void KeySoundPlayerAudioProcessorEditor::ChainListener::buttonClicked (Button* button) {
  editor->processor.chain=chain;
  editor->processor.synth=&(editor->processor.synths[chain-1]);
  editor->chainN.setText (String (chain),NotificationType::dontSendNotification);
}
boolean readFrame(String text) {
  String[] temp=split(text, "\n");
  String[] tokens;
  int a=0;
  int Bpm=0;
  a=0;
  while (a<temp.length) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
      printError(2, a+1, current, temp[a], "[//]comment is not supported in\nunipad or unipack! this file can make errors on them.");
    } else {
      tokens=split(temp[a], " ");
      int tokensCount=tokens.length;
      if (tokens[0].equals("on") || tokens[0].equals("o")) {//==========================================================================================================================================================================o
        if (tokensCount>5 || tokensCount<4) {//few or many parameters(4 is [on y x html][on y x vel] 5 is [on y x html vel][on y x auto vel]
          printError(1, a+1, current, temp[a], "too few or many parameters");
          a++;
          continue;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(1, a+1, current, temp[a], "cannot read position.  maybe there is two spaces.");
          a++;
          continue;
        }
        if ((int(tokens[1])<=0||int(tokens[2])<=0)&&tokens[1].equals("mc")==false) {
          printError(1, a+1, current, temp[a], "button number must be greater than 0.");
          a++;           
          continue;
        }
        if (tokensCount==5) {//[on y x html vel][on y x auto vel]
          if (tokens[3].equals("auto") || tokens[3].equals("a")) {//[on y x auto vel]
            if (tokens[4].length()>3 || tokens[4].length()<=0||127<int(tokens[4])||int(tokens[4])<0) {//velocity is not correct
              printError(2, a+1, current, temp[a], "velocity is not correct");
              a++;           
              continue;
            }
            if (tokens[1].equals("mc")) {//[on mc n auto vel]
            }
          } else {//[on y x html vel]
            if (tokens[4].length()>3 || tokens[4].length()<0||127<int(tokens[4])||int(tokens[4])<=0) {//velocity is not correct
              printError(2, a+1, current, temp[a], "velocity is not correct");
              a++;           
              continue;
            }
            if (tokens[3].length()!=6||16777216<=unhex(tokens[3])||unhex(tokens[3])<0) {//html is not correct
              printError(2, a+1, current, temp[a], "html color is not correct");
              a++;           
              continue;
            }
          }
        } else if (tokensCount==4) {//[on y x html][on y x vel]
          if (tokens[3].equals("auto")||tokens[3].equals("a")) {
            printError(1, a+1, current, temp[a], "velocity number expected");
            a++;           
            continue;
          }
          if (tokens[1].equals("mc")) {//[on mc n html][on mc n vel]
            if (tokens[3].length()==6)printError(2, a+1, current, "[on mc n html] found! you cannot run this on launchpad!");
            else printError(2, a+1, current, "[on mc n vel] found. you can ignore this warning.");
            a++;           
            continue;
          }
          if (tokens[3].length()==6) {//[on y x html]
            if (tokens[3].length()!=6||16777216<=unhex(tokens[3])||unhex(tokens[3])<0) {//html is not correct
              printError(2, a+1, current, temp[a], "html color is not correct");
              a++;           
              continue;
            }
          } else {//[on y x vel]
            printError(2, a+1, current, temp[a], "[on y x vel] is not supported in\nunipad or unipack! this file can make errors on them.");
            if (tokens[3].length()>3 || tokens[3].length()<0||127<int(tokens[3])||int(tokens[3])<=0) {//velocity is not correct
              printError(2, a+1, current, temp[a], "velocity is not correct");
              a++;           
              continue;
            }
          }
        }
      } else if (tokens[0].equals("off") || tokens[0].equals("f")) {//==========================================================================================================================================================================f
        if (tokensCount!=3) {//few or many parameters([off y x])
          printError(1, a+1, current, temp[a], "too few or many arguments passed.");
          a++;           
          continue;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(1, a+1, current, temp[a], "can't read position. maybe there is two spaces.");
          a++;           
          continue;
        }
        if ((int(tokens[1])<=0||int(tokens[2])<=0)&&tokens[1].equals("mc")==false) {
          printError(1, a+1, current, temp[a], "button number must be greater than 0.");
          a++;           
          continue;
        }
        //mc range check
      } else if (tokens[0].equals("delay") || tokens[0].equals("d")) {//==========================================================================================================================================================================d
        if (tokensCount!=2) {//few or many parameters([delay t])
          printError(1, a+1, current, temp[a], "too few or many arguments passed.");
          a++;           
          continue;
        }
        if (tokens[1].length()==0) {//time is empty
          printError(1, a+1, current, temp[a], "time is empty");
          a++;           
          continue;
        }
        //bpm sync
        String[] isdivided=split(tokens[1], "/");
        if (isdivided.length==2) {
          printError(2, a+1, current, temp[a], "[delay n/n] is not supported in\nunipad or unipack! this file can make errors on them.");
          if (Bpm==0) {
            printError(2, a+1, current, temp[a], "set bpm before using bpm expression");
            a++;           
            continue;
          }
          if (isNumber(isdivided[0])==false||isNumber(isdivided[1])==false) {
            printError(2, a+1, current, temp[a], "time is not a number.");
            a++;           
            continue;
          }
          if (int(isdivided[1])==0) {
            printError(1, a+1, current, temp[a], "divided by 0!");
            a++;           
            continue;
          }
          if (int(isdivided[0])<=0||int(isdivided[1])<0) {
            printError(2, a+1, current, temp[a], "delay must be same or greater than 0");
            a++;           
            continue;
          }
          //totalFrames=totalFrames+1;
        } else if (isdivided.length==1) {
          if (int(tokens[1])<0) {//time is not correct
            printError(2, a+1, current, temp[a], "time must be same or greater than 0");
            a++;           
            continue;
          }
        } else {
          printError(0, a+1, current, temp[a], "time is not correct");
          a++;           
          continue;
        }
      } else if (tokens[0].equals("filename")) {//==========================================================================================================================================================================fn
        printError(2, a+1, current, temp[a], "[filename arguments] is not supported in\nunipad or unipack! this file can make errors on them.");
        if (tokensCount<5||tokensCount>7) {//few or many parameters([filename name<c y x l>][filename name<c y x l> convertoption][filename name<c y x l loop>][filename name<c y x l loop> convertoption])
          printError(1, a+1, current, temp[a], "too few or many arguments passed.");
          a++;           
          continue;
        }
        if (tokensCount==5) {
          if (tokens[4].equals("default")||tokens[4].equals("L-R")||tokens[4].equals("U-D")||tokens[4].equals("90-R")||tokens[4].equals("180-R")||tokens[4].equals("180-L")||tokens[4].equals("90-L")||tokens[4].equals("Y=X")||tokens[4].equals("Y=-X")) {
            printError(1, a+1, current, temp[a], "enter loop count");
            a++;           
            continue;
          }
        } else if (tokensCount==6) {
          if (tokens[5].equals("default")||tokens[5].equals("d")||tokens[5].equals("0")) {
          } else if (tokens[5].equals("L-R")||tokens[5].equals("1")) {
          } else if (tokens[5].equals("U-D")||tokens[5].equals("2")) {
          } else if (tokens[5].equals("90-R")||tokens[5].equals("3")) {
          } else if (tokens[5].equals("180-R")||tokens[5].equals("180-L")||tokens[5].equals("4")) {
          } else if (tokens[5].equals("90-L")||tokens[5].equals("5")) {
          } else if (tokens[5].equals("Y=X")||tokens[5].equals("6")) {
          } else if (tokens[5].equals("Y=-X")||tokens[5].equals("7")) {
          } else {
          }
        } else if (tokensCount==7) {
          if (tokens[6].equals("")) {
            printError(1, a+1, current, temp[a], "delete space.there is  two blanks.");
            a++;           
            continue;
          }
          if (tokens[5].equals("default")||tokens[5].equals("d")||tokens[5].equals("0")) {
          } else if (tokens[5].equals("L-R")||tokens[5].equals("1")) {
          } else if (tokens[5].equals("U-D")||tokens[5].equals("2")) {
          } else if (tokens[5].equals("90-R")||tokens[5].equals("3")) {
          } else if (tokens[5].equals("180-R")||tokens[5].equals("180-L")||tokens[5].equals("4")) {
          } else if (tokens[5].equals("90-L")||tokens[5].equals("5")) {
          } else if (tokens[5].equals("Y=X")||tokens[5].equals("6")) {
          } else if (tokens[5].equals("Y=-X")||tokens[5].equals("7")) {
          } else {
            printError(2, a+1, current, temp[a], "option incorrect");
            a++;           
            continue;
          }
        }
      } else if (tokens[0].equals("bpm")) {//==========================================================================================================================================================================d
        printError(2, a+1, current, temp[a], "[bpm arguments] is not supported in\nunipad or unipack!this file can make errors on them.");
        //[bpm s]
        if (tokensCount!=2) {
          printError(1, a+1, current, temp[a], "too few or many arguments passed.");
          a++;           
          continue;
        }
        if (tokens[1].equals("")) {
          printError(1, a+1, current, temp[a], "enter bpm");
          a++;           
          continue;
        }
        if (float(tokens[1])<=0) {
          printError(2, a+1, current, temp[a], "bpm must be greater than 0");
          a++;           
          continue;
        }
      } else {
        printError(1, a+1, current, temp[a], "unknown token \""+tokens[0]+"\"");
        a++;           
        continue;
      }
    }
    a=a+1;
  }
  if (a==temp.length)return true;
  return false;
}
boolean readFrameKS(String text) {
  String[] temp=split(text, "\n");
  String[] tokens;
  int a=0;
  while (a<temp.length) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
      printError(2, a+1, current, temp[a], "[//]comment is not supported in\nunipad or unipack! this file can make errors on them.");
      a++;
      continue;
    } else {
      tokens=split(temp[a], "\"");
      int tokensCount=tokens.length;//[c y x sound][c y x sound loop]
      if (tokensCount!=3&&tokensCount!=1) {//
        printError(1, a+1, current, temp[a], "too few or many arguments passed.");
        a++;
        continue;
      }
      if (tokensCount==3) {
        String filen=tokens[1];
        if (filen.length()==0) {
          printError(1, a+1, current, temp[a], "no filename passed.");
          a++;
          continue;
        }
        printError(2, a+1, current, temp[a], "absolute path/double quote filename is not supported in\nunipad or unipack!this file can make errors on them.");
        if (tokens[3].length()>4&&tokens[3].contains(".")) {
          if (filen.substring(filen.length()-4, filen.length()).equals(".wav")==false)printError(2, a+1, current, temp[a], "it seems this file is not\nwav file.if this is wav file, ignore this warning,");
        }
        if (tokens[2].equals("")==false) {//has loop
          String loopn=tokens[2];
          if (loopn.length()<=0) {
            printError(1, a+1, current, temp[a], "loop is incorrect. maybe there is two spaces.");
            a++;
            continue;
          }
          if (isNumber(tokens[4])==false) {
            printError(2, a+1, current, temp[a], "loop number is not a number.");
            a++;
            continue;
          }
          if (int(loopn)<=0) {
            printError(2, a+1, current, temp[a], "loop number must be same or greater than 0.");
            a++;
            continue;
          }
        }
        tokens=split(tokens[0], " ");
      } else {
        tokens=split(temp[a], " ");
        if (tokens[3].length()==0) {
          printError(1, a+1, current, temp[a], "no filename passed.");
          a++;
          continue;
        }
        if (tokens[3].length()>4&&tokens[3].contains(".")) {
          if (tokens[3].substring(tokens[3].length()-4, tokens[3].length()).equals(".wav")==false)printError(2, a+1, current, temp[a], "it seems this file is not\nwav file.if this is wav file, ignore this warning,");
        }
        if (tokens.length==5) {
          if (tokens[4].length()<=0) {
            printError(1, a+1, current, temp[a], "loop is incorrect. maybe there is two spaces.");
            a++;
            continue;
          }
          if (isNumber(tokens[4])==false) {
            printError(2, a+1, current, temp[a], "loop number is not a number.");
            a++;
            continue;
          }
          if (int(tokens[4])<=0) {
            printError(2, a+1, current, temp[a], "loop number must be same or greater than 0.");
            a++;
            continue;
          }
        }
      }
      if (tokens[0].length()==0||tokens[1].length()==0||tokens[2].length()==0) {//position is empty
        printError(2, a+1, current, temp[a], "position or chain is incorrect.");
        a++;
        continue;
      }
      if (int(tokens[0])<=0||int(tokens[1])<=0||int(tokens[2])<=0) {
        printError(2, a+1, current, temp[a], "button number must be greater than 0.");
        a++;
        continue;
      }
    }
    a=a+1;
  }
  if (a==temp.length)return true;
  return false;
}
boolean readFrameInfo(String text) {
  String[] temp=split(text, "\n");
  String[] tokens;
  //info.Title="Enter Title";
  //info.Producer="Enter Producer";
  //info.Chain=8;
  //info.ButtonX=8;
  //info.ButtonY=8;
  //info.Landscape=true;
  //info.SquareButton=true;
  int a=0;
  while (a<temp.length) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
      printError(2, a+1, current, temp[a], "[//]comment is not supported in\nunipad or unipack! this file can make errors on them.");
      a++;
      continue;
    } else {
      tokens=split(temp[a], "=");
      if (tokens.length<2) {
        printError(1, a+1, current, temp[a], "this line does not contains '='!");
        a++;
        continue;
      }
      int b=2;
      while (b<tokens.length) {
        tokens[1]=tokens[1]+"="+tokens[b];
        b=b+1;
      }
      if (tokens[0].equals("title")) {
      } else if (tokens[0].equals("producerName")) {
      } else if (tokens[0].equals("buttonX")) {
      } else if (tokens[0].equals("buttonY")) {
      } else if (tokens[0].equals("chain")) {
      } else if (tokens[0].equals("squareButton")) {
        if (tokens.length>1) {
          if (tokens[1].equals("true")||tokens[1].equals("t")||tokens[1].equals("false")||tokens[1].equals("f")) {
          } else {
            printError(2, a+1, current, temp[a], "value of squareButton is incorrect.");
            a++;
            continue;
          }
        }
      } else if (tokens[0].equals("landscape")) {
        if (tokens.length>1) {
          if (tokens[1].equals("true")||tokens[1].equals("t")) {
          } else if (tokens[1].equals("false")||tokens[1].equals("f")) {
          } else {
            printError(2, a+1, current, temp[a], "value of landscape is incorrect.");
            a++;
            continue;
          }
        }
      } else {
        printError(1, a+1, current, temp[a], "unknown token \""+tokens[0]+"\"");
        a++;
        continue;
      }
    }
    a=a+1;
  }
  if (a==temp.length)return true;
  return false;
}
boolean readFrameAP(String text) {
  String[] temp=split(text, "\n");
  String[] tokens;
  int a=0;
  int Bpm=0;
  while (a<temp.length) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
      printError(2, a+1, current, temp[a], "[//]comment is not supported in\nunipad or unipack! this file can make errors on them.");
    } else {
      tokens=split(temp[a], " ");
      int tokensCount=tokens.length;
      if (tokens[0].equals("on") || tokens[0].equals("o")||tokens[0].equals("off") || tokens[0].equals("f")) {
        if (tokensCount!=3) {
          printError(1, a+1, current, temp[a], "too few or many parameters");
          a++;
          continue;
        }
        if (tokens[1].length()==0||tokens[2].length()==0) {//position is empty
          printError(1, a+1, current, temp[a], "cannot read position. maybe there is two spaces.");
          a++;
          continue;
        }
        if ((int(tokens[1])<=0||int(tokens[2])<=0)&&tokens[1].equals("mc")==false) {
          printError(1, a+1, current, temp[a], "button number must be greater than 0.");
          a++;           
          continue;
        }
      } else if (tokens[0].equals("chain") || tokens[0].equals("c")) {
        if (tokensCount!=2) {
          printError(1, a+1, current, temp[a], "too few or many parameters");
          a++;
          continue;
        }
        if (tokens[1].length()==0) {
          printError(1, a+1, current, temp[a], "chain is empty.");
          a++;
          continue;
        }
        if (isNumber(tokens[1])==false) {
          printError(1, a+1, current, temp[a], "chain is not a number.");
          a++;
          continue;
        }
        if (8<int(tokens[1].length())||int(tokens[1].length())<=0) {
          printError(2, a+1, current, temp[a], "chain is out of range");
          a++;
          continue;
        }
      } else if (tokens[0].equals("delay") || tokens[0].equals("d")) {//==========================================================================================================================================================================d
        if (tokens.length!=2) {//few or many parameters([delay t])
          printError(1, a+1, current, temp[a], "too few or many arguments passed.");
          a++;           
          continue;
        }
        if (tokens[1].length()==0) {//time is empty
          printError(1, a+1, current, temp[a], "time is empty");
          a++;           
          continue;
        }
        //bpm sync
        String[] isdivided=split(tokens[1], "/");
        if (isdivided.length==2) {
          printError(2, a+1, current, temp[a], "[delay n/n] is not supported in\nunipad or unipack! this file can make errors on them.");
          if (Bpm==0) {
            printError(2, a+1, current, temp[a], "set bpm before using bpm expression");
            a++;           
            continue;
          }
          if (isNumber(isdivided[0])==false||isNumber(isdivided[1])==false) {
            printError(2, a+1, current, temp[a], "time is not a number.");
            a++;           
            continue;
          }
          if (int(isdivided[1])==0) {
            printError(1, a+1, current, temp[a], "divided by 0!");
            a++;           
            continue;
          }
          if (int(isdivided[0])<=0||int(isdivided[1])<0) {
            printError(2, a+1, current, temp[a], "delay must be same or greater than 0");
            a++;           
            continue;
          }
          //totalFrames=totalFrames+1;
        } else if (isdivided.length==1) {
          if (int(tokens[1])<0) {//time is not correct
            printError(2, a+1, current, temp[a], "time must be same or greater than 0");
            a++;           
            continue;
          }
        } else {
          printError(0, a+1, current, temp[a], "time is not correct");
          a++;           
          continue;
        }
      } else if (tokens[0].equals("bpm")) {//==========================================================================================================================================================================d
        printError(2, a+1, current, temp[a], "[bpm arguments] is not supported in\nunipad or unipack!this file can make errors on them.");
        //[bpm s]
        if (tokens.length!=2) {
          printError(1, a+1, current, temp[a], "too few or many arguments passed.");
          a++;           
          continue;
        }
        if (tokens[1].equals("")) {
          printError(1, a+1, current, temp[a], "enter bpm");
          a++;           
          continue;
        }
        if (float(tokens[1])<=0) {
          printError(2, a+1, current, temp[a], "bpm must be greater than 0");
          a++;           
          continue;
        }
      } else {
        printError(1, a+1, current, temp[a], "unknown token \""+tokens[0]+"\"");
        a++;
        continue;
      }
    }
    a=a+1;
  }
  if (a==temp.length)return true;
  return false;
}
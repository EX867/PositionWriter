
void getDelayPos() {
  temp=split(display.getText(), "\n");
  String[] tokens;

  int a=0;
  int totalLength=0;
  int len=temp.length;
  boolean delayCorrect=false;
  int index=0;
  while (a<len) {
    if (temp[a].length()==0) {//is empty
    } else if (temp[a].length()>=2 &&temp[a].substring(0, 2).equals("//")) {//is comment
    } else {
      tokens=split(temp[a], " ");
      int tokensCount=tokens.length;
      if (tokens[0].equals("delay") || tokens[0].equals("d")) {//==========================================================================================================================================================================d
        if (tokensCount!=2) {//few or many parameters([delay t])
          printError(a, "too few or many parameters");
          totalLength=totalLength+temp[a].length()+1;
          a=a+1;
          continue;
        }
        if (tokens[1].length()==0) {//time is empty
          printError(a, "enter time");
          totalLength=totalLength+temp[a].length()+1;
          a=a+1;
          continue;
        }
        //bpm sync
        String[] isdivided=split(tokens[1], "/");
        if (isdivided.length==2) {
          if (Bpm==0) {
            printError(a, "set bpm before using bpm expression");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          if (int(isdivided[0])==0) {
            printError(a, "delay can't be 0");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          if (int(isdivided[0])<0||int(isdivided[1])<=0) {
            printError(a, "delay is bigger than 0");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          tmpcaretPos[index]=totalLength-1;//before the delay
          index=index+1;
          tmpdelayLine[index]=a;
        } else if (isdivided.length==1) {
          if (int(tokens[1])<=0) {//time is not correct
            printError(a, "time is not correct");
            totalLength=totalLength+temp[a].length()+1;
            a=a+1;
            continue;
          }
          tmpcaretPos[index]=totalLength-1;//before the delay
          index=index+1;
          tmpdelayLine[index]=a;
        } else {
          printError(a, "time is not correct");
          totalLength=totalLength+temp[a].length()+1;
          a=a+1;
          continue;
        }
      }
    }
    totalLength=totalLength+temp[a].length()+1;
    a=a+1;
  }
  //if (a==len) {
  tmpcaretPos[index]=totalLength-1;//before the delay
  index++;
  tmpdelayLine[index]=a-1;
  //delayCorrect=true;
  copyCaretArray();
  //}
  sR=true;
  println("read completed "+str(delayCorrect));
}
//================================================================================================================================
color [] k=new color[]{
  #000000, 
  #bdbdbd, 
  #eeeeee, 
  #fafafa, //3
  #f8bbd0, 
  #ef5350, //5
  #e57373, 
  #ef9a9a, 

  #fff3e0, 
  #ffa726, 
  #ffb960, //10
  #ffcc80, 
  #ffe0b2, 
  #ffee58, 
  #fff59d, 
  #fff9c4, 

  #dcedc8, 
  #8bc34a, //17
  #aed581, 
  #bfdf9f, 
  #5ee2b0, 
  #00ce3c, 
  #00ba43, 
  #119c3f, 

  #57ecc1, 
  #00e864, 
  #00e05c, 
  #00d545, 
  #7afddd, 
  #00e4c5, 
  #00e0b2, 
  #01eec6, 

  #49efef, 
  #00e7d8, 
  #00e5d1, 
  #01efde, 
  #6addff, 
  #00dafe, 
  #01d6ff, 
  #08acdc, 

  #73cefe, 
  #0d9bf7, 
  #148de4, 
  #2a77c9, 
  #8693ff, 
  #2196f3, //45
  #4668f6, 
  #4153dc, 

  #b095ff, 
  #8453fd, 
  #634acd, 
  #5749c5, 
  #ffb7ff, 
  #e863fb, 
  #d655ed, 
  #d14fe9, 

  #fc99e3, 
  #e736c2, 
  #e52fbe, 
  #e334b6, 
  #ed353e, 
  #ffa726, //61
  #f4df0b, 
  #66bb6a, 

  #5cd100, //64
  #00d29e, 
  #2388ff, 
  #3669fd, 
  #00b4d0, 
  #475cdc, 
  #b2bbcd, 
  #95a0b2, 

  #f72737, 
  #d2ea7b, 
  #c8df10, 
  #7fe422, 
  #00c931, 
  #00d7a6, 
  #00d8fc, 
  #0b9bfc, 

  #585cf5, 
  #ac59f0, 
  #d980dc, 
  #b8814a, 
  #ff9800, 
  #abdf22, 
  #9ee154, 
  #66bb6a, //87

  #3bda47, 
  #6fdeb9, 
  #27dbda, 
  #9cc8fd, 
  #79b8f7, 
  #afafef, 
  #d580eb, 
  #f74fca, 

  #ea8a1f, 
  #dbdb08, 
  #9cd60d, 
  #f3d335, 
  #c8af41, 
  #00ca69, 
  #24d2b0, 
  #757ebe, 

  #5388db, 
  #e5c5a6, 
  #e93b3b, 
  #f9a2a1, 
  #ed9c65, 
  #e1ca72, 
  #b8da78, 
  #98d52c, 

  #626cbd, 
  #cac8a0, 
  #90d4c2, 
  #ceddfe, 
  #beccf7, 
  #a3b1be, 
  #b8c0d2, 
  #d2e2f8, 

  #fe1624, 
  #cd2724, 
  #9ccc65, //122
  #009c1b, 
  #ffff00, //124
  #beb212, 
  #f5d01d, //126
  #e37829, 
};



//================================================================================================================================
void RecordLog() {
  tR=true;
  if (UndoMax<MAX_UNDO-1) {
    UndoMax=UndoMax+1;
  }
  int i=UndoMax;
  while (i>UndoIndex) {
    Undo[i]=Undo[i-1];
    i=i-1;
  }
  i=0;
  while (i<UndoMax+1-UndoIndex) {
    Undo[i]=Undo[i+UndoIndex];
    i=i+1;
  }
  UndoMax=UndoMax-UndoIndex;
  UndoIndex=0;
  Undo[0]=display.getText();
  print("log ");
}

void WriteDisplay(String text) {
  if (inFrameInput) {
    getDelayPos();
    readFrame();
    RecordLog();
    display.setText(display.getText().substring(0, caretPos[sliderIndex])+text+display.getText().substring(caretPos[sliderIndex], display.getText().length()));
  } else {
    display.setText(display.getText()+text);
    RecordLog();
  }
}
int getLength(int c, int x, int y) {
  int a=0;
  while (a<MAX_MULTISOUND) {
    if (keySound[c][x][y][a].equals(""))break;
    a=a+1;
  }
  return a;
}


/**
 * <p>Checks whether the String a valid Java number.</p>
 *
 * <p>Valid numbers include hexadecimal marked with the <code>0x</code>
 * qualifier, scientific notation and numbers marked with a type
 * qualifier (e.g. 123L).</p>
 *
 * <p><code>Null</code> and empty String will return
 * <code>false</code>.</p>
 *
 * @param str  the <code>String</code> to check
 * @return <code>true</code> if the string is a correctly formatted number
 */
public static boolean isNumber(String str) {
  if (str.equals(""))return false;
  char[] chars = str.toCharArray();
  int sz = chars.length;
  boolean hasExp = false;
  boolean hasDecPoint = false;
  boolean allowSigns = false;
  boolean foundDigit = false;
  // deal with any possible sign up front
  int start = (chars[0] == '-') ? 1 : 0;
  if (sz > start + 1) {
    if (chars[start] == '0' && chars[start + 1] == 'x') {
      int i = start + 2;
      if (i == sz) {
        return false; // str == "0x"
      }
      // checking hex (it can't be anything else)
      for (; i < chars.length; i++) {
        if ((chars[i] < '0' || chars[i] > '9')
          && (chars[i] < 'a' || chars[i] > 'f')
          && (chars[i] < 'A' || chars[i] > 'F')) {
          return false;
        }
      }
      return true;
    }
  }
  sz--; // don't want to loop to the last char, check it afterwords
  // for type qualifiers
  int i = start;
  // loop to the next to last char or to the last char if we need another digit to
  // make a valid number (e.g. chars[0..5] = "1234E")
  while (i < sz || (i < sz + 1 && allowSigns && !foundDigit)) {
    if (chars[i] >= '0' && chars[i] <= '9') {
      foundDigit = true;
      allowSigns = false;
    } else if (chars[i] == '.') {
      if (hasDecPoint || hasExp) {
        // two decimal points or dec in exponent   
        return false;
      }
      hasDecPoint = true;
    } else if (chars[i] == 'e' || chars[i] == 'E') {
      // we've already taken care of hex.
      if (hasExp) {
        // two E's
        return false;
      }
      if (!foundDigit) {
        return false;
      }
      hasExp = true;
      allowSigns = true;
    } else if (chars[i] == '+' || chars[i] == '-') {
      if (!allowSigns) {
        return false;
      }
      allowSigns = false;
      foundDigit = false; // we need a digit after the E
    } else {
      return false;
    }
    i++;
  }
  if (i < chars.length) {
    if (chars[i] >= '0' && chars[i] <= '9') {
      // no type qualifier, OK
      return true;
    }
    if (chars[i] == 'e' || chars[i] == 'E') {
      // can't have an E at the last byte
      return false;
    }
    if (chars[i] == '.') {
      if (hasDecPoint || hasExp) {
        // two decimal points or dec in exponent
        return false;
      }
      // single trailing decimal point after non-exponent is ok
      return foundDigit;
    }
    if (!allowSigns
      && (chars[i] == 'd'
      || chars[i] == 'D'
      || chars[i] == 'f'
      || chars[i] == 'F')) {
      return foundDigit;
    }
    if (chars[i] == 'l'
      || chars[i] == 'L') {
      // not allowing L with an exponent
      return foundDigit && !hasExp;
    }
    // last character is illegal
    return false;
  }
  // allowSigns is true iff the val ends in 'E'
  // found digit it to make sure weird stuff like '.' and '1E-' doesn't pass
  return !allowSigns && foundDigit;
}

void deleteLine(int line) {
  int a=0;
  String[] lines=split(display.getText(), "\n");
  String ret="";
  while (a<lines.length) {
    if (a!=line) {
      ret=ret+lines[a]+"\n";
    }
    a=a+1;
  }
  SelectedFile2=-1;
  if (lines.length>0)ret=ret.substring(0, ret.length()-1);
  display.setText(ret);
  RecordLog();
}

void replaceLine(int line, String in) {
  int a=0;
  String[] lines=split(display.getText(), "\n");
  String ret="";
  while (a<lines.length) {
    if (a!=line) {
      ret=ret+lines[a]+"\n";
    } else {
      ret=ret+in+"\n";
    }
    a=a+1;
  }
  SelectedFile2=-1;
  if (lines.length>0)ret=ret.substring(0, ret.length()-1);
  display.setText(ret);
  RecordLog();
}
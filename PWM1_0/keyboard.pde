int keyboardButtons=44;
int keyX;
int keyY;
int keyWidth;
int keyHeight;
String keyText[];
int keyInitX[];
int keyInitY [];
int keyWidths[];
boolean keyboardType []=new boolean [50];

boolean keyboardOn=true;

boolean isShifted=false;
void initKeyConstants() {
  keyX=0;
  keyY=Screen_Height-KEY_HEIGHT;
  keyWidth=(Screen_Width_FULL/10)/2;//width is calculated with half of keywidth
  keyHeight=KEY_HEIGHT/5;
  keyText=new String [] {
    //layout 3
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", 
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", 
    "a", "s", "d", "f", "g", "h", "j", "k", "l", 
    "SHIFT", "z", "x", "c", "v", "b", "n", "m", "<<", 
    "< >", "_", "#", "SPACE", "/", "\\n", 
    //layout 4
    "1","2","3","4","5","6","7","8","9","0",
    "+","-","*","=","%","$","{","}","[","]",
    "!","@","~","&","|","<",">","(",")",
    "SHIFT","^","'","\"",":",";",",","?","<<",
    "< >",".","#","SPACE","/","\\n",
  };
  keyWidths=new int [] {
    //layout 3
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
    2, 2, 2, 2, 2, 2, 2, 2, 2, 
    3, 2, 2, 2, 2, 2, 2, 2, 3, 
    3, 2, 2, 8, 2, 3,
  };
  keyInitX =new int [] {
    //layout 3
    0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 
    0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 
    1, 3, 5, 7, 9, 11, 13, 15, 17, 
    0, 3, 5, 7, 9, 11, 13, 15, 17, 
    0, 3, 5, 7, 15, 17,
  };
  keyInitY =new int [] {
    //layout 3
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    2, 2, 2, 2, 2, 2, 2, 2, 2, 
    3, 3, 3, 3, 3, 3, 3, 3, 3, 
    4, 4, 4, 4, 4, 4,
  };
}

void initKeyboardButton (){
  btns [NofButtons+29].layout=4;
  btns [NofButtons+37].layout=4;
  btns [NofButtons+38].layout=4;
  btns [NofButtons+39].layout=4;
  btns [NofButtons+40].layout=4;
  btns [NofButtons+41].layout=4;
  btns [NofButtons+42].layout=4;
  btns [NofButtons+43].layout=4;
  
}

int keyLayout=1;
/*
1=normal
 2=(shift)uppercase
 3=special char1
 4=(shift)special char2
 5=
 */
void keyboardRelease(){
  int a=0;
  int keyIndex;
  String toWrite="";

  while (a<keyboardButtons) {
    keyIndex=a+NofButtons;
    if ((keyLayout==1||keyLayout==2||keyLayout==3)&&(btns[keyIndex].layout==3||btns [keyIndex].layout==4)) {//====================================NORMAL
      if (btns [keyIndex].isTouched()==false&&keyboardType[a]==true) {
        //print(btns [keyIndex].text);
        if (btns[keyIndex].text.equals ("SHIFT")) {
          if (keyLayout==1){
            int c=0;
            while (c <37){
              if (c!=29){
                btns [NofButtons+c].text=btns [NofButtons+c].text.toUpperCase();
              }
              c=c+1;
            }
            keyLayout=2;
            btns [keyIndex].colorEnabled=color (155);
          }else if(keyLayout==2) {
            int c=0;
            while (c <37){
              if (c!=29){
                btns [NofButtons+c].text=btns [NofButtons+c].text.toLowerCase ();
              }
              c=c+1;
            }
            keyLayout=1;
            btns [keyIndex].colorEnabled=color(255);
          }
        } else if (btns [keyIndex].text.equals ("<<")) {
          if (display.Cursur >1) {
            toWrite=display.getText().substring (0, display.Cursur-1)+display.getText().substring (display.Cursur,display.getText().length ());
          display.setText(toWrite);
          display.Cursur=display.Cursur-1;
          } else if (display.Cursur==1) {
            toWrite=(display.getText().substring (1, display.getText().length ()));
          display.setText(toWrite);
          display.Cursur=display.Cursur-1;
          } else {//do nothing
          }
        } else if (btns [keyIndex].text.equals ("< >")) {
          if (keyLayout==1 ||keyLayout ==2){
            keyLayout=3;
            int c=0;
            while (c <keyboardButtons ){
              btns [NofButtons+c].text=keyText [keyboardButtons+c];
              c=c+1;
            }
            btns [NofButtons+29].colorEnabled=color (255);
            
          }else {
            keyLayout=1;
            int c=0;
            while (c <keyboardButtons ){
              btns [NofButtons+c].text=keyText [c];
              c=c+1;
            }
          }
        } else if (btns [keyIndex].text.equals ("SPACE")) {
          if (display.Cursur >0) {
            toWrite=display.getText().substring (0, display.Cursur)+" "+display.getText().substring (display.Cursur, display.getText().length ());
          } else {
            toWrite=" "+display.getText().substring (display.Cursur, display.getText().length ());
          }
          display.Cursur=display.Cursur+1;
          display.setText(toWrite);
        } else if (btns [keyIndex].text.equals ("\\n")) {
          if (display.Cursur >0) {
            toWrite=display.getText().substring (0, display.Cursur)+"\n"+display.getText().substring (display.Cursur, display.getText().length ());
          } else {
            toWrite="\n"+display.getText().substring (0, display.getText().length ());
          }
          display.Cursur=display.Cursur+1;
          display.setText(toWrite);
        } else {
          if (keyLayout ==1){
          if (display.Cursur >0) {
            toWrite=display.getText().substring (0, display.Cursur)+(btns [keyIndex].text)+display.getText().substring (display.Cursur, display.getText().length ());
          } else {
            toWrite=(btns [keyIndex].text)+display.getText().substring (display.Cursur, display.getText().length ());
          }
          }else {
            
          if (display.Cursur >0) {
            toWrite=display.getText().substring (0, display.Cursur)+(btns [keyIndex].text.toUpperCase())+display.getText().substring (display.Cursur, display.getText().length ());
          } else {
            toWrite=(btns [keyIndex].text.toUpperCase ())+display.getText().substring (display.Cursur, display.getText().length ());
          }
          keyLayout=1;
          btns [NofButtons+29].colorEnabled=color (255);
            int c=0;
            while (c <37){
              if (c!=29){
                btns [NofButtons+c].text=btns [NofButtons+c].text.toLowerCase ();
              }
              c=c+1;
            }
          }
          display.Cursur=display.Cursur+1;
          display.setText(toWrite);
          sR=true;
        }
        keyboardType [a]=false;
      }
    } else if ((keyLayout==3||keyLayout==4)&&(btns [keyIndex].layout==5)) {//===============================UPPERCASE
    }
    a=a+1;
  }
  
}

void keyboardButtons() {
  int a=0;
  int keyIndex;
  while (a<keyboardButtons) {
    keyIndex=a+NofButtons;
    if ((keyLayout==1||keyLayout==2||keyLayout ==3)&&(btns[keyIndex].layout==3||btns [keyIndex].layout==4)) {//====================================NORMAL
      if (btns [keyIndex].isTouched()){//&&keyboardType[a]==false) {
        //print(btns [keyIndex].text);
        if (btns[keyIndex].text.equals ("SHIFT")) {
        } else if (btns [keyIndex].text.equals ("<<")) {
        } else if (btns [keyIndex].text.equals ("< >")) {
          
        } else if (btns [keyIndex].text.equals ("SPACE")) {
        } else if (btns [keyIndex].text.equals ("\\n")) {
        } else {
          fill(255);
          rect (btns [keyIndex].x-keyWidth+20*displayD,btns [keyIndex].y-keyHeight*2+20*displayD,keyWidth*4-40*displayD,2*keyHeight-40*displayD);
          textSize (80*displayD);
          fill (0);
          text (btns [keyIndex].text,btns [keyIndex].x+10*displayD,btns [keyIndex].y-keyHeight+20*displayD);
        }
        keyboardType [a]=true;
      }
    } else if (keyLayout==2&&btns [keyIndex].layout==2) {//===============================UPPERCASE
    }
    a=a+1;
  }
}
import java.awt.*;
import java.awt.event.AdjustmentListener;
import java.awt.event.AdjustmentEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowStateListener;
import java.awt.event.ActionEvent;
import java.awt.event.WindowEvent;
import javax.swing.*;
import javax.swing.border.*;
import javax.swing.event.*;
import javax.swing.text.*;

JTextArea display;
JScrollPane scroll;
JFrame tframe;

JFrame findReplace;
JTextArea find;
JTextArea replace;

JFrame help;
JLabel label;

Font font12 = new Font("arial", Font.PLAIN, 12);
Font font15 = new Font("Gulim", Font.BOLD, 15);
Font font20 = new Font("Gulim", Font.BOLD, 20);
Font font25 = new Font("Gulim", Font.BOLD, 25);

int JF_cursor;
void createFindReplace() {
  if (findReplace.isVisible()) findReplace.setVisible(false);
  else findReplace.setVisible(true);
  JF_cursor=0;
}
void createDisplay() {
  if (tframe.isVisible()) tframe.setVisible(false);
  else tframe.setVisible(true);
}
void createHelp() {
  if (help.isVisible()) help.setVisible(false);
  else help.setVisible(true);
}
void configureTextEditor() {
  //http://stackoverflow.com/questions/10177183/java-add-scroll-into-text-area
  JPanel middlePanel = new JPanel ();
  middlePanel.setBorder ( new TitledBorder ( new EtchedBorder (), "PositionWriter.Editor" ) );

  display = new JTextArea( floor(45*scale), floor(40*scale) );
  display.setEditable ( true ); // set textArea editable

  scroll = new JScrollPane ( display );
  scroll.setVerticalScrollBarPolicy ( ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS );
  scroll.getVerticalScrollBar().addAdjustmentListener(new AdjustmentListener() {
    public void adjustmentValueChanged(AdjustmentEvent e) {
      JScrollBar src = (JScrollBar) e.getSource();
      if (tframe.isFocused()==false) {
        src.setValue(src.getMaximum());
      }
    }
  }
  );

  display.setFont(font15);


  //Add Textarea in to middle panel
  middlePanel.add ( scroll );
  // My code
  tframe = new JFrame ();
  tframe.add ( middlePanel );
  tframe.pack ();
  //tframe.setLocationRelativeTo ( null );
  tframe.setLocation(20, 20);
  tframe.setResizable(false);
  tframe.setName("PositionWriter");
  tframe.setVisible ( true );
  //======
  display.setText("//===EX867_Position_Writer===//");  
  display.setSize(floor(400*scale), floor(1000*scale));
  LogFull=display.getText();
}

void configureFindReplace() {
  find=new JTextArea(1, 15);
  JTextArea findText=new JTextArea(1, 8);
  replace=new JTextArea(1, 15);
  JTextArea replaceText=new JTextArea(1, 8);
  JButton findBtn=new JButton("FIND");
  JButton replaceBtn= new JButton("REPLACE");

  find.setEditable(true);
  findText.setEditable(false);
  replace.setEditable(true);
  replaceText.setEditable(false);

  find.setFont(font15);
  findText.setFont(font15);
  replace.setFont(font15);
  replaceText.setFont(font15);
  findText.setBackground(Color.LIGHT_GRAY);
  replaceText.setBackground(Color.LIGHT_GRAY);

  findReplace=new JFrame();
  findReplace.setLayout(new FlowLayout());
  findReplace.add(findText);
  findReplace.add(find);
  findReplace.add(replaceText);
  findReplace.add(replace);
  findReplace.add(findBtn);
  findReplace.add(replaceBtn);
  findReplace.setTitle("PositionWriter");
  findReplace.pack();
  findReplace.setLocation(400, 400);
  findReplace.setSize(300, 120);
  findReplace.setResizable(false);
  findReplace.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);
  findText.setText("find here");
  replaceText.setText("replace here");
  findReplace.setVisible(false);

  JF_cursor=0;
  ActionListener findListener=new ActionListener() {
    @Override
      public void actionPerformed(ActionEvent ev) {
      //http://stackoverflow.com/questions/13437865/java-scroll-to-specific-text-inside-jtextarea/13438455#13438455

      if (Language==LC_ENG) Log=JF_ENG_NEXTFIND+find.getText();
      else Log=JF_KOR_NEXTFIND+find.getText();
      print(Log+" : ");

      if (find.getText() != null && find.getText().length() > 0) {

        int findLength = find.getText().length();
        if (JF_cursor + findLength > display.getText().length()) {
          JF_cursor = 0;
        }
        //JF_cursor=kmp(display.getText().substring(JF_cursor, display.getText().length()-JF_cursor), find.getText());

        boolean found = JF_nextFind(JF_cursor, findLength);
        if (found) {//JF_cursor!=-1) {
          Log="result found";
          try {
            Rectangle viewRect = display.modelToView(JF_cursor);
            display.scrollRectToVisible(viewRect);
          }
          catch(Exception e) {
          }
          display.setCaretPosition(JF_cursor + findLength);
          display.moveCaretPosition(JF_cursor);
          JF_cursor += findLength;
        } else Log="no result found";
      }
      display.requestFocusInWindow();
    }
  };
  ActionListener replaceListener=new ActionListener() {
    @Override
      public void actionPerformed(ActionEvent e) {
      if (find.getText()!=null&&find.getText().length()>0) {
        String tmLogFull=display.getText();
        if (Language==LC_ENG) Log="replace "+find.getText()+" with "+replace.getText();
        else Log=find.getText()+"\uB97C"+replace.getText()+"\uB85C \uBC14\uAFB8\uAE30 ";
        println(Log);
        LogFull="";

        String[] tmLogSplit=split(tmLogFull, find.getText());
        int a=0;
        LogFull=tmLogSplit[0];
        while (a+1<tmLogSplit.length) {
          a=a+1;
          LogFull=LogFull+replace.getText()+tmLogSplit[a];
        }
        tR=true;
        RecordLog();
        display.setText(LogFull);
      }
    }
  };
  findBtn.addActionListener(findListener);
  replaceBtn.addActionListener(replaceListener);
  //FocusListener ws=new FocusListener();
  //tframe.addWindowStateListener(ws);
}
//class FocusListener implements WindowStateListener {
//  @Override
//    public void windowGainedFocus(WindowEvent e) {
//    println(e.getNewState()+" "+WindowEvent.WINDOW_GAINED_FOCUS);
//    textFocused=true;
//  }
//  @Override
//    public void windowLostFocus(WindowEvent e) {
//    println(e.getNewState()+" "+WindowEvent.WINDOW_GAINED_FOCUS);
//    textFocused=false;
//  }
//  @Override
//    public void windowStateChanged(WindowEvent e) {
//    if (e.getNewState() == WindowEvent.WINDOW_GAINED_FOCUS) {
//    } else if (e.getNewState() == WindowEvent.WINDOW_LOST_FOCUS) {
//    }
//  }
//}
//http://docs.oracle.com/javase/1.5.0/docs/api/java/awt/event/WindowEvent.html
boolean textFocused=true;
void configureHelp() {
  help=new JFrame();
  help.setTitle("Shortcuts");
  label=new JLabel("<html><shortcuts><br>"+ON+" : change line and print \"on\"<br>"+OFF+" : change line and print \"off\"<br>"+DELAY+" : change line and print \"delay\"<br>"+AUTO+" : print space and \"auto\"<br>"+FILENAME+" : change line and print \"filename\"<br>"+BPM+" : change line and print \"bpm\"<br>ENTER : change line<br>BACKSPACE : erase one character<br>CTRL+R : screen refresh<br>CTRL+D : open text editor<br>CTRL+F : open find replace window<br>SHIFT+number : print number<br>CTRL+number(1~6) : print recent used html color<br>ALT+RGB slider : slider fine tuning<br>CTRL+e : export to text<br>CTRL+z : undo<br>CTRL+y : redo<br><,> : previous frame,next frame<br>[]{}(AutoInput only) : move selected color<br>/ : print /(next to '/' shift+number will print no space.)<br>SPACE : led preview<br>p or P : stop led preview<html>");
  help.add(label);
  label.setLocation(0, 0);//?
  label.setHorizontalAlignment(JLabel.CENTER);
  label.setFont(font12);
  help.setSize(floor(320*scale), floor(420*scale));
  help.setVisible(false);
}

boolean JF_nextFind(int start, /* temp */ int findLength) {
  boolean found=false;
  Document document = display.getDocument();//temp
  try {
    //
    while (start + findLength <= display.getText().length()) {
      if (document.getText(start, findLength).equals(find.getText())) {
        found = true;
        break;
      }
      start++;
    }
    //
  }
  catch (Exception exp) {
    exp.printStackTrace();
  }
  JF_cursor=start;
  return found;
}

//KMP algorithm==========
//http://bowbowbow.tistory.com/6
//int[] pi;
//void getPi(String in) {
//  int len=in.length();
//  pi=new int[len+1];
//  int a=1;
//  pi[0]=-1;
//  while (a<=len) {
//    //string is 1 less on index
//    int b=pi[a-1];
//    while (true) {
//      if (b==-1) {
//        pi[a]=0;
//        break;
//      } else if (in.charAt(b)==in.charAt(a-1)) {
//        pi[a]=b+1;
//        break;
//      } else b=pi[b];
//    }
//    a=a+1;
//  }
//}
//int kmp(String s, String p) {
//  int ans=-1;//if find first one, break!
//  getPi(p);
//  int n =s.length(), m = p.length(), j =0;
//  for (int i = 0; i < n; i++) {
//    while (j>0 && s.charAt(i) != p.charAt(j))
//      j = pi[j];
//    if (s.charAt(i) == p.charAt(j)) {
//      if (j==m-1) {
//        ans=i-m+1;
//        j = pi[j+1];
//        break;
//      } else {
//        j++;
//      }
//    }
//  }
//  return ans;
//}
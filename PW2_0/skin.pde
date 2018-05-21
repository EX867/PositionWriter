class SkinEditView extends Element {
  //test
  PImage back=loadImage("skinback.png");
  boolean play=true;
  TextBox packageEdit;
  TextBox titleEdit;
  TextBox authorEdit;
  TextBox descriptionEdit;
  TextBox appnameEdit;
  Button textColorEdit;
  ImageDrop skin_background;
  ImageDrop skin_btn;
  ImageDrop skin_btnPressed;
  ImageDrop skin_cover;
  ImageDrop skin_coverMiddle;
  ImageDrop skin_chain;
  ImageDrop skin_chainSelected;
  ImageDrop skin_chainNext;
  ImageDrop skin_chainCover;
  ImageDrop skin_play;
  ImageDrop skin_playPressed;
  ImageDrop skin_pause;
  ImageDrop skin_pausePressed;
  ImageDrop skin_prev;
  ImageDrop skin_prevPressed;
  ImageDrop skin_next;
  ImageDrop skin_nextPressed;
  ImageDrop skin_themeIcon;
  ImageDrop skin_appIcon;
  TextBox skin_package;
  TextBox skin_version;
  TextBox skin_title;
  TextBox skin_author;
  TextBox skin_description;
  TextBox skin_appname;
  ColorButton skin_settingBtn;
  ColorButton skin_traceLog;
  ImageButton skin_build;
  ImageButton skin_exit;
  public SkinEditView(String name, Rect pos_) {
    super(name);
    pos=pos_;
    addChild(skin_background=new ImageDrop("skin_background", new Rect(30, 15, 180, 115)));
    //left
    addChild(skin_btn=new ImageDrop("skin_btn", new Rect(20, 160, 100, 240)));
    addChild(skin_btnPressed=new ImageDrop("skin_btnPressed", new Rect(20, 260, 100, 340)));
    addChild(skin_cover=new ImageDrop("skin_cover", new Rect(20, 360, 100, 440)));
    addChild(skin_coverMiddle=new ImageDrop("skin_coverMiddle", new Rect(20, 460, 100, 540)));
    //right
    addChild(skin_chain=new ImageDrop("skin_chain", new Rect(1360, 160, 1440, 240)));
    addChild(skin_chainSelected=new ImageDrop("skin_chainSelected", new Rect(1360, 260, 1440, 340)));
    addChild(skin_chainNext=new ImageDrop("skin_chainNext", new Rect(1360, 360, 1440, 440)));
    addChild(skin_chainCover=new ImageDrop("skin_chainCover", new Rect(1360, 460, 1440, 540)));
    //controls
    addChild(skin_play=new ImageDrop("skin_play", new Rect(260, 30, 340, 110)));
    addChild(skin_playPressed=new ImageDrop("skin_playPressed", new Rect(360, 30, 440, 110)));
    addChild(skin_pause=new ImageDrop("skin_pause", new Rect(460, 30, 540, 110)));
    addChild(skin_pausePressed=new ImageDrop("skin_pausePressed", new Rect(560, 30, 640, 110)));
    addChild(skin_prev=new ImageDrop("skin_prev", new Rect(660, 30, 740, 110)));
    addChild(skin_prevPressed=new ImageDrop("skin_prevPressed", new Rect(760, 30, 840, 110)));
    addChild(skin_next=new ImageDrop("skin_next", new Rect(860, 30, 940, 110)));
    addChild(skin_nextPressed=new ImageDrop("skin_nextPressed", new Rect(960, 30, 1040, 110)));
    //
    addChild(skin_themeIcon=new ImageDrop("skin_themeIcon", new Rect(1220, 20, 1320, 120)));
    addChild(skin_appIcon=new ImageDrop("skin_appIcon", new Rect(1340, 20, 1440, 120)));
    //load image
    addChild(skin_package=new TextBox("skin_package", new Rect(35, 865, 205, 935), " ...theme. ", "test").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_version=new TextBox("skin_version", new Rect(215, 865, 335, 935), " Version ", "1.0.0").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_title=new TextBox("skin_title", new Rect(345, 865, 535, 935), " Title ", "Test skin").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_author=new TextBox("skin_author", new Rect(545, 865, 735, 935), " Author ", "User").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_description=new TextBox("skin_description", new Rect(745, 865, 1135, 935), " Description ", "asdf asdf").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_appname=new TextBox("skin_appname", new Rect(1145, 865, 1335, 935), " App name ", "Test skin").setNumberOnly(TextBox.NumberType.NONE));
    addChild(skin_settingBtn=new ColorButton("skin_text1", new Rect(20, 570, 80, 630)));
    addChild(skin_traceLog=new ColorButton("skin_traceLog", new Rect(20, 640, 80, 700)));
    addChild(skin_build=new ImageButton("skin_build", new Rect(1345, 865, 1435, 935)));
    addChild(skin_exit=new ImageButton("skin_exit", new Rect(1385, 795, 1435, 845)));
    skin_exit.image=loadImage("exit.png");
    skin_build.image=loadImage("run.png");
    skin_background.image=loadImage("external/skin/playbg.png");
    skin_btn.image=loadImage("external/skin/btn.png");
    skin_btnPressed.image=loadImage("external/skin/btn_.png");
    skin_cover.image=loadImage("external/skin/phantom.png");
    skin_coverMiddle.image=loadImage("external/skin/phantom_.png");
    skin_chain.image=loadImage("external/skin/chain.png");
    skin_chainSelected.image=loadImage("external/skin/chain_.png");
    skin_chainNext.image=loadImage("external/skin/chain__.png");
    skin_chainCover.image=loadImage("external/skin/chainled.png");
    skin_play.image=loadImage("external/skin/play.png");
    skin_playPressed.image=loadImage("external/skin/play_.png");
    skin_pause.image=loadImage("external/skin/pause.png");
    skin_pausePressed.image=loadImage("external/skin/pause_.png");
    skin_prev.image=loadImage("external/skin/prev.png");
    skin_prevPressed.image=loadImage("external/skin/prev_.png");
    skin_next.image=loadImage("external/skin/next.png");
    skin_nextPressed.image=loadImage("external/skin/next_.png");
    skin_themeIcon.image=loadImage("external/skin/theme_ic.png");
    skin_appIcon.image=loadImage("external/skin/appicon.png");
    skin_build.scaled=true;
    skin_build.padding=7;
    skin_settingBtn.setDescription("change text button color");
    skin_settingBtn.setPressListener(new ColorButton.OpenColorPickerEvent(skin_settingBtn));
    skin_settingBtn.setDataChangeListener(new EventListener() {
      public void onEvent(Element e) {
        maskImage1(skin_settingBtn.c);
      }
    }
    );
    skin_traceLog.setDescription("change record order color");
    skin_traceLog.setPressListener(new ColorButton.OpenColorPickerEvent(skin_traceLog));
    onLayout();
    skin_exit.setPressListener(new MouseEventListener() {
      public boolean onEvent(MouseEvent e, int index) {
        KyUI.removeLayer();
        return false;
      }
    }
    );
    skin_package.setText("test");
    skin_package.setDescription("com.kimjisub.launchpad.theme.test");
    skin_package.setTextChangeListener(new EventListener() {
      public void onEvent(Element e) {
        TextBox t=(TextBox)e;
        String text=t.getText();
        t.setDescription("com.kimjisub.launchpad.theme."+text);
        t.error=!isValidPackageName(text);
      }
    }
    );
    skin_appname.setText("Test skin");
    skin_appname.setTextChangeListener(new EventListener() {
      public void onEvent(Element e) {
        TextBox t=(TextBox)e;
        t.error=t.getContent().empty();
      }
    }
    );
    skin_title.setText("Title");
    skin_description.setText("Test unipad skin");
    skin_author.setText("User");
    skin_version.setText("1.0.0");
    skin_build.setDescription("build start");
    skin_build.setPressListener(new MouseEventListener() {
      public boolean onEvent(MouseEvent e, int index) {
        KyUI.addLayer(frame_log);
        build_windows("com.kimjisub.launchpad.theme."+skin_package.getText(), skin_appname.getText(), /*"Author : "+*/skin_author.getText(), /*"Description : "+*/skin_description.getText(), "Name : "+skin_title.getText(), skin_version.getText(), skin_settingBtn.c, skin_traceLog.c);
        return false;
      }
    }
    );
  }
  @Override
    public boolean mouseEvent(MouseEvent e, int index) {
    PVector mouse=new PVector(KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y);
    mouse.sub((pos.left+pos.right)/2, (pos.top+pos.bottom)/2);
    mouse.mult(1/0.95F);
    mouse.sub(new PVector(-528, -90));
    mouse.mult(1/0.35F);
    if (e.getAction()==MouseEvent.PRESS&&new Rect(-90, -90, 90, 90).contains(mouse.x, mouse.y)) {
      if (play)play=false;
      else play=true;
      invalidate();
    }
    return false;
  }
  @Override
    public void render(PGraphics g) {
    g.strokeWeight(5);
    PVector mouse=new PVector(KyUI.mouseGlobal.getLast().x, KyUI.mouseGlobal.getLast().y);
    g.pushMatrix();
    g.imageMode(CENTER);
    g.translate((pos.left+pos.right)/2, (pos.top+pos.bottom)/2);
    mouse.sub((pos.left+pos.right)/2, (pos.top+pos.bottom)/2);
    g.scale(0.95F);
    mouse.mult(1/0.95F);
    g.fill(color(21, 31, 42));//unipad defualt background
    g.rect(-1280/2, -720/2, 1280/2, 720/2);
    if (skin_background.image!=null) {
      g.pushMatrix();
      g.scale((float)1280/skin_background.image.width, (float)720/skin_background.image.height);
      g.image(skin_background.image, 0, 0);
      g.popMatrix();
    }
    g.image(back, 0, 0);//test
    PVector mouse2=new PVector(mouse.x, mouse.y);
    g.pushMatrix();
    g.scale((float)684/(180*info.buttonX), (float)684/(180*info.buttonY));//change values if they are incorrect.
    mouse2.x=mouse2.x/((float)684/(180*info.buttonX));
    mouse2.y=mouse2.y/((float)684/(180*info.buttonY));
    boolean coverv=(info.buttonX%2==0)&&(info.buttonY%2==0);
    for (int b=0; b<info.buttonY; b++) {
      for (int a=0; a<info.buttonX; a++) {
        float x=-((float)info.buttonX-1)*90+a*180;
        float y=-((float)info.buttonY-1)*90+b*180;
        g.pushMatrix();
        g.translate(x, y);
        if (mousePressed&&new Rect(x-90, y-90, x+90, y+90).contains(mouse2.x, mouse2.y)) {
          g.scale((float)180/skin_btnPressed.image.width, (float)180/skin_btnPressed.image.height);
          g.image(skin_btnPressed.image, 0, 0);
        } else {
          g.scale((float)180/skin_btn.image.width, (float)180/skin_btn.image.height);
          g.image(skin_btn.image, 0, 0);
        }
        g.popMatrix();
        g.pushMatrix();
        g.translate(x, y);
        if (coverv) {
          if (a==info.buttonX/2-1&&b==info.buttonY/2-1) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.image(skin_coverMiddle.image, 0, 0);
          } else if (a==info.buttonX/2&&b==info.buttonY/2-1) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.rotate(radians(90));
            g.image(skin_coverMiddle.image, 0, 0);
          } else if (a==info.buttonX/2&&b==info.buttonY/2) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.rotate(radians(180));
            g.image(skin_coverMiddle.image, 0, 0);
          } else if (a==info.buttonX/2-1&&b==info.buttonY/2) {
            g.scale((float)180/skin_coverMiddle.image.width, (float)180/skin_coverMiddle.image.height);
            g.rotate(radians(-90));
            g.image(skin_coverMiddle.image, 0, 0);
          } else {
            g.scale((float)180/skin_cover.image.width, (float)180/skin_cover.image.height);
            g.image(skin_cover.image, 0, 0);
          }
        } else {
          g.scale((float)180/skin_cover.image.width, (float)180/skin_cover.image.height);
          g.image(skin_cover.image, 0, 0);
        }
        g.popMatrix();
      }
      //chain(full 8)
      if (b<8) {
        g.pushMatrix();
        float x=-((float)info.buttonX-1)*90+info.buttonY*180;
        float y=-((float)info.buttonY-1)*90+b*180;
        g.translate(x, y);
        g.pushMatrix();
        if (mousePressed&&new Rect(x-90, y-90, x+90, y+90).contains(mouse2.x, mouse2.y)) {
          g.scale((float)180/skin_chainNext.image.width, (float)180/skin_chainNext.image.height);
          g.image(skin_chainNext.image, 0, 0);
        } else {
          if (b==0) {
            g.scale((float)180/skin_chainSelected.image.width, (float)180/skin_chainSelected.image.height);
            g.image(skin_chainSelected.image, 0, 0);
          } else {
            g.scale((float)180/skin_chain.image.width, (float)180/skin_chain.image.height);
            g.image(skin_chain.image, 0, 0);
          }
        }
        g.popMatrix();
        g.scale((float)180/skin_chainCover.image.width, (float)180/skin_chainCover.image.height);
        g.image(skin_chainCover.image, 0, 0);
        g.popMatrix();
      }
    }
    g.popMatrix();
    g.translate(-528, -90);
    mouse.sub(-528, -90);
    g.scale(0.35F);
    mouse.mult(1/0.35F);
    g.pushMatrix();
    g.translate(-180, 0);
    if (mousePressed&&new Rect(-270, -90, -90, 90).contains(mouse.x, mouse.y)) {
      g.scale((float)180/skin_prevPressed.image.width, (float)180/skin_prevPressed.image.height);
      g.image(skin_prevPressed.image, 0, 0);
    } else {
      g.scale((float)180/skin_prev.image.width, (float)180/skin_prev.image.height);
      g.image(skin_prev.image, 0, 0);
    }
    g.popMatrix();
    if (mousePressed&&new Rect(-90, -90, 90, 90).contains(mouse.x, mouse.y)) {
      g.pushMatrix();
      if (play) {
        g.scale((float)180/skin_playPressed.image.width, (float)180/skin_playPressed.image.height);
        g.image(skin_pausePressed.image, 0, 0);
      } else {
        g.scale((float)180/skin_pausePressed.image.width, (float)180/skin_pausePressed.image.height);
        g.image(skin_playPressed.image, 0, 0);
      }
      g.popMatrix();
    } else {
      //if (mousePressed&&new Rect(-90, -90, 90, 90).contains(mouse.x, mouse.y)) {
      g.pushMatrix();
      if (play) {
        g.scale((float)180/skin_play.image.width, (float)180/skin_play.image.height);
        g.image(skin_play.image, 0, 0);
      } else {
        g.scale((float)180/skin_pause.image.width, (float)180/skin_pause.image.height);
        g.image(skin_pause.image, 0, 0);
      }
      g.popMatrix();
      //}
    }
    g.pushMatrix();
    g.translate(180, 0);
    if (mousePressed&&new Rect(90, -90, 270, 90).contains(mouse.x, mouse.y)) {
      g.scale((float)180/skin_nextPressed.image.width, (float)180/skin_nextPressed.image.height);
      g.image(skin_nextPressed.image, 0, 0);
    } else {
      g.scale((float)180/skin_next.image.width, (float)180/skin_next.image.height);
      g.image(skin_next.image, 0, 0);
    }
    g.popMatrix();
    g.popMatrix();
    g.noStroke();
  }
  void maskImage1(color c) {//masks text1
    back=loadImage("skinback.png");
    back.loadPixels();
    for (int a=0; a<back.pixels.length; a++) {
      back.pixels[a]=color(red(c), green(c), blue(c), max(0, alpha(back.pixels[a])+alpha(c)-255));
    }
    back.updatePixels();
    invalidate();
  }
}
//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/build/Build.java
//https://spin.atomicobject.com/2011/08/22/building-android-application-bundles-apks-by-hand/
import com.android.sdklib.build.ApkBuilder;
import org.eclipse.jdt.internal.compiler.batch.Main;
import java.io.FilenameFilter;
class ThreadScanner implements Runnable {
  InputStream input;
  java.util.Scanner scanner;
  ConsoleEdit logs;
  boolean active;
  ThreadScanner(InputStream input_, ConsoleEdit logs_) {
    input=input_;
    scanner=new java.util.Scanner(input);
    active=true;
    logs=logs_;
  }
  void close() throws IOException {
    active=false;
    scanner.close();
  }
  @Override void run() {
    String line="";
    while (input!=null&&line!=null&&active) {
      if (scanner.hasNextLine()) {
        line= scanner.nextLine();
        logs.addLine(addLinebreaks(line, 75));
        //try {
        //  Thread.sleep(1);
        //}
        //catch(InterruptedException e) {
        //}
      }
    }
  }
}
void build_windows(final String packageName, final String appName, final String author, final String description, final String themeName, final String versionName, final color settingBtn, final color traceLog) {
  new Thread(new Runnable() {
    public void run() {
      ((ImageButton)KyUI.get("log_exit")).setEnabled(false);
      ((ImageButton)KyUI.get("log_exit")).invalidate();
      color actionBar=color(0);
      ConsoleEdit logs=(ConsoleEdit)KyUI.get("log_content");
      String androidJarPath=joinPath(getDataPath(), "builder/android.jar");
      if (new java.io.File(androidJarPath).isFile()==false) {
        logs.addLine("android.jar not found, downloading android.jar from URL...").invalidate();
        InputStream in=null;
        FileOutputStream fos=null;
        try {
          URL url=new URL("https://github.com/EX867/external/raw/master/android.jar");
          in = url.openStream();
          fos = new FileOutputStream(androidJarPath);
          byte[] buf = new byte[1024*1024];
          double len = 0;
          double tmp = 0;
          int count=1;
          int size = url.openConnection().getContentLength()*10/1024/1024;
          while ((len = in.read(buf)) > 0) {        
            tmp += len / 1024 / 1024;
            if (tmp*10>count) {
              logs.addLine(((float)count/10)+"MB / "+((float)size/10)+"MB").invalidate();
              count++;
            }
            fos.write(buf, 0, (int) len);
            fos.flush();
          }
          logs.addLine("android.jar download finished.").invalidate();
        }
        catch(Exception e) {
          logs.addLine("android.jar not found, can't download from URL\n   cause : "+e.toString());
          return;
        }
        try {
          in.close();
        }
        catch(Exception e) {
        }
        try {
          fos.close();
        }
        catch(Exception e) {
        }
      } else {
        logs.addLine("android.jar was found, continuing build...").invalidate();
      }
      String toolsPath=joinPath(getDataPath(), "lib/tools.jar");
      if (new java.io.File(toolsPath).isFile()==false) {
        logs.addLine("tools.jar not found, downloading tools.jar from URL...").invalidate();
        InputStream in=null;
        FileOutputStream fos=null;
        try {
          URL url=new URL("https://github.com/EX867/external/raw/master/tools.jar");
          in = url.openStream();
          fos = new FileOutputStream(androidJarPath);
          byte[] buf = new byte[1024*1024];
          double len = 0;
          double tmp = 0;
          int count=1;
          int size = url.openConnection().getContentLength()*10/1024/1024;
          while ((len = in.read(buf)) > 0) {        
            tmp += len / 1024 / 1024;
            if (tmp*10>count) {
              logs.addLine(((float)count/10)+"MB / "+((float)size/10)+"MB").invalidate();
              count++;
            }
            fos.write(buf, 0, (int) len);
            fos.flush();
          }
          logs.addLine("tools.jar download finished.").invalidate();
        }
        catch(Exception e) {
          logs.addLine("tools.jar not found, can't download from URL\n   cause : "+e.toString());
          return;
        }
        try {
          in.close();
        }
        catch(Exception e) {
        }
        try {
          fos.close();
        }
        catch(Exception e) {
        }
      } else {
        logs.addLine("tools.jar was found, continuing build...").invalidate();
      }
      try {
        String datapath=getDataPath();
        String buildPath=joinPath(joinPath(path_global, "temp"), appName);
        logs.addLine("deleting old files...").invalidate();
        if (new File(buildPath).exists())deleteFile(buildPath);
        logs.addLine("creating files for build...").invalidate();
        String drawable=joinPath(buildPath, "res/drawable/");
        ((ImageDrop)KyUI.get("skin_appIcon")).image.save(drawable+"appicon.png");
        ((ImageDrop)KyUI.get("skin_themeIcon")).image.save(drawable+"theme_ic.png");
        ((ImageDrop)KyUI.get("skin_btn")).image.save(drawable+"btn.png");
        ((ImageDrop)KyUI.get("skin_btnPressed")).image.save(drawable+"btn_.png");
        ((ImageDrop)KyUI.get("skin_chain")).image.save(drawable+"chain.png");
        ((ImageDrop)KyUI.get("skin_chainSelected")).image.save(drawable+"chain_.png");
        ((ImageDrop)KyUI.get("skin_chainNext")).image.save(drawable+"chain__.png");
        ((ImageDrop)KyUI.get("skin_chainCover")).image.save(drawable+"chainled.png");
        ((ImageDrop)KyUI.get("skin_play")).image.save(drawable+"play.png");
        ((ImageDrop)KyUI.get("skin_playPressed")).image.save(drawable+"play_.png");
        ((ImageDrop)KyUI.get("skin_pause")).image.save(drawable+"pause.png");
        ((ImageDrop)KyUI.get("skin_pausePressed")).image.save(drawable+"pause_.png");
        ((ImageDrop)KyUI.get("skin_prev")).image.save(drawable+"prev.png");
        ((ImageDrop)KyUI.get("skin_prevPressed")).image.save(drawable+"prev_.png");
        ((ImageDrop)KyUI.get("skin_next")).image.save(drawable+"next.png");
        ((ImageDrop)KyUI.get("skin_nextPressed")).image.save(drawable+"next_.png");
        ((ImageDrop)KyUI.get("skin_background")).image.save(drawable+"playbg.png");
        ((ImageDrop)KyUI.get("skin_cover")).image.save(drawable+"phantom.png");
        ((ImageDrop)KyUI.get("skin_coverMiddle")).image.save(drawable+"phantom_.png");
        writeFile(joinPath(buildPath, "src/java/"+packageName.replace(".", "/")+"/MainActivity.java"), build_generateMainActivity(packageName));
        copyFile(joinPath(datapath, "external/skin/xml_next.xml"), joinPath(buildPath, "res/drawable/xml_next.xml"));
        copyFile(joinPath(datapath, "external/skin/xml_prev.xml"), joinPath(buildPath, "res/drawable/xml_prev.xml"));
        copyFile(joinPath(datapath, "external/skin/xml_pause.xml"), joinPath(buildPath, "res/drawable/xml_pause.xml"));
        copyFile(joinPath(datapath, "external/skin/xml_play.xml"), joinPath(buildPath, "res/drawable/xml_play.xml"));
        writeFile(joinPath(buildPath, "res/layout/activity_main.xml"), build_generateLayout(packageName));
        writeFile(joinPath(buildPath, "res/values/colors.xml"), build_generateColors(actionBar, settingBtn, traceLog));
        writeFile(joinPath(buildPath, "res/values/styles.xml"), build_generateStyles());
        writeFile(joinPath(buildPath, "res/values/strings.xml"), build_generateStrings(appName, author, description, themeName));
        writeFile(joinPath(buildPath, "AndroidManifest.xml"), build_generateManifest(versionName, packageName));
        new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).getParentFile().mkdirs();
        new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).createNewFile();
        new File(joinPath(buildPath, "bin")).mkdirs();
        new File(joinPath(buildPath, "bin/apk")).mkdirs();
        //Run AAPT
        logs.addLine("running aapt...").invalidate();
        String aaptPath="\""+joinPath(datapath, "builder/aapt.exe")+"\"";
        String resPath="\""+joinPath(buildPath, "res")+"\"";
        String genPath="\""+joinPath(buildPath, "gen")+"\"";
        String manifestPath="\""+joinPath(buildPath, "AndroidManifest.xml")+"\"";
        String apkResPath=joinPath(buildPath, "bin/"+appName+".apk.res");
        int code=0;
        ProcessBuilder builder = new ProcessBuilder(new String[]{aaptPath, "package", "-v", "-f", "-m", "-S", resPath, "-J", genPath, "-M", manifestPath, "-I", "\""+androidJarPath+"\"", "-F", "\""+apkResPath+"\"", "--generate-dependencies"});
        builder.redirectErrorStream(true);
        Process aaptProcess = builder.start();
        ThreadScanner scanner=new ThreadScanner(aaptProcess.getInputStream(), logs);
        new Thread(scanner).start();
        if ((code=aaptProcess.waitFor()) != 0) {
          throw new Exception("AAPT exited with error code "+code);
        }
        scanner.close();
        if (new File(joinPath(buildPath, "bin/"+appName+".apk.res")).exists()==false) {
          throw new Exception(appName+".apk.res file is not created");
        }
        logs.addLine("compiling...");//Run ECJ
        Main main = new Main(new PrintWriter(System.out), new PrintWriter(System.err), false, null, null);
        String[] ecjArgs = {
          "-warn:-unusedImport", // Disable warning for unused imports
          "-extdirs", joinPath(datapath, "builder"), // The location of the external libraries
          "-bootclasspath", androidJarPath, // The location of android.jar
          "-classpath", joinPath(buildPath, "src"), // The location of the source folder
          "-classpath", joinPath(buildPath, "gen"), // The location of the generated folder
          "-1.6", 
          "-target", "1.6", // Target Java level
          "-proc:none", // Disable annotation processors...
          "-d", joinPath(buildPath, "bin/classes"), // The location of the output folder
          joinPath(joinPath(buildPath, "src"), joinPath("java", packageName.replace(".", "/")+"/MainActivity.java")) // The location of the main activity
        };
        if (main.compile(ecjArgs)) {
          logs.addLine("compile success!").invalidate();
        } else {
          throw new Exception("Compilation with ECJ failed");
        }
        //Run DX Dexer
        logs.addLine("Dexing source...").invalidate();
        String[] dxArgs= new String[] {
          "--num-threads=1", 
          "--output=" + joinPath(buildPath, /*"bin/main-classes.dex"*/"bin/classes.dex"), //The output location of the sketch's dexed classes
          joinPath(buildPath, "bin/classes")//add "classes" to get DX to work properly
        };
        //This is some side-stepping to avoid System.exit() calls
        com.androidjarjar.dx.command.dexer.Main.Arguments dexArgs = new com.androidjarjar.dx.command.dexer.Main.Arguments();
        dexArgs.parse(dxArgs);
        int resultCode = com.androidjarjar.dx.command.dexer.Main.run(dexArgs);
        if (resultCode != 0) {
          throw new Exception("DX Dexer exited with code "+resultCode);
        }
        //Run APKBuilder
        logs.addLine("building apk...").invalidate();
        ApkBuilder apkbuilder = new ApkBuilder(new File(joinPath(buildPath, "bin/" + appName + ".apk.unaligned.unsigned")), //The location of the output APK file (unsigned)
          new File(joinPath(buildPath, "bin/" + appName + ".apk.res")), //The location of the .apk.res file
          new File(joinPath(buildPath, "bin/classes.dex")), //The location of the DEX class file
          null, null //Only specify an output stream if we want verbose output
          );
        apkbuilder.addSourceFolder(new File(joinPath(buildPath, "src"))); //The location of the source folder
        apkbuilder.sealApk();
        logs.addLine("signing apk with default keystore...").invalidate();
        //-keystore examplestore -signedjar sCount.jar Count.jar signFiles 
        builder=new ProcessBuilder(joinPath(datapath, "builder/jarsigner.exe"), "-verbose", "-keystore", joinPath(datapath, "builder/debug.keystore"), "-keypass", "android", "-storepass", "android", "-signedjar", joinPath(buildPath, "bin/" + appName + ".apk.unaligned"), joinPath(buildPath, "bin/" + appName + ".apk.unaligned.unsigned"), "androiddebugkey");
        builder.redirectErrorStream(true);
        Process process = builder.start();
        scanner=new ThreadScanner(process.getInputStream(), logs);
        new Thread(scanner).start();
        if ((code=process.waitFor()) != 0) {
          throw new Exception("JarSigner exited with error code "+code);
        }
        scanner.close();
        logs.addLine("aligning apk").invalidate();
        builder=new ProcessBuilder(joinPath(datapath, "builder/zipalign.exe"), "-f", "-v", "4", joinPath(buildPath, "bin/" + appName + ".apk.unaligned"), joinPath(buildPath, "bin/apk/" + appName + ".apk"));
        builder.redirectErrorStream(true);
        process = builder.start();
        scanner=new ThreadScanner(process.getInputStream(), logs);
        new Thread(scanner).start();
        if ((code=process.waitFor()) != 0) {
          throw new Exception("ZipAlign exited with error code "+code);
        }
        scanner.close();
        logs.addLine("Build successful!\n").invalidate();
        openFileExplorer(joinPath(buildPath, "bin/apk/"));//appName + ".apk"
      }
      catch(Exception e) {
        logs.addLine("Build failed : \n\n"+e.toString()+"!\n").invalidate();
      }
      ((ImageButton)KyUI.get("log_exit")).setEnabled(true);
      ((ImageButton)KyUI.get("log_exit")).invalidate();
    }
  }
  ).start();
}
public static void dexJar(String inputPath, String outputPath) {
  try {
    String[] args = new String[] {
      "--output=" + outputPath, //The location of the output DEXed file
      inputPath, //The location of the file to DEXify
    };
    //This is some side-stepping to avoid System.exit() calls
    com.androidjarjar.dx.command.dexer.Main.Arguments dexArgs = new com.androidjarjar.dx.command.dexer.Main.Arguments();
    dexArgs.parse(args);
    int resultCode = com.androidjarjar.dx.command.dexer.Main.run(dexArgs);

    if (resultCode != 0) {
      System.err.println("DX Dexer failed, error code : " + resultCode);
    }
  } 
  catch (Exception e) {
    System.err.println("DX Dexer failed");
    e.printStackTrace();
  }
}
String build_generateLayout(String packageName) {
  return readFile(joinPath(getDataPath(), "external/skin/activity_main.xml")).replace("PACKAGE_NAME", packageName);
}
String build_generateStrings(String appName, String author, String description, String themeName) {
  return readFile(joinPath(getDataPath(), "external/skin/strings.xml")).replace("APP_NAME", appName).replace("THEME_NAME", themeName).replace("THEME_DESCRIPTION", description).replace("THEME_AUTHOR", author);
}
String build_generateStyles() {
  return readFile(joinPath(getDataPath(), "external/skin/styles.xml"));
}
String build_generateColors(color actionBar, color settingBtn, color traceLog) {
  return readFile(joinPath(getDataPath(), "external/skin/colors.xml")).replace("SETTING_BTN", hex(settingBtn).toUpperCase()).replace("TEXT1", "FF000000").replace("TRACE_LOG", hex(traceLog).toUpperCase());
}
String build_generateManifest(String versionName, String packageName) {
  return readFile(joinPath(getDataPath(), "external/skin/AndroidManifest.xml")).replace("PACKAGE_NAME", packageName).replace("VERSION_NAME", versionName);
}
String build_generateMainActivity(String packageName) {
  String ret="package "+packageName+";"+
    //"import android.support.v7.app.AppCompatActivity;"+
    "import android.app.Activity;"+
    "import android.os.Bundle;"+
    "public class MainActivity extends Activity {"+//AppCompatActivity {"+
    "    @Override"+
    "    protected void onCreate(Bundle savedInstanceState) {"+
    "        super.onCreate(savedInstanceState);"+
    "        setContentView(R.layout.activity_main);"+
    "        getActionBar().setDisplayShowHomeEnabled(false);"+
    "    }"+
    "}";
  return ret;
}
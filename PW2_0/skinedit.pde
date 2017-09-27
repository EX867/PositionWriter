//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/build/Build.java
//https://spin.atomicobject.com/2011/08/22/building-android-application-bundles-apks-by-hand/
import kellinwood.security.zipsigner.ZipSigner;
import com.android.sdklib.build.ApkBuilder;
import org.eclipse.jdt.internal.compiler.batch.Main;
import java.io.FilenameFilter;

PImage skin_appIcon;
PImage skin_themeIcon;
PImage skin_btn;
PImage skin_btnPressed;
PImage skin_chain;
PImage skin_chainSelected;
PImage skin_chainNext;
PImage skin_play;
PImage skin_playPressed;
PImage skin_pause;
PImage skin_pausePressed;
PImage skin_prev;
PImage skin_prevPressed;
PImage skin_next;
PImage skin_nextPressed;
PImage skin_background;
PImage skin_cover;
PImage skin_coverMiddle;

class ThreadScanner implements Runnable {
  InputStream input;
  java.util.Scanner scanner;
  Logger logger;
  boolean active;
  ThreadScanner(InputStream input_) {
    input=input_;
    scanner=new java.util.Scanner(input);
    logger=(Logger)UI[getUIid("ERROR_LOG")];
    active=true;
  }
  void close() throws IOException {
    scanner.close();
  }
  @Override void run() {
    String line="";
    while (input!=null&&line!=null&&active) {
      if (scanner.hasNextLine()) {
        line= scanner.nextLine();
        System.out.println(line);
        logger.logs.add(line);
        registerRender();
        try {
          Thread.sleep(1);
        }
        catch(Exception e) {
          e.printStackTrace();
        }
      }
    }
  }
}
void loadDefaultImages() {
  skin_appIcon=loadImage("template/skin/appicon.png");
  skin_themeIcon=loadImage("template/skin/theme_ic.png");
  skin_btn=loadImage("template/skin/btn.png");
  skin_btnPressed=loadImage("template/skin/btn.png");
  skin_chain=loadImage("template/skin/chain.png");
  skin_chainSelected=loadImage("template/skin/chain.png");
  skin_chainNext=loadImage("template/skin/chain.png");
  skin_play=loadImage("template/skin/play.png");
  skin_playPressed=loadImage("template/skin/play_.png");
  skin_pause=loadImage("template/skin/pause.png");
  skin_pausePressed=loadImage("template/skin/pause_.png");
  skin_prev=loadImage("template/skin/prev.png");
  skin_prevPressed=loadImage("template/skin/prev_.png");
  skin_next=loadImage("template/skin/next.png");
  skin_nextPressed=loadImage("template/skin/next_.png");
  skin_background=loadImage("template/skin/playbg.png");
  skin_cover=loadImage("template/skin/phantom.png");
  skin_coverMiddle=loadImage("template/skin/phantom_.png");
}

void build_windows(String packageName, String appName, String author, String description, String themeName, color text) {
  ((Logger)UI[getUIid("ERROR_LOG")]).logs.clear();
  if (new java.io.File(joinPath(joinPath(GlobalPath, ExternalPath), "android.jar")).isFile()==false) {
    displayLogError("You have to copy android.jar into \""+joinPath(joinPath(GlobalPath, ExternalPath), "android.jar")+"\" before building skin!");
    return;
  }
  new Thread(new ThreadBuilder(packageName, appName, author, description, themeName, text)).start();
}
class ThreadBuilder implements Runnable {
  String packageName_; 
  String appName_; 
  String author_; 
  String description_;
  String themeName_; 
  color text_;
  ThreadBuilder(String packageName, String appName, String author, String description, String themeName, color text) {
    packageName_=packageName;
    appName_=appName;
    author_=author;
    description_=description;
    themeName_=themeName;
    text_=text;
  }
  void run() {
    build_windows_thread(packageName_, appName_, author_, description_, themeName_, text_);
  }
  void build_windows_thread(String packageName, String appName, String author, String description, String themeName, color text) {
    color actionBar=color(0);
    ArrayList<String> logs=((Logger)UI[getUIid("ERROR_LOG")]).logs;
    try {
      String datapath=getDataPath();
      String buildPath=joinPath(joinPath(GlobalPath, TempPath), appName);
      surface.setTitle(title_filename+title_edited+title_suffix+" - deleting old files...");
      logs.add("deleting old files...");
      registerRender();
      if (new File(buildPath).exists())deleteFile(buildPath);
      surface.setTitle(title_filename+title_edited+title_suffix+" - creating files for build...");
      logs.add("creating files for build...");
      registerRender();
      surface.setTitle(title_filename+title_edited+title_suffix+" - creating build files...");
      logs.add("creating build files...");
      registerRender();
      String drawable=joinPath(buildPath, "res/drawable/");
      skin_appIcon.save(drawable+"appicon.png");
      skin_themeIcon.save(drawable+"theme_ic.png");
      skin_btn.save(drawable+"btn.png");
      skin_btnPressed.save(drawable+"btn_.png");
      skin_chain.save(drawable+"chain.png");
      skin_chainSelected.save(drawable+"chain_.png");
      skin_chainNext.save(drawable+"chain__.png");
      skin_play.save(drawable+"play.png");
      skin_playPressed.save(drawable+"play_.png");
      skin_pause.save(drawable+"pause.png");
      skin_pausePressed.save(drawable+"pause_.png");
      skin_prev.save(drawable+"prev.png");
      skin_prevPressed.save(drawable+"prev_.png");
      skin_next.save(drawable+"next.png");
      skin_nextPressed.save(drawable+"next_.png");
      skin_background.save(drawable+"playbg.png");
      skin_cover.save(drawable+"phantom.png");
      skin_coverMiddle.save(drawable+"phantom_.png");
      writeFile(joinPath(buildPath, "src/java/"+packageName.replace(".", "/")+"/MainActivity.java"), build_generateMainActivity(packageName));
      EX_fileCopy(joinPath(datapath, "template/skin/xml_next.xml"), joinPath(buildPath, "res/drawable/xml_next.xml"));
      EX_fileCopy(joinPath(datapath, "template/skin/xml_prev.xml"), joinPath(buildPath, "res/drawable/xml_prev.xml"));
      EX_fileCopy(joinPath(datapath, "template/skin/xml_pause.xml"), joinPath(buildPath, "res/drawable/xml_pause.xml"));
      EX_fileCopy(joinPath(datapath, "template/skin/xml_play.xml"), joinPath(buildPath, "res/drawable/xml_play.xml"));
      EX_fileCopy(joinPath(datapath, "template/skin/activity_main.xml"), joinPath(buildPath, "res/layout/activity_main.xml"));
      writeFile(joinPath(buildPath, "res/values/colors.xml"), build_generateColors(actionBar, text));
      writeFile(joinPath(buildPath, "res/values/styles.xml"), build_generateStyles());
      writeFile(joinPath(buildPath, "res/values/strings.xml"), build_generateStrings(appName, author, description, themeName));
      writeFile(joinPath(buildPath, "AndroidManifest.xml"), build_generateManifest(packageName));
      new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).getParentFile().mkdirs();
      new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).createNewFile();
      new File(joinPath(buildPath, "bin")).mkdirs();
      new File(joinPath(buildPath, "bin/apk")).mkdirs();
      //Run AAPT
      surface.setTitle(title_filename+title_edited+title_suffix+" - running aapt...");
      logs.add("running aapt...");
      registerRender();
      List<String> cmd = new ArrayList<String>();
      cmd.add(joinPath(datapath, "builder")+"/aapt.exe");
      cmd.add("package");
      cmd.add("-v");
      cmd.add("-f");
      cmd.add("-m");
      cmd.add("-S");
      cmd.add("\""+joinPath(buildPath, "res")+"\"");
      cmd.add("-J");
      cmd.add(joinPath(buildPath, "gen"));
      cmd.add("-M");
      cmd.add("\""+joinPath(buildPath, "AndroidManifest.xml")+"\"");
      cmd.add("-I");
      cmd.add("\""+joinPath(joinPath(GlobalPath, ExternalPath), "android.jar")+"\"");
      /*cmd.add("-S");
       cmd.add("\""+joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar")+"\"");*/
      cmd.add("-F");
      cmd.add("\""+joinPath(buildPath, "bin/"+appName+".apk.res")+"\"");
      cmd.add("--generate-dependencies");
      ProcessBuilder builder = new ProcessBuilder(cmd);
      builder.redirectErrorStream(true);
      Process aaptProcess = builder.start();
      ThreadScanner scanner=new ThreadScanner(aaptProcess.getInputStream());
      new Thread(scanner).start();
      int code = aaptProcess.waitFor();
      scanner.active=false;
      scanner.close();
      if (code != 0) {
        System.err.println("AAPT exited with error code " + code);
        throw new Exception("AAPT exited with error code "+code);
      }
      if (new File(joinPath(buildPath, "bin/"+appName+".apk.res")).exists()==false) {
        throw new Exception(appName+".apk.res file is not created");
      }
      //Run ECJ
      surface.setTitle(title_filename+title_edited+title_suffix+" - compiling...");
      Main main = new Main(new PrintWriter(System.out), new PrintWriter(System.err), false, null, null);
      String[] ecjArgs = {
        "-warn:-unusedImport", // Disable warning for unused imports
        "-extdirs", joinPath(datapath, "builder"), // The location of the external libraries
        "-bootclasspath", joinPath(joinPath(GlobalPath, ExternalPath), "android.jar"), // The location of android.jar
        "-classpath", joinPath(buildPath, "src"), // The location of the source folder
        "-classpath", joinPath(buildPath, "gen"), // The location of the generated folder
        "-1.6", 
        "-target", "1.6", // Target Java level
        "-proc:none", // Disable annotation processors...
        "-d", joinPath(buildPath, "bin/classes"), // The location of the output folder
        joinPath(joinPath(buildPath, "src"), joinPath("java", packageName.replace(".", "/")+"/MainActivity.java")) // The location of the main activity
      };
      if (main.compile(ecjArgs)) {
        logs.add("Compile success!");
        registerRender();
      } else {
        //We have some compilation errors
        println("Compilation with ECJ failed");
        surface.setTitle(title_filename+title_edited+title_suffix);
        throw new Exception("Compilation with ECJ failed");
      }
      //Run DX Dexer
      surface.setTitle(title_filename+title_edited+title_suffix+" - dexing...");
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
        System.err.println("DX Dexer result code: " + resultCode);
        throw new Exception("DX Dexer exited with code "+resultCode);
      }
      //Run DX Merger
      //surface.setTitle(title_filename+title_edited+title_suffix+" - merging dex files...");
      //if (new File(joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex")).isFile()==false) {
      //  dexJar(joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar"), joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex"));
      //}
      //String[] args = new String[2];
      //args[0] = joinPath(buildPath, "bin/classes.dex"); //The location of the output DEX class file
      //args[1] = joinPath(buildPath, "bin/main-classes.dex"); //The location of the sketch's dexed classes
      //Apparently, this tool accepts as many dex files as we want to throw at it...
      //args[2]=joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex");
      //com.androidjarjar.dx.merge.DexMerger.main(args);
      //Run APKBuilder
      surface.setTitle(title_filename+title_edited+title_suffix+" - building apk...");
      logs.add("building apk...");
      registerRender();
      //Create the builder with the basic files
      ApkBuilder apkbuilder = new ApkBuilder(new File(joinPath(buildPath, "bin/" + appName + ".apk.unsigned")), //The location of the output APK file (unsigned)
        new File(joinPath(buildPath, "bin/" + appName + ".apk.res")), //The location of the .apk.res file
        new File(joinPath(buildPath, "bin/classes.dex")), //The location of the DEX class file
        null, null //Only specify an output stream if we want verbose output
        );
      //Add everything else
      apkbuilder.addSourceFolder(new File(joinPath(buildPath, "src"))); //The location of the source folder
      //Seal the APK
      apkbuilder.sealApk();
      surface.setTitle(title_filename+title_edited+title_suffix+" - signing apk with default keystore...");
      logs.add("signing apk with default keystore...");
      registerRender();
      String inFilename =joinPath(buildPath, "bin/" + appName + ".apk.unsigned");
      String outFilename = joinPath(buildPath, "bin/apk/" + appName + ".apk");
      ZipSigner signer = null;
      signer=new ZipSigner();
      signer.setKeymode("testkey");
      try {
        signer.signZip(inFilename, outFilename);
      }
      catch(Throwable t) {
        t.printStackTrace();
      }
      logs.add("");
      logs.add("Build success!");
      registerRender();
      surface.setTitle(title_filename+title_edited+title_suffix);
    }
    catch(Exception e) {
      surface.setTitle(title_filename+title_edited+title_suffix);
      e.printStackTrace();
      displayLogError(e);
      return;
    }
    openFileExplorer(joinPath(joinPath(joinPath(GlobalPath, TempPath), appName), "bin/apk/" ));//appName + ".apk"
    registerRender();
  }
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
String build_generateStrings(String appName, String author, String description, String themeName) {
  String ret="<resources>"+
    "  <string name=\"app_name\">"+appName+"</string>"+
    "  <string name=\"theme_author\">"+author+"</string>"+
    "  <string name=\"theme_description\">"+description+"</string>"+
    "  <string name=\"theme_name\">"+themeName+"</string>"+
    "</resources>";
  return ret;
}
String build_generateStyles() {
  String ret="<resources>"+
    "  <style name=\"AppTheme\" parent=\"android:style/Theme.Holo.Light.DarkActionBar\">"+//Theme.AppCompat.Light.DarkActionBar\">"+
    //"    <item name=\"@android:actionBarColor\">@color/colorPrimary</item>"+//colorPrimary
    "  </style>"+
    "</resources>";
  return ret;
}
String build_generateColors(color actionBar, color text) {
  String ret="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+
    "<resources>"+
    "  <color name=\"colorPrimary\">#"+hex(actionBar).toUpperCase()+"</color>"+//default FF3F51B5
    "  <color name=\"text1\">#"+hex(text).toUpperCase()+"</color>"+//default FFFFFFFF
    "</resources>";
  return ret;
}
String build_generateManifest(String packageName) {
  String ret="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+
    "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\""+
    "  package=\""+packageName+"\">"+
    "  <application"+
    "    android:allowBackup=\"true\""+
    "    android:icon=\"@drawable/appicon\""+
    "    android:label=\"@string/app_name\""+
    "    android:supportsRtl=\"true\""+
    "    android:theme=\"@style/AppTheme\">"+
    "    <activity android:name=\".MainActivity\">"+
    "      <intent-filter>"+
    "          <action android:name=\"android.intent.action.MAIN\" />"+
    "        <category android:name=\"android.intent.category.LAUNCHER\" />"+
    "      </intent-filter>"+
    "    </activity>"+
    "  </application>"+
    "</manifest>";
  return ret;
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
class SkinEditView extends UIelement {
  ArrayList<InnerDropArea> areas=new ArrayList<InnerDropArea>();
  //test
  PImage back=loadImage("skinback.png");
  boolean play=true;
  TextBox packageEdit;
  TextBox titleEdit;
  TextBox authorEdit;
  TextBox descriptionEdit;
  TextBox appnameEdit;
  Button textColorEdit;
  public SkinEditView( int ID_, int Type_, String name_, String description_, float x_, float y_, float w_, float h_) {
    super (ID_, Type_, name_, description_, x_, y_, w_, h_);
    areas.add(new InnerDropArea(new Rect(100, 60, 80, 45), skin_background));//i failed to make this in proper way. I have to use gui library(2)!!
    //left
    areas.add(new InnerDropArea(new Rect(50, 200, 40, 40), skin_btn));
    areas.add(new InnerDropArea(new Rect(50, 300, 40, 40), skin_btnPressed));
    areas.add(new InnerDropArea(new Rect(50, 400, 40, 40), skin_cover));
    areas.add(new InnerDropArea(new Rect(50, 500, 40, 40), skin_coverMiddle));
    //right
    areas.add(new InnerDropArea(new Rect(1370, 200, 40, 40), skin_chain));
    areas.add(new InnerDropArea(new Rect(1370, 300, 40, 40), skin_chainSelected));
    areas.add(new InnerDropArea(new Rect(1370, 400, 40, 40), skin_chainNext));
    //controls
    areas.add(new InnerDropArea(new Rect(300, 60, 40, 40), skin_play));
    areas.add(new InnerDropArea(new Rect(400, 60, 40, 40), skin_playPressed));
    areas.add(new InnerDropArea(new Rect(500, 60, 40, 40), skin_pause));
    areas.add(new InnerDropArea(new Rect(600, 60, 40, 40), skin_pausePressed));
    areas.add(new InnerDropArea(new Rect(700, 60, 40, 40), skin_prev));
    areas.add(new InnerDropArea(new Rect(800, 60, 40, 40), skin_prevPressed));
    areas.add(new InnerDropArea(new Rect(900, 60, 40, 40), skin_next));
    areas.add(new InnerDropArea(new Rect(1000, 60, 40, 40), skin_nextPressed));
    //
    areas.add(new InnerDropArea(new Rect(1230, 60, 50, 50), skin_themeIcon));
    areas.add(new InnerDropArea(new Rect(1350, 60, 50, 50), skin_appIcon));
  }
  void setComponents(TextBox a, TextBox b, TextBox c, TextBox d, TextBox e, Button f) {
    packageEdit=a;
    titleEdit=b;
    authorEdit=c;
    descriptionEdit=d;
    appnameEdit=e;
    textColorEdit=f;
  }
  @Override
    boolean react() {
    if (super.react()==false)return false;//LOG_LOG
    PVector mouse=new PVector(MouseX, MouseY);
    mouse.sub(position);
    mouse.mult(1/0.95F);
    mouse.sub(new PVector(-528, -90));
    mouse.mult(1/0.35F);
    if (mouseState==AN_PRESS||mouseState==AN_RELEASE)render();//it is so inefficient so I need to use gui library!!
    if (mouseState==AN_PRESS&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
      if (play)play=false;
      else play=true;
    }
    return false;
  }
  @Override
    void render() {
    int a=0;
    strokeWeight(5);
    while (a<areas.size()) {
      areas.get(a).location.render(UIcolors[I_BACKGROUND], UIcolors[I_FOREGROUND]);
      pushMatrix();
      translate(areas.get(a).location.position.x, areas.get(a).location.position.y);
      scale(areas.get(a).location.size.x*2/areas.get(a).image.width, areas.get(a).location.size.y*2/areas.get(a).image.height);
      image(areas.get(a).image, 0, 0);
      popMatrix();
      a=a+1;
    }
    //draw image
    PVector mouse=new PVector(MouseX, MouseY);
    pushMatrix();
    translate(position.x, position.y);
    mouse.sub(position);
    scale(0.95F);
    mouse.mult(1/0.95F);
    fill(color(21, 31, 42/*unipad defualt background*/));
    rect(0, 0, 1280/2, 720/2);
    //
    pushMatrix();
    scale((float)1280/skin_background.width, (float)720/skin_background.height);
    image(skin_background, 0, 0);
    popMatrix();
    image(back, 0, 0);//test
    PVector mouse2=new PVector(mouse.x, mouse.y);
    pushMatrix();
    scale((float)684/(180*ButtonX), (float)684/(180*ButtonY));//change values if they are incorrect.
    mouse2.x=mouse2.x/((float)684/(180*ButtonX));
    mouse2.y=mouse2.y/((float)684/(180*ButtonY));
    boolean coverv=(ButtonX%2==0)&&(ButtonY%2==0);
    int b=0;
    while (b<ButtonY) {
      a=0;
      while (a<ButtonY) {
        float x=-((float)ButtonX-1)*90+a*180;
        float y=-((float)ButtonY-1)*90+b*180;
        pushMatrix();
        translate(x, y);
        if (mousePressed&&new Rect(x, y, 90, 90).includes(mouse2.x, mouse2.y)) {
          scale((float)180/skin_btnPressed.width, (float)180/skin_btnPressed.height);
          image(skin_btnPressed, 0, 0);
        } else {
          scale((float)180/skin_btn.width, (float)180/skin_btn.height);
          image(skin_btn, 0, 0);
        }
        popMatrix();
        pushMatrix();
        translate(x, y);
        if (coverv) {
          if (a==ButtonX/2-1&&b==ButtonY/2-1) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            image(skin_coverMiddle, 0, 0);
          } else if (a==ButtonX/2&&b==ButtonY/2-1) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            rotate(radians(90));
            image(skin_coverMiddle, 0, 0);
          } else if (a==ButtonX/2&&b==ButtonY/2) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            rotate(radians(180));
            image(skin_coverMiddle, 0, 0);
          } else if (a==ButtonX/2-1&&b==ButtonY/2) {
            scale((float)180/skin_coverMiddle.width, (float)180/skin_coverMiddle.height);
            rotate(radians(-90));
            image(skin_coverMiddle, 0, 0);
          } else {
            scale((float)180/skin_cover.width, (float)180/skin_cover.height);
            image(skin_cover, 0, 0);
          }
        } else {
          scale((float)180/skin_cover.width, (float)180/skin_cover.height);
          image(skin_cover, 0, 0);
        }
        popMatrix();
        a=a+1;
      }
      //chain(full 8)
      if (b<8) {
        pushMatrix();
        float x=-((float)ButtonX-1)*90+a*180;
        float y=-((float)ButtonY-1)*90+b*180;
        translate(x, y);
        if (mousePressed&&new Rect(x, y, 90, 90).includes(mouse2.x, mouse2.y)) {
          scale((float)180/skin_chainNext.width, (float)180/skin_chainNext.height);
          image(skin_chainNext, 0, 0);
        } else {
          if (b==0) {
            scale((float)180/skin_chainSelected.width, (float)180/skin_chainSelected.height);
            image(skin_chainSelected, 0, 0);
          } else {
            scale((float)180/skin_chain.width, (float)180/skin_chain.height);
            image(skin_chain, 0, 0);
          }
        }
        popMatrix();
      }
      b=b+1;
    }
    popMatrix();
    translate(-528, -90);
    mouse.sub(new PVector(-528, -90));
    scale(0.35F);
    mouse.mult(1/0.35F);
    pushMatrix();
    translate(-180, 0);
    if (mousePressed&&new Rect(-180, 0, 90, 90).includes(mouse.x, mouse.y)) {
      scale((float)180/skin_prevPressed.width, (float)180/skin_prevPressed.height);
      image(skin_prevPressed, 0, 0);
    } else {
      scale((float)180/skin_prev.width, (float)180/skin_prev.height);
      image(skin_prev, 0, 0);
    }
    popMatrix();
    if (mousePressed&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
      pushMatrix();
      if (play) {
        scale((float)180/skin_playPressed.width, (float)180/skin_playPressed.height);
        image(skin_playPressed, 0, 0);
      } else {
        scale((float)180/skin_pausePressed.width, (float)180/skin_pausePressed.height);
        image(skin_pausePressed, 0, 0);
      }
      popMatrix();
    } else {
      //if (mousePressed&&new Rect(0, 0, 90, 90).includes(mouse.x, mouse.y)) {
      pushMatrix();
      if (play) {
        scale((float)180/skin_play.width, (float)180/skin_play.height);
        image(skin_play, 0, 0);
      } else {
        scale((float)180/skin_pause.width, (float)180/skin_pause.height);
        image(skin_pause, 0, 0);
      }
      popMatrix();
      //}
    }
    pushMatrix();
    translate(180, 0);
    if (mousePressed&&new Rect(180, 0, 90, 90).includes(mouse.x, mouse.y)) {
      scale((float)180/skin_nextPressed.width, (float)180/skin_nextPressed.height);
      image(skin_nextPressed, 0, 0);
    } else {
      scale((float)180/skin_next.width, (float)180/skin_next.height);
      image(skin_next, 0, 0);
    }
    popMatrix();
    popMatrix();
    noStroke();
  }
  InnerDropArea getDropAreaItem(int x, int y) {
    int a=0;
    while (a<areas.size()) {
      if (areas.get(a).location.includes(x, y)) {
        return areas.get(a);
      }
      a=a+1;
    }
    return null;
  }
  class InnerDropArea {
    Rect location;//chaos of chaos!!
    PImage image;
    InnerDropArea(Rect location_, PImage image_) {
      location=location_;
      image=image_;
    }
    void setImage(PImage image_) {
      if (image==skin_appIcon) {
        skin_appIcon=image_;
      } else if (image==skin_themeIcon) {
        skin_themeIcon=image_;
      } else if (image==skin_btn) {
        skin_btn=image_;
      } else if (image==skin_btnPressed) {
        skin_btnPressed=image_;
      } else if (image==skin_chain) {
        skin_chain=image_;
      } else if (image==skin_chainSelected) {
        skin_chainSelected=image_;
      } else if (image==skin_chainNext) {
        skin_chainNext=image_;
      } else if (image==skin_play) {
        skin_play=image_;
      } else if (image==skin_playPressed) {
        skin_playPressed=image_;
      } else if (image==skin_pause) {
        skin_pause=image_;
      } else if (image==skin_pausePressed) {
        skin_pausePressed=image_;
      } else if (image==skin_prev) {
        skin_prev=image_;
      } else if (image==skin_prevPressed) {
        skin_prevPressed=image_;
      } else if (image==skin_next) {
        skin_next=image_;
      } else if (image==skin_nextPressed) {
        skin_nextPressed=image_;
      } else if (image==skin_background) {
        skin_background=image_;
      } else if (image==skin_cover) {
        skin_cover=image_;
      } else if (image==skin_coverMiddle) {
        skin_coverMiddle=image_;
      }
      image=image_;
    }
  }
  void maskImage1(color c) {//masks text1
    back=loadImage("skinback.png");
    back.loadPixels();
    for (int a=0; a<back.pixels.length; a++) {
      back.pixels[a]=color(red(c), green(c), blue(c), max(0, alpha(back.pixels[a])+alpha(c)-255));
    }
    back.updatePixels();
  }
}
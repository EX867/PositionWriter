//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/build/Build.java
//https://spin.atomicobject.com/2011/08/22/building-android-application-bundles-apks-by-hand/
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

void build_windows(String packageName, String appName, String author, String description, String themeName, color actionBar, color upperActionBar, color text) {
  try {
    String datapath="";
    if (DEVELOPER_BUILD) {
      datapath=new File(joinPath(DEVELOPER_PATH, "data")).getAbsolutePath();
    } else {
      datapath=new File("data").getAbsolutePath();
    }
    String buildPath=joinPath(GlobalPath, "Temp/"+appName);
    //create files for build.
    //packageName=com.kimjisub.launchpad.theme.customPackageName;
    surface.setTitle(title_filename+title_edited+title_suffix+" - creating build files...");
    String drawable=joinPath(buildPath, "src/main/res/drawable/");
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
    writeFile(joinPath(buildPath, "src/main/java/"+packageName.replace(".", "/")+"/MainActivity.xml"), build_generateMainActivity(packageName));
    EX_fileCopy(joinPath(datapath, "template/skin/xml_next.xml"), joinPath(buildPath, "src/main/res/drawable/xml_next.xml"));
    EX_fileCopy(joinPath(datapath, "template/skin/xml_prev.xml"), joinPath(buildPath, "src/main/res/drawable/xml_prev.xml"));
    EX_fileCopy(joinPath(datapath, "template/skin/xml_pause.xml"), joinPath(buildPath, "src/main/res/drawable/xml_pause.xml"));
    EX_fileCopy(joinPath(datapath, "template/skin/xml_play.xml"), joinPath(buildPath, "src/main/res/drawable/xml_play.xml"));
    EX_fileCopy(joinPath(datapath, "template/skin/activity_main.xml"), joinPath(buildPath, "src/main/res/layout/activity_main.xml"));
    writeFile(joinPath(buildPath, "src/main/res/values/colors.xml"), build_generateColors(actionBar, upperActionBar, text));
    writeFile(joinPath(buildPath, "src/main/res/values/styles.xml"), build_generateStyles());
    writeFile(joinPath(buildPath, "src/main/res/values/strings.xml"), build_generateStrings(appName, author, description, themeName));
    writeFile(joinPath(buildPath, "src/main/AndroidManifest.xml"), build_generateManifest(packageName));
    //Run AAPT
    surface.setTitle(title_filename+title_edited+title_suffix+" - running aapt...");
    List<String> cmd = new ArrayList<String>();
    cmd.add(joinPath(datapath, "builder")+"/aapt.exe");
    cmd.add("package");
    cmd.add("-v");
    cmd.add("-f");
    cmd.add("-m");
    cmd.add("-S");
    cmd.add("\""+joinPath(buildPath, "src/main/res")+"\"");
    cmd.add("-J");
    cmd.add(joinPath(buildPath, "gen"));
    cmd.add("-M");
    cmd.add("\""+joinPath(buildPath, "src/main/AndroidManifest.xml")+"\"");
    cmd.add("-I");
    cmd.add("\""+joinPath(GlobalPath, "Assets/android.jar")+"\"");
    /*cmd.add("-j");
     cmd.add("\""+joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar")+"\"");//android-support-v7-appcompat.jar*/
    cmd.add("-F");
    cmd.add("\""+joinPath(buildPath, "bin/"+appName+".apk.res")+"\"");
    ProcessBuilder builder = new ProcessBuilder(cmd);
    builder.redirectOutput(ProcessBuilder.Redirect.INHERIT);
    builder.redirectError(ProcessBuilder.Redirect.INHERIT);
    Process aaptProcess = builder.start();
    int code = aaptProcess.waitFor();
    if (code != 0) {
      surface.setTitle(title_filename+title_edited+title_suffix);
      System.err.println("AAPT exited with error code " + code);
      return;
    }
    //Run ECJ
    surface.setTitle(title_filename+title_edited+title_suffix+" - compiling...");
    Main main = new Main(new PrintWriter(System.out), new PrintWriter(System.err), false, null, null);
    String[] ecjArgs = {
      "-warn:-unusedImport", // Disable warning for unused imports
      "-extdirs", joinPath(datapath, "builder"), // The location of the external libraries
      "-bootclasspath", joinPath(datapath, "builder/android.jar"), // The location of android.jar
      "-classpath", joinPath(buildPath, "bin") // The location of the source folder
      + ":" + joinPath(buildPath, "gen"), // The location of the generated folder
      "-1.6", 
      "-target", "1.6", // Target Java level
      "-proc:none", // Disable annotation processors...
      "-d", joinPath(buildPath, "bin/classes"), // The location of the output folder
      joinPath(joinPath(buildPath, "src"), joinPath("main/java", packageName.replace(".", "/")+"/MainActivity.java")) // The location of the main activity
    };
    if (main.compile(ecjArgs)) {
      println("compile success!");
    } else {
      //We have some compilation errors
      println("Compilation with ECJ failed");
      surface.setTitle(title_filename+title_edited+title_suffix);
      return;
    }
    //Run DX Dexer
    surface.setTitle(title_filename+title_edited+title_suffix+" - dexing...");
    String[] dxArgs= new String[] {
      "--num-threads=1", 
      "--output=" + joinPath(buildPath, "bin/main-classes.dex"), //The output location of the sketch's dexed classes
      joinPath(buildPath, "bin/classes")//add "classes" to get DX to work properly
    };
    //This is some side-stepping to avoid System.exit() calls
    com.androidjarjar.dx.command.dexer.Main.Arguments dexArgs = new com.androidjarjar.dx.command.dexer.Main.Arguments();
    dexArgs.parse(dxArgs);
    int resultCode = com.androidjarjar.dx.command.dexer.Main.run(dexArgs);
    if (resultCode != 0) {
      System.err.println("DX Dexer result code: " + resultCode);
    }
    //Run DX Merger
    surface.setTitle(title_filename+title_edited+title_suffix+" - merging dex files...");
    if (new File(joinPath(datapath, "builder/android.jar")).isFile()==false) {//dex if no dex file.
      dexJar(joinPath(datapath, "builder/android.jar"), joinPath(datapath, "builder/android.dex"));
    }
    if (new File(joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar")).isFile()==false) {
      dexJar(joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar"), joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex"));
    }
    String[] args = new String[4];
    args[0] = joinPath(buildPath, "bin/classes.dex"); //The location of the output DEX class file
    args[1] = joinPath(buildPath, "bin/main-classes.dex"); //The location of the sketch's dexed classes
    //Apparently, this tool accepts as many dex files as we want to throw at it...
    args[2]=joinPath(datapath, "builder/android.dex");
    args[3]=joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex");
    com.androidjarjar.dx.merge.DexMerger.main(args);
    //Run APKBuilder
    surface.setTitle(title_filename+title_edited+title_suffix+" - building aspk...");
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
  }
  catch(Exception e) {
    surface.setTitle(title_filename+title_edited+title_suffix);
    e.printStackTrace();
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
      System.err.println("DX Dexer failed, error code: " + resultCode);
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
    "  <style name=\"AppTheme\" parent=\"Theme.AppCompat.Light.DarkActionBar\">"+
    "    <item name=\"colorPrimary\">@color/colorPrimary</item>"+
    "    <item name=\"colorPrimaryDark\">@color/colorPrimaryDark</item>"+
    "    <item name=\"colorAccent\">@color/colorAccent</item>"+
    "  </style>"+
    "</resources>";
  return ret;
}
String build_generateColors(color actionBar, color upperActionBar, color text) {
  String ret="<?xml version=\"1.0\" encoding=\"utf-8\"?>"+
    "<resources>"+
    "  <color name=\"colorPrimary\">#"+hex(actionBar).toUpperCase()+"</color>"+//default FF3F51B5
    "  <color name=\"colorPrimaryDark\">#"+hex(upperActionBar).toUpperCase()+"</color>"+//default FF303F9F
    "  <color name=\"colorAccent\">#FFFF4081</color>"+
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
    "import android.support.v7.app.AppCompatActivity;"+
    "import android.os.Bundle;"+
    "public class MainActivity extends AppCompatActivity {"+
    "    @Override"+
    "    protected void onCreate(Bundle savedInstanceState) {"+
    "        super.onCreate(savedInstanceState);"+
    "        setContentView(R.layout.activity_main);"+
    "    }"+
    "}";
  return ret;
}
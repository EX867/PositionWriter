//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/build/Build.java
//https://spin.atomicobject.com/2011/08/22/building-android-application-bundles-apks-by-hand/
import kellinwood.security.zipsigner.ZipSigner;
import com.android.sdklib.build.ApkBuilder;
import org.eclipse.jdt.internal.compiler.batch.Main;
import java.io.FilenameFilter;
class ThreadScanner implements Runnable {
  InputStream input;
  java.util.Scanner scanner;
  ArrayList<String> logs;
  boolean active;
  ThreadScanner(InputStream input_, ArrayList<String> logs_) {
    input=input_;
    scanner=new java.util.Scanner(input);
    active=true;
    logs=logs_;
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
        logs.add(line);
        try {
          Thread.sleep(1);
        }
        catch(InterruptedException e) {
        }
      }
    }
  }
}
//void build_windows(String packageName, String appName, String author, String description, String themeName, String themeVersion, color text) {
//  ((Logger)UI[getUIid("ERROR_LOG")]).logs.clear();
//  if (new java.io.File(joinPath(joinPath(GlobalPath, ExternalPath), "android.jar")).isFile()==false) {
//    displayLogError("You have to copy android.jar into \""+joinPath(joinPath(GlobalPath, ExternalPath), "android.jar")+"\" before building skin!");
//    return;
//  }
//  new Thread(new ThreadBuilder(packageName, appName, author, description, themeName, themeVersion, text)).start();
//}
//void build_windows(String packageName, String appName, String author, String description, String themeName, String themeVersion, color text) {
//  new Thread(new Runnable() {
//    color actionBar=color(0);
//    ArrayList<String> logs=null;//=new ArrayList<String>();//((Logger)UI[getUIid("ERROR_LOG")]).logs;
//    try {
//      String datapath=getDataPath();
//      String buildPath=joinPath(joinPath(GlobalPath, TempPath), appName);
//      surface.setTitle(title_filename+title_edited+title_suffix+" - deleting old files...");
//      logs.add("deleting old files...");
//      registerRender();
//      if (new File(buildPath).exists())deleteFile(buildPath);
//      surface.setTitle(title_filename+title_edited+title_suffix+" - creating files for build...");
//      logs.add("creating files for build...");
//      registerRender();
//      String drawable=joinPath(buildPath, "res/drawable/");
//      skin_appIcon.save(drawable+"appicon.png");
//      skin_themeIcon.save(drawable+"theme_ic.png");
//      skin_btn.save(drawable+"btn.png");
//      skin_btnPressed.save(drawable+"btn_.png");
//      skin_chain.save(drawable+"chain.png");
//      skin_chainSelected.save(drawable+"chain_.png");
//      skin_chainNext.save(drawable+"chain__.png");
//      skin_play.save(drawable+"play.png");
//      skin_playPressed.save(drawable+"play_.png");
//      skin_pause.save(drawable+"pause.png");
//      skin_pausePressed.save(drawable+"pause_.png");
//      skin_prev.save(drawable+"prev.png");
//      skin_prevPressed.save(drawable+"prev_.png");
//      skin_next.save(drawable+"next.png");
//      skin_nextPressed.save(drawable+"next_.png");
//      skin_background.save(drawable+"playbg.png");
//      skin_cover.save(drawable+"phantom.png");
//      skin_coverMiddle.save(drawable+"phantom_.png");
//      writeFile(joinPath(buildPath, "src/java/"+packageName.replace(".", "/")+"/MainActivity.java"), build_generateMainActivity(packageName));
//      copyFile(joinPath(datapath, "template/skin/xml_next.xml"), joinPath(buildPath, "res/drawable/xml_next.xml"));
//      copyFile(joinPath(datapath, "template/skin/xml_prev.xml"), joinPath(buildPath, "res/drawable/xml_prev.xml"));
//      copyFile(joinPath(datapath, "template/skin/xml_pause.xml"), joinPath(buildPath, "res/drawable/xml_pause.xml"));
//      copyFile(joinPath(datapath, "template/skin/xml_play.xml"), joinPath(buildPath, "res/drawable/xml_play.xml"));
//      copyFile(joinPath(datapath, "template/skin/activity_main.xml"), joinPath(buildPath, "res/layout/activity_main.xml"));
//      writeFile(joinPath(buildPath, "res/values/colors.xml"), build_generateColors(actionBar, text));
//      writeFile(joinPath(buildPath, "res/values/styles.xml"), build_generateStyles());
//      writeFile(joinPath(buildPath, "res/values/strings.xml"), build_generateStrings(appName, author, description, themeName));
//      writeFile(joinPath(buildPath, "AndroidManifest.xml"), build_generateManifest(packageName, themeVersion));
//      new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).getParentFile().mkdirs();
//      new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).createNewFile();
//      new File(joinPath(buildPath, "bin")).mkdirs();
//      new File(joinPath(buildPath, "bin/apk")).mkdirs();
//      //Run AAPT
//      surface.setTitle(title_filename+title_edited+title_suffix+" - running aapt...");
//      logs.add("running aapt...");
//      registerRender();
//      List<String> cmd = new ArrayList<String>();
//      cmd.add(joinPath(datapath, "externalF")+"/aapt.exe");
//      cmd.add("package");
//      cmd.add("-v");
//      cmd.add("-f");
//      cmd.add("-m");
//      cmd.add("-S");
//      cmd.add("\""+joinPath(buildPath, "res")+"\"");
//      cmd.add("-J");
//      cmd.add(joinPath(buildPath, "gen"));
//      cmd.add("-M");
//      cmd.add("\""+joinPath(buildPath, "AndroidManifest.xml")+"\"");
//      cmd.add("-I");
//      cmd.add("\""+joinPath(joinPath(GlobalPath, ExternalPath), "android.jar")+"\"");
//      /*cmd.add("-S");
//       cmd.add("\""+joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar")+"\"");*/
//      cmd.add("-F");
//      cmd.add("\""+joinPath(buildPath, "bin/"+appName+".apk.res")+"\"");
//      cmd.add("--generate-dependencies");
//      ProcessBuilder builder = new ProcessBuilder(cmd);
//      builder.redirectErrorStream(true);
//      Process aaptProcess = builder.start();
//      ThreadScanner scanner=new ThreadScanner(aaptProcess.getInputStream());
//      new Thread(scanner).start();
//      int code = aaptProcess.waitFor();
//      scanner.active=false;
//      scanner.close();
//      if (code != 0) {
//        System.err.println("AAPT exited with error code " + code);
//        throw new Exception("AAPT exited with error code "+code);
//      }
//      if (new File(joinPath(buildPath, "bin/"+appName+".apk.res")).exists()==false) {
//        throw new Exception(appName+".apk.res file is not created");
//      }
//      //Run ECJ
//      surface.setTitle(title_filename+title_edited+title_suffix+" - compiling...");
//      Main main = new Main(new PrintWriter(System.out), new PrintWriter(System.err), false, null, null);
//      String[] ecjArgs = {
//        "-warn:-unusedImport", // Disable warning for unused imports
//        "-extdirs", joinPath(datapath, "builder"), // The location of the external libraries
//        "-bootclasspath", joinPath(joinPath(GlobalPath, ExternalPath), "android.jar"), // The location of android.jar
//        "-classpath", joinPath(buildPath, "src"), // The location of the source folder
//        "-classpath", joinPath(buildPath, "gen"), // The location of the generated folder
//        "-1.6", 
//        "-target", "1.6", // Target Java level
//        "-proc:none", // Disable annotation processors...
//        "-d", joinPath(buildPath, "bin/classes"), // The location of the output folder
//        joinPath(joinPath(buildPath, "src"), joinPath("java", packageName.replace(".", "/")+"/MainActivity.java")) // The location of the main activity
//      };
//      if (main.compile(ecjArgs)) {
//        logs.add("Compile success!");
//        registerRender();
//      } else {
//        //We have some compilation errors
//        println("Compilation with ECJ failed");
//        surface.setTitle(title_filename+title_edited+title_suffix);
//        throw new Exception("Compilation with ECJ failed");
//      }
//      //Run DX Dexer
//      surface.setTitle(title_filename+title_edited+title_suffix+" - dexing...");
//      logs.add("Dexing source...");
//      registerRender();
//      String[] dxArgs= new String[] {
//        "--num-threads=1", 
//        "--output=" + joinPath(buildPath, /*"bin/main-classes.dex"*/"bin/classes.dex"), //The output location of the sketch's dexed classes
//        joinPath(buildPath, "bin/classes")//add "classes" to get DX to work properly
//      };
//      //This is some side-stepping to avoid System.exit() calls
//      com.androidjarjar.dx.command.dexer.Main.Arguments dexArgs = new com.androidjarjar.dx.command.dexer.Main.Arguments();
//      dexArgs.parse(dxArgs);
//      int resultCode = com.androidjarjar.dx.command.dexer.Main.run(dexArgs);
//      if (resultCode != 0) {
//        System.err.println("DX Dexer result code: " + resultCode);
//        throw new Exception("DX Dexer exited with code "+resultCode);
//      }
//      //Run DX Merger
//      //surface.setTitle(title_filename+title_edited+title_suffix+" - merging dex files...");
//      //if (new File(joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex")).isFile()==false) {
//      //  dexJar(joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar"), joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex"));
//      //}
//      //String[] args = new String[2];
//      //args[0] = joinPath(buildPath, "bin/classes.dex"); //The location of the output DEX class file
//      //args[1] = joinPath(buildPath, "bin/main-classes.dex"); //The location of the sketch's dexed classes
//      //Apparently, this tool accepts as many dex files as we want to throw at it...
//      //args[2]=joinPath(datapath, "builder/libs/android-support-v7-appcompat.dex");
//      //com.androidjarjar.dx.merge.DexMerger.main(args);
//      //Run APKBuilder
//      surface.setTitle(title_filename+title_edited+title_suffix+" - building apk...");
//      logs.add("building apk...");
//      registerRender();
//      //Create the builder with the basic files
//      ApkBuilder apkbuilder = new ApkBuilder(new File(joinPath(buildPath, "bin/" + appName + ".apk.unsigned")), //The location of the output APK file (unsigned)
//        new File(joinPath(buildPath, "bin/" + appName + ".apk.res")), //The location of the .apk.res file
//        new File(joinPath(buildPath, "bin/classes.dex")), //The location of the DEX class file
//        null, null //Only specify an output stream if we want verbose output
//        );
//      //Add everything else
//      apkbuilder.addSourceFolder(new File(joinPath(buildPath, "src"))); //The location of the source folder
//      //Seal the APK
//      apkbuilder.sealApk();
//      surface.setTitle(title_filename+title_edited+title_suffix+" - signing apk with default keystore...");
//      logs.add("signing apk with default keystore...");
//      registerRender();
//      String inFilename =joinPath(buildPath, "bin/" + appName + ".apk.unsigned");
//      String outFilename = joinPath(buildPath, "bin/apk/" + appName + ".apk");
//      ZipSigner signer = null;
//      signer=new ZipSigner();
//      signer.setKeymode("testkey");
//      try {
//        signer.signZip(inFilename, outFilename);
//      }
//      catch(Throwable t) {
//        t.printStackTrace();
//      }
//      logs.add("");
//      logs.add("Build success!");
//      registerRender();
//      surface.setTitle(title_filename+title_edited+title_suffix);
//    }
//    catch(Exception e) {
//      surface.setTitle(title_filename+title_edited+title_suffix);
//      displayError(e);
//      return;
//    }
//    openFileExplorer(joinPath(joinPath(joinPath(GlobalPath, TempPath), appName), "bin/apk/" ));//appName + ".apk"
//    registerRender();
//  }
//  ).start();
//}
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
String build_generateManifest(String packageName, String themeVersion) {
  String ret="<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+
    "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"\n"+
    "  package=\""+packageName+"\"\n"+
    "  android:versionName=\""+themeVersion+"\">\n"+
    "  <application\n"+
    "    android:allowBackup=\"true\"\n"+
    "    android:icon=\"@drawable/appicon\"\n"+
    "    android:label=\"@string/app_name\"\n"+
    "    android:supportsRtl=\"true\"\n"+
    "    android:theme=\"@style/AppTheme\">\n"+
    "    <activity android:name=\".MainActivity\">\n"+
    "      <intent-filter>\n"+
    "          <action android:name=\"android.intent.action.MAIN\" />\n"+
    "        <category android:name=\"android.intent.category.LAUNCHER\" />\n"+
    "      </intent-filter>\n"+
    "    </activity>\n"+
    "  </application>\n"+
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
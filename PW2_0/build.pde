//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/build/Build.java
//https://spin.atomicobject.com/2011/08/22/building-android-application-bundles-apks-by-hand/
import kellinwood.security.zipsigner.ZipSigner;
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
    scanner.close();
  }
  @Override void run() {
    String line="";
    while (input!=null&&line!=null&&active) {
      if (scanner.hasNextLine()) {
        line= scanner.nextLine();
        logs.addLine(line);
        try {
          Thread.sleep(10);
        }
        catch(InterruptedException e) {
        }
      }
    }
  }
}
void build_windows(final String packageName, final String appName, final String author, final String description, final String themeName, final String themeVersion, final color text) {
  new Thread(new Runnable() {
    public void run() {
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
        copyFile(joinPath(datapath, "external/skin/activity_main.xml"), joinPath(buildPath, "res/layout/activity_main.xml"));
        writeFile(joinPath(buildPath, "res/values/colors.xml"), build_generateColors(actionBar, text));
        writeFile(joinPath(buildPath, "res/values/styles.xml"), build_generateStyles());
        writeFile(joinPath(buildPath, "res/values/strings.xml"), build_generateStrings(appName, author, description, themeName));
        writeFile(joinPath(buildPath, "AndroidManifest.xml"), build_generateManifest(packageName, themeVersion));
        new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).getParentFile().mkdirs();
        new File(joinPath(buildPath, "gen/"+ packageName.replace(".", "/")+"/R.java")).createNewFile();
        new File(joinPath(buildPath, "bin")).mkdirs();
        new File(joinPath(buildPath, "bin/apk")).mkdirs();
        //Run AAPT
        logs.addLine("running aapt...").invalidate();
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
        cmd.add("\""+androidJarPath+"\"");
        /*cmd.add("-S");
         cmd.add("\""+joinPath(datapath, "builder/libs/android-support-v7-appcompat.jar")+"\"");*/
        cmd.add("-F");
        cmd.add("\""+joinPath(buildPath, "bin/"+appName+".apk.res")+"\"");
        cmd.add("--generate-dependencies");
        ProcessBuilder builder = new ProcessBuilder(cmd);
        builder.redirectErrorStream(true);
        Process aaptProcess = builder.start();
        ThreadScanner scanner=new ThreadScanner(aaptProcess.getInputStream(), logs);
        new Thread(scanner).start();
        int code = aaptProcess.waitFor();
        scanner.active=false;
        scanner.close();
        if (code != 0) {
          throw new Exception("AAPT exited with error code "+code);
        }
        if (new File(joinPath(buildPath, "bin/"+appName+".apk.res")).exists()==false) {
          throw new Exception(appName+".apk.res file is not created");
        }
        //Run ECJ
        logs.addLine("compiling...");
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
        logs.addLine("signing apk with default keystore...").invalidate();
        ZipSigner signer = null;
        signer=new ZipSigner();
        signer.setKeymode(ZipSigner.KEY_TESTKEY);
        signer.signZip(joinPath(buildPath, "bin/" + appName + ".apk.unsigned"), joinPath(buildPath, "bin/apk/" + appName + ".apk"));
        logs.addLine("Build success!\n").invalidate();
      }
      catch(Exception e) {
        logs.addLine("Build failed : \n\n"+addLinebreaks(e.toString(), 50)+"!\n").invalidate();
        return;
      }
      openFileExplorer(joinPath(joinPath(joinPath(path_global, "temp"), appName), "bin/apk/" ));//appName + ".apk"
    }
  }
  ).start();
}
//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/tool/ExportSignedPackage.java
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
    "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" \n"+
    "  package=\""+packageName+"\" \n"+
    "  android:versionName=\""+themeVersion+"\">\n"+
    "  android:versionCode=\"1\">\n"+
    "  <application\n"+
    "    android:allowBackup=\"true\"\n"+
    "    android:icon=\"@drawable/appicon\"\n"+
    "    android:label=\"@string/app_name\"\n"+
    //"    android:supportsRtl=\"true\"\n"+
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
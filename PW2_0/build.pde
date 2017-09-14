//https://github.com/Calsign/APDE/blob/master/APDE/src/main/java/com/calsignlabs/apde/build/Build.java
//https://spin.atomicobject.com/2011/08/22/building-android-application-bundles-apks-by-hand/
/*import com.android.sdklib.build.ApkBuilder;
 import org.eclipse.jdt.internal.compiler.batch.Main;
 
 void build(String srcPath, String buildPath) throws Exception {//Run AAPT
 try {
 System.out.println("Packaging resources with AAPT...");
 
 //Create folder structure for R.java TODO why is this necessary?
 (new File(genFolder.getAbsolutePath() + "/" + mainActivityLoc + "/")).mkdirs();
 
 String[] args = {
 aaptLoc.getAbsolutePath(), //The location of AAPT
 "package", "-v", "-f", "-m", 
 "-S", buildFolder.getAbsolutePath() + "/res/", //The location of the /res folder
 "-J", genFolder.getAbsolutePath(), //The location of the /gen folder
 "-A", assetsFolder.getAbsolutePath(), //The location of the /assets folder
 "-M", buildFolder.getAbsolutePath() + "/AndroidManifest.xml", //The location of the AndroidManifest.xml file
 "-I", androidJarLoc.getAbsolutePath(), //The location of the android.jar resource
 "-F", binFolder.getAbsolutePath() + "/" + sketchName + ".apk.res" //The location of the output .apk.res file
 };
 
 Process aaptProcess = Runtime.getRuntime().exec(args);
 
 int code = aaptProcess.waitFor();
 
 if (code != 0) {
 System.err.println("AAPT exited with error code " + code);
 
 cleanUpError();
 return;
 }
 
 if (verbose) {
 copyStream(aaptProcess.getErrorStream(), System.out);
 }
 } 
 catch (IOException e) {
 //Something weird happened
 System.out.println("AAPT failed");
 e.printStackTrace();
 
 cleanUpError();
 return;
 } 
 catch (InterruptedException e) {
 //Something even weirder happened
 System.out.println("AAPT failed");
 e.printStackTrace();
 
 cleanUpError();
 return;
 }
 
 if (!running.get()) { //CHECK
 cleanUpHalt();
 return;
 }
 
 editor.messageExt(editor.getResources().getString(R.string.run_ecj));
 
 //Run ECJ
 {
 System.out.println("Compiling with ECJ...");
 
 Main main = new Main(new PrintWriter(System.out), new PrintWriter(System.err), false, null, null);
 String[] args = {
 (verbose ? "-verbose"
 : "-warn:-unusedImport"), // Disable warning for unused imports (the preprocessor gives us a lot of them, so this is just a lot of noise)
 "-extdirs", libsFolder.getAbsolutePath(), // The location of the external libraries (Processing's core.jar and others)
 "-bootclasspath", androidJarLoc.getAbsolutePath(), //buildFolder.getAbsolutePath() + "/sdk/platforms/" + androidVersion + "/android.jar", // The location of android.jar
 "-classpath", srcFolder.getAbsolutePath() // The location of the source folder
 + ":" + genFolder.getAbsolutePath() // The location of the generated folder
 + ":" + libsFolder.getAbsolutePath(), // The location of the library folder
 "-1.6", 
 "-target", "1.6", // Target Java level
 "-proc:none", // Disable annotation processors...
 "-d", binFolder.getAbsolutePath() + "/classes/", // The location of the output folder
 srcFolder.getAbsolutePath() + "/" + mainActivityLoc + "/" + sketchName + ".java", // The location of the sketch file
 srcFolder.getAbsolutePath() + "/" + mainActivityLoc + "/" + MAIN_ACTIVITY_NAME, // The location of the main activity
 };
 
 if (verbose) {
 System.out.println("Compiling: " + srcFolder.getAbsolutePath() + "/" + mainActivityLoc + "/" + sketchName + ".java");
 }
 
 if (main.compile(args)) {
 System.out.println();
 } else {
 //We have some compilation errors
 System.out.println();
 System.out.println("Compilation with ECJ failed");
 
 cleanUpError();
 return;
 }
 }
 
 if (!running.get()) { //CHECK
 cleanUpHalt();
 return;
 }
 
 editor.messageExt(editor.getResources().getString(R.string.run_dx));
 
 //Run DX Dexer
 try {
 System.out.println("Dexing with DX Dexer...");
 
 String[] args;
 
 //Yuck, this is the best way to support verbose output...
 if (verbose ) {
 args = new String[] {
 "--verbose", 
 "--num-threads=" + numCores, 
 "--output=" + binFolder.getAbsolutePath() + "/sketch-classes.dex", //The output location of the sketch's dexed classes
 binFolder.getAbsolutePath() + "/classes/" //add "/classes/" to get DX to work properly
 };
 } else {
 args = new String[] {
 "--num-threads=" + numCores, 
 "--output=" + binFolder.getAbsolutePath() + "/sketch-classes.dex", //The output location of the sketch's dexed classes
 binFolder.getAbsolutePath() + "/classes/" //add "/classes/" to get DX to work properly
 };
 }
 
 //This is some side-stepping to avoid System.exit() calls
 
 com.androidjarjar.dx.command.dexer.Main.Arguments dexArgs = new com.androidjarjar.dx.command.dexer.Main.Arguments();
 dexArgs.parse(args);
 
 int resultCode = com.androidjarjar.dx.command.dexer.Main.run(dexArgs);
 
 if (resultCode != 0) {
 System.err.println("DX Dexer result code: " + resultCode);
 }
 } 
 catch(Exception e) {
 System.out.println("DX Dexer failed");
 e.printStackTrace();
 
 cleanUpError();
 return;
 }
 
 if (!running.get()) { //CHECK
 cleanUpHalt();
 return;
 }
 
 //Run DX Merger
 try {
 System.out.println("Merging DEX files with DX Merger...");
 
 File[] dexedLibs = dexedLibsFolder.listFiles(new FilenameFilter() {
 @Override
 public boolean accept(File dir, String filename) {
 return filename.endsWith("-dex.jar");
 }
 }
 );
 
 String[] args = new String[dexedLibs.length + 2];
 args[0] = binFolder.getAbsolutePath() + "/classes.dex"; //The location of the output DEX class file
 args[1] = binFolder.getAbsolutePath() + "/sketch-classes.dex"; //The location of the sketch's dexed classes
 
 //Apparently, this tool accepts as many dex files as we want to throw at it...
 for (int i = 0; i < dexedLibs.length; i ++) {
 args[i + 2] = dexedLibs[i].getAbsolutePath();
 }
 
 com.androidjarjar.dx.merge.DexMerger.main(args);
 } 
 catch (Exception e) {
 System.out.println("DX Merger failed");
 e.printStackTrace();
 
 cleanUpError();
 return;
 }
 
 if (!running.get()) { //CHECK
 cleanUpHalt();
 return;
 }
 
 editor.messageExt(editor.getResources().getString(R.string.run_apkbuilder));
 
 //Run APKBuilder
 try {
 System.out.println("Building APK file with APKBuilder...");
 
 //      String[] args = {
 //        binFolder.getAbsolutePath() + "/" + sketchName + ".apk.unsigned", //The location of the output APK file (unsigned)
 //        "-u",
 //        "-z", binFolder.getAbsolutePath() + "/" + sketchName + ".apk.res", //The location of the .apk.res file
 //        "-f", binFolder.getAbsolutePath() + "/classes.dex", //The location of the DEX class file
 //        "-z", glslFolder.getAbsolutePath(), //Location of GLSL files
 //        "-rf", srcFolder.getAbsolutePath() //The location of the source folder
 //      };
 //      
 //      com.android.sdklib.build.ApkBuilderMain.main(args);
 
 //Create the builder with the basic files
 ApkBuilder builder = new ApkBuilder(new File(binFolder.getAbsolutePath() + "/" + sketchName + ".apk.unsigned"), //The location of the output APK file (unsigned)
 new File(binFolder.getAbsolutePath() + "/" + sketchName + ".apk.res"), //The location of the .apk.res file
 new File(binFolder.getAbsolutePath() + "/classes.dex"), //The location of the DEX class file
 null, (verbose ? System.out : null) //Only specify an output stream if we want verbose output
 );
 
 //Add everything else
 builder.addZipFile(glslFolder); //Location of GLSL files
 builder.addSourceFolder(srcFolder); //The location of the source folder
 
 //Seal the APK
 builder.sealApk();
 } 
 catch(Exception e) {
 System.out.println("APKBuilder failed");
 e.printStackTrace();
 
 cleanUpError();
 return;
 }
 }*/
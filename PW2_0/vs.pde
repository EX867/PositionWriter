//version utils.pde
boolean DEBUG=true;
boolean DEVELOPER_BUILD=false;//detect with processing.exe
String DEVELOPER_PATH;
String VERSION="{\"type\"=\"production\",\"major\"=0,\"minor\"=0,\"patch\"=0,\"build\"=0,\"build_date\"=\"\"}";//type=beta or production
String startText="PositionWriter <major>.<minor> <type> [<build>] (<build_date> build)";//template for startText. see buildVersion() to get actual string.
void vs_detectProcessing() {
  File file=new File("");
  println("detectProcessing : "+file.getAbsolutePath());
  if (new File(joinPath(file.getAbsolutePath(), "processing.exe")).exists()) {//windows
    println("yes. this is processing build.");
    DEVELOPER_BUILD=true;
  }
  if (new File(joinPath(file.getAbsolutePath(), "processing")).exists()) {//linux
    println("yes. this is processing build.");
    DEVELOPER_BUILD=true;
  }
  if (DEVELOPER_BUILD) {
    DEVELOPER_PATH=dataPath("");
  }
}
void vs_loadBuildVersion() {
  JSONObject version=new JSONObject();
  version=parseJSONObject(VERSION);
  startText="PositionWriter "+version.getInt("major")+"."+version.getInt("minor")+" "+version.getString("type");
  if (version.getString("type").equals("beta")) {
    startText=startText+" "+version.getInt("build");
  }
  startText=startText+" ("+version.getString("build_date")+" build)";
}
void vs_checkVersion() {
  JSONObject version=new JSONObject();
  version=parseJSONObject(VERSION);
  try {
    String[] lines=loadStrings("https://EX867.github.io/PositionWriter/versionInfo");
    JSONObject beta=parseJSONObject(lines[2].replace("<p>", "").replace("</p>", ""));//fixed 3rd line
    JSONObject production=parseJSONObject(lines[3].replace("<p>", "").replace("</p>", ""));//fixed 4th line
    if (version.getString("type").equals("beta")) {//if production>=current->production, beta>=current->beta
      if (production.getInt("major")==version.getInt("major")) {//only compare if major is same.
        if ((production.getInt("minor")>version.getInt("minor"))||(production.getInt("minor")==version.getInt("minor")&&production.getInt("patch")>version.getInt("patch"))) {
          displayUpdatedScreen();
          return;
        }
      }
      if (beta.getInt("major")==version.getInt("major")) {//only compare if major is same.
        if (beta.getInt("minor")>version.getInt("minor")||(beta.getInt("minor")==version.getInt("minor")&&beta.getInt("patch")>version.getInt("patch"))||(beta.getInt("minor")==version.getInt("minor")&&beta.getInt("patch")==version.getInt("patch")&&beta.getInt("build")>version.getInt("build"))) {
          displayUpdatedScreen();
          return;
        }
      }
    } else if (version.getString("type").equals("production")) {//if production>=current->production
      if (production.getInt("major")==version.getInt("major")) {//only compare if major is same.
        if (production.getInt("minor")>version.getInt("minor")||(production.getInt("minor")==version.getInt("minor")&&production.getInt("patch")>version.getInt("patch"))) {
          displayUpdatedScreen();
          return;
        }
      }
    }
  }
  catch(Exception e) {
    //there is problem with internet, so ignore.
  }
}
void displayUpdatedScreen() {
}
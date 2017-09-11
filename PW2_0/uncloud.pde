HashMap<String, Uncloud_listItem> uncloudList=new HashMap<String, Uncloud_listItem>();
ArrayList<Uncloud_listitem> uncloudIndex=new ArrayList<Uncloud_listItem>();
String uncloud_pw;
String uncloud_userkey="";
int uncloud_limit=0;
int uncloud_used=0;
void loadKey() {
  uncloud_pw="...";
}
class Uncloud_listItem {
  public final int LOCAL=0;
  public final int REMOTE_ONLY=1;//add 1 on remote.
  public final int REMOTE_LATEST=2;//if found on local,add 1 to state.
  public final int REMOTE_OUTDATED=3;//if found on local and updated parameter is false, add 1 to state.
  String title;
  String date;
  String id;
  boolean published;
  //
  int state=0;
  boolean loadState=false;
  Analyzer.UnipackInfo info;
  public Uncloud_listItem(String title_, String date_, String id_, boolean published_) {
    title=title_;
    date=date_;
    id=id_;
    published=published_;
    state+=1;//make remote
    loadState=false;
  }
  public Uncloud_listItem(String title_) {
    title=title_;
    date="";
    id="";
    published=false;
    state=0;
  }
}
void uncloud_setup() {
  loadKey();
  //auto-login.
  ((TextBox)UI[getUIidRev("LOGIN_ID")]).text="";//#return
  ((TextBox)UI[getUIidRev("LOGIN_PASSWORD")]).text="";//#return
  //uncloud_login();
}
void uncloud_prepare() {//called on opening projects window
  uncloudList.clear();
  //get uncloud file list.
  if (uncloud_userkey.equals("")==false) {
    JSONObject send=new JSONObject();
    send.setString("tool_apikey", uncloud_pw);
    send.setString("key", uncloud_userkey);
    JSONObject response=post("https://uncloud.ga/3rdp-apis/list.php", send);
    if (response.getBoolean("result")) {
      uncloud_limit=int(response.getString("lim_size_max"));
      uncloud_used=int(response.getString("lim_size_used"));
      int count=int(response.getString("unipacks_count"));
      for (int a=1; a<=count; a++) {
        Uncloud_listItem item=new Uncloud_listItem(response.getString("unipack_title_"+a), response.getString("unipack_date_"+a), response.getString("unipack_id_"+a), response.getBoolean("unipack_public_"+a));
        uncloudIndex.add(item);
        uncloudList.put(response.getString("unipack_title_"+a), item);
      }
    } else {
      displayLogError(e);
    }
  }
  //scan Projects folder.
  //same name will be same unipack.
  File[] files=new File(joinPath(GlobalPath, ProjectsPath)).listFiles();
  for (int a=0; a<files.length; a++) {
    if (files[a].isDirectory()) {//check only info for validating unipack.
      File infof=new File(joinPath(files[a].getAbsoluteDirectory(), "info"));
      if (infof.isFile()) {
        Analyzer.UnipackInfo info=getUnipackInfo(infof.getAbsolutePath(), readFile(infof.getAbsolutePath()));
        if (uncloudList.containsKey(files[a].getName())) {
          uncloudList.get(files[a].getName()).path=files[a].getAbsolutePath().replace("\\", "/");
          uncloudList.get(files[a].getName()).state++;//make local and remote
          //check update state
          if (info.updated==false) {
            uncloudList.get(files[a].getName()).state++;//make outdated
          }
        } else {
          Uncloud_listItem item=new Uncloud_listItem(files[a].getName(), files[a].getAbsolutePath().replace("\\", "/"));
          item.info=info;
          item.loadState=true;
          uncloudIndex.add(item);
          uncloudList.put(files[a].getName(), item);
        }
      }
    }
  }
  uncloud_select(((ScrollList)UI[getUIidRev("UN_LIST")]).selected);
  renderLater();
}
void uncloud_select(int index) {//upload,update,delete,download
  UI[getUIidRev("UN_UPLOAD")].disabled=true;
  UI[getUIidRev("UN_UPDATE")].disabled=true;
  UI[getUIidRev("UN_DELETE")].disabled=true;
  UI[getUIidRev("UN_DOWNLOAD")].disabled=true;
  if (index==-1)return;
  if (uncloudList.get(index).state=Uncloud_listItem.LOCAL) {
    UI[getUIidRev("UN_UPLOAD")].disabled=false;
  } else if (uncloudList.get(index).state=Uncloud_listItem.REMOTE_ONLY) {
    UI[getUIidRev("UN_DELETE")].disabled=false;
    UI[getUIidRev("UN_DOWNLOAD")].disabled=false;
  } else if (uncloudList.get(index).state=Uncloud_listItem.REMOTE_LATEST) {
    UI[getUIidRev("UN_DELETE")].disabled=false;
    UI[getUIidRev("UN_DOWNLOAD")].disabled=false;
  } else if (uncloudList.get(index).state=Uncloud_listItem.REMOTE_OUTDATED) {
    UI[getUIidRev("UN_UPDATE")].disabled=false;
    UI[getUIidRev("UN_DELETE")].disabled=false;
    UI[getUIidRev("UN_DOWNLOAD")].disabled=false;
  }
}
void uncloud_login() {
  JSONObject send=new JSONObject();
  send.setString("tool_apikey", uncloud_pw);
  send.setString("id", ((TextBox)UI[getUIidRev("LOGIN_ID")]).text);
  send.setString("pass", ((TextBox)UI[getUIidRev("LOGIN_PASSWORD")]).text);
  JSONObject response=post("https://uncloud.ga/3rdp-apis/login.php", send);
  if (response.getBoolean("result")) {
    uncloud_userkey=response.getString("apikey");
  } else {
    displayLogError(e);
  }
}
void uncloud_upload(int index) {
  //this will open info file and change updated to true.
  JSONObject send=new JSONObject();
  send.setString("tool_apikey", uncloud_pw);
  send.setString("key", uncloud_userkey);
  send.setString("title", uncloudIndex.get(index).title);
  send.setString("unipack", readFile(uncloudIndex.get(index).path));
  JSONObject response=post("https://uncloud.ga/3rdp-apis/upload.php", send);
  if (response.getBoolean("result")) {
    uncloudIndex.get(index).state=Uncloud_listItem.REMOTE_LATEST;
    uncloudIndex.get(index).id=response.getString("unipack_id");
  } else {
    displayLogError(e);
  }
}
void uncloud_update() {
  uncloud_delete();
  uncloud_upload();
}
void uncloud_delete(int index) {
  if (uncloudIndex.get(index).id.equals("")) {//assertion
    displayLogError("uncloudIndex.get(index).id is not loaded!");
  }
  JSONObject send=new JSONObject();
  send.setString("tool_apikey", uncloud_pw);
  send.setString("key", uncloud_userkey);
  send.setString("id", uncloudIndex.get(index).id);
  JSONObject response=post("https://uncloud.ga/3rdp-apis/delete.php", send);
  if (response.getBoolean("result")) {
    //do nothing
  } else {
    displayLogError(e);
  }
}
void uncloud_getdetail() {
  if (uncloudIndex.get(index).id.equals("")) {//assertion
    displayLogError("uncloudIndex.get(index).id is not loaded!");
  }
  JSONObject send=new JSONObject();
  send.setString("tool_apikey", uncloud_pw);
  send.setString("key", uncloud_userkey);
  send.setString("id", uncloudIndex.get(index).id);
  JSONObject response=post("https://uncloud.ga/3rdp-apis/uploaded_detail.php", send);
  if (response.getBoolean("result")) {
    uncloudIndex.get(index).info=new Analyzer.UnipackInfo();
    uncloudIndex.get(index).info.title=response.getString("info_name");
    uncloudIndex.get(index).info.producerName=response.getString("info_producername");
    uncloudIndex.get(index).info.chain=response.getString("info_chain");
    uncloudIndex.get(index).info.buttonX=response.getString("info_x");
    uncloudIndex.get(index).info.buttonY=response.getString("info_y");
  } else {
    displayLogError(e);
  }
}
void uncloud_download() {
  if (uncloudIndex.get(index).id.equals("")) {//assertion
    displayLogError("uncloudIndex.get(index).id is not loaded!");
  }
  JSONObject send=new JSONObject();
  send.setString("tool_apikey", uncloud_pw);
  send.setString("key", uncloud_userkey);
  send.setString("id", uncloudIndex.get(index).id);
  JSONObject response=post("https://uncloud.ga/3rdp-apis/download.php", send);
  if (response.getBoolean("result")) {
    link(response.getString("url"));
  } else {
    displayLogError(e);
  }
}
JSONObject post(String url, JSONObject json) {
  try {
    URL url = new URL(url);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setDoOutput(true);
    conn.setUseCaches(false);
    conn.setRequestMethod("POST");
    conn.setRequestProperty("Content-Type", "application/json");
    conn.connect();
    DataOutputStream out = new DataOutputStream(conn.getOutputStream());
    printLog("send : "+json.toString());
    out.writeUTF(ret);
    out.flush();
    out.close();
    InputStream is = conn.getInputStream();
    Scanner scan = new Scanner(is);
    StringBuilder str=new StringBuilder();
    while (scan.hasNext()) {
      str.append(scan.nextLine()).append("\n");
    }
    printLog("recieve : "+str.toString();
    scan.close();
    return parseJSONObject(str.toString());
  } 
  catch (Exception e) {
    displayLogError(e);
  }
}
ArrayList<Uncloud_listItem> uncloudList=new ArrayList<Uncloud_listItem>();
class Uncloud_listItem {
  public final int LOCAL=0;
  public final int UPDATE_NEEDED=1;
  public final int UPDATED=2;
  String title;
  String date;
  String id;
  int state;
  boolean loadState=false;
  Analyzer.UnipackInfo info;
  public Uncloud_listItem() {
    loadState=false;
  }
}
void uncloud_setup() {
  //auto-login.
}
void uncloud_prepare() {//called on opening projects window
  uncloudList.clear();
  //scan Projects folder.
  File[] files=new File(joinPath(GlobalPath, ProjectsPath)).listFiles();
  for (int a=0; a<files.length; a++) {
    uncloudList.add(new Uncloud_listItem());
  }
  //get uncloud file list.
  //same name will be same unipack.
  //if unipack is only local, enable upload only.
  //if unipack is uploaded, enable delete, download
  //..if unipack is exported after last update, enable update.(update needed)
  //..if unipack is not exported after last update. disable else.(updated)
  //renderLater
}
//{“result”:”false”,  “reason”:”Not Authorized.”}
void uncloud_login() {//https://uncloud.ga/3rdp-apis/login.php
  //send : {tool_apikey,id,pass}
  //response : {result,apikey}
}
void uncloud_upload() {//https://uncloud.ga/3rdp-apis/upload.php
  //send : {tool_apikey,key,title,unipack}
  //response : {result,unipack_id}
  //this will open info file and change updated to false.
}
void uncloud_update() {
  uncloud_delete();
  uncloud_upload();
}
void uncloud_delete() {//https://uncloud.ga/3rdp-apis/delete.php
  //send : {tool_apikey,key,id}
  //response : {result}
}
void uncloud_getdetail() {//https://uncloud.ga/3rdp-apis/uploaded_detail.php
  //send : {tool_apikey,key,id}
  //response : {result,info_name,info_producername,info_chain,info_x,info_y}
}
void uncloud_download() {//https://uncloud.ga/3rdp-apis/download.php
  //send : {tool_apikey,key,id}
  //response : {result,url}
}
void uncloud_getlist() {//https://uncloud.ga/3rdp-apis/list.php
  //send : {tool_apikey,key}
  //response : {result,lim_size_max(byte),lim_size_used,unipacks_count,
  //  [unipack_title_n(1~),unipack_date_n(YYYY.MM.DD hour:min:sec UTC),unipack_id_n,unipack_public_n]}
}
void post(String url, JSONObject json) {
  //code later.
}
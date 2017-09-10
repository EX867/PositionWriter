import android.app.Activity; 
BackPressCloseHandler backPressCloseHandler;
	
public class BackPressCloseHandler {

	private long backKeyPressedTime = 0;

	private Activity activity;

	public BackPressCloseHandler(Activity context) {
		this.activity = context;
	}

	public void onBackPressed() {
		if (System.currentTimeMillis() > backKeyPressedTime + 2000) {
			backKeyPressedTime = System.currentTimeMillis();
  Log="press twice to exit";
  LogRead="";
			//showGuide();
			return;
		}
		if (System.currentTimeMillis() <= backKeyPressedTime + 2000) {
  writeTemporary ();
			activity.finish();
			//toast.cancel();
		}
	}
}
void initBackPress (){
		backPressCloseHandler = new BackPressCloseHandler(this);
}

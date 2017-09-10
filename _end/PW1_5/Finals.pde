long SAMPLEWAV_MAX_SIZE=(long)1024*1024*200;

char ON='o';
char OFF='f';
char DELAY='d';
char AUTO='a';
char FILENAME='n';
char BPM='b';
char RECENT_NUMBER_1='q';
char RECENT_NUMBER_2='w';

int AUTOSAVE_TIME=30000;
boolean SE_PAD_ENTERABLE=false;//FIX!!
boolean SE_ON_DELETABLE=true;
//language


final int LC_ENG=0;
final int LC_KOR=1;

final int AN_PRESS=0;
final int AN_PRESSED=1;
final int AN_RELEASE=2;
final int AN_RELEASED=3;

final int TAB_LED=0;
final int TAB_KEYSOUND=1;
final int TAB_INFO=2;
final int TAB_WAVCUTTER=3;
final int TAB_SETTINGS=8;
final int TAB_MACROS=4;

final int TAB_SETTINGS1=10;
final int TAB_SHORTCUTS=11;

final int VIEW_FILEVIEW=1;
final int VIEW_SOUNDVIEW=2;

final int DEFAULT=0;
final int AUTOINPUT=1;
final int CHAINMODE=2;
final int AUTOPLAY=3;

final boolean DS_HTML=true;
final boolean DS_VEL=false;

final String JF_ENG_NEXTFIND="next find ";
final String JF_KOR_NEXTFIND="\uB2E4\uC74C \uCC3E\uAE30 ";
final String NT_ENG_NEWVERSION="new version is found";
final String NT_ENG_LATEST="latest version";
final String NT_ENG_NOTCONNECTED="Can't connect with server";
final String NT_KOR_NOTCONNECTED="\uC11C\uBC84\uC5D0 \uC5F0\uACB0\uD560 \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.";

final String KE_ENG_FINDREPLACE="Toggle findReplace";
final String KE_KOR_FINDREPLACE="\uCC3E\uAE30";
final String KE_ENG_DISPLAY="Toggle Display";
final String KE_KOR_DISPLAY="\uC5D0\uB514\uD130";
final String KE_ENG_NOTUNDO="can't undo";
final String KE_KOR_NOTUNDO="\uB418\uB3CC\uB9B4 \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.";
final String KE_ENG_NOTREDO="can't redo";
final String KE_KOR_NOTREDO="\uB2E4\uC2DC\uD560 \uC218 \uC5C6\uC2B5\uB2C8\uB2E4.";
final String KE_ENG_EXPORT="exporting...";
final String KE_KOR_EXPORT="\uD30C\uC77C\uB85C \uCD9C\uB825\uD558\uB294 \uC911...";
final String KE_ENG_NOTEXPORT="error on exporting : ";
final String KE_KOR_NOTEXPORT="\uCD9C\uB825\uD558\uB294 \uC911 \uBB38\uC81C\uAC00 \uBC1C\uC0DD\uD588\uC2B5\uB2C8\uB2E4. : ";

final String EX_ENG_EXPORTED="export completed";
final String EX_KOR_EXPORTED="\uCD9C\uB825\uC774 \uC644\uB8CC\uB418\uC5C8\uC2B5\uB2C8\uB2E4.";
final String EX_ENG_NOTEXPORTED="incorrect syntax";
final String EX_KOR_NOTEXPORTED="\uC624\uB958\uAC00 \uC788\uC2B5\uB2C8\uB2E4.";
final String EX_ENG_SYNTAXINCORRECT="fix errors before export.";
final String EX_KOR_SYNTAXINCORRECT="\uD30C\uC77C\uB85C; \uB0B4\uBCF4\uB0B4\uAE30 \uC804\uC5D0 \uC624\uB958\uB97C \uACE0\uCCD0\uC57C";

final String DS_ENG_SETCHAIN="set chain to ";
final String DS_KOR_SETCHAIN="\uCCB4\uC778 ";

final String LX_ENG_ERR="error : line ";
final String LX_KOR_ERR="\uC624\uB958 : \uC904 ";
final String LX_ENG_READING="reading...";
final String LX_KOR_READING="\uC77D\uB294\uC911...";
final String LX_ENG_READCOMPLETE="read completed";
final String LX_KOR_READCOMPLETE="\uC77D\uAE30 \uC644\uB8CC";
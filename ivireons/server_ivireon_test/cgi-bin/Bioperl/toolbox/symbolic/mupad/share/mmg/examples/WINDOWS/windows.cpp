///////////////////////////////////////////////////////////////////////////////
// MODULE: windows.cpp - Windows Message Boxes and Utilities
///////////////////////////////////////////////////////////////////////////////

MMG(win32: coption="-EHsc" )
MMG(win64: coption="-EHsc" )

// It is necessary because we still support old Windows versions like Win98 
#define WINVER  0x0410

 #define _AFXDLL 
#include <afxdlgs.h>
#include <afxwin.h>

///////////////////////////////////////////////////////////////////////////////
#define CHECK_ARGS()           \
  MFnargsCheck( 2 );           \
  MFargCheck( 1, DOM_STRING ); \
  MFargCheck( 2, DOM_STRING )

#define DISPLAY(flags) \
  MessageBox(NULL, MFstring(MFarg(2)), MFstring(MFarg(1)), flags|MB_TOPMOST)

#define RETURN(value) \
  MFreturn( MFcopy(value) )

///////////////////////////////////////////////////////////////////////////////
MFUNC( beep, MCnop )
{
  MFnargsCheck(2);
  MFargCheck(1,DOM_INT);
  MFargCheck(2,DOM_INT);

  Beep( (DWORD) MFint(MFarg(1)), (DWORD) MFint(MFarg(2)) );

  MFreturn(MFcopy(MVnull));
} MFEND

///////////////////////////////////////////////////////////////////////////////
MFUNC( pause, MCnop )
{
  MFnargsCheck(1);
  MFargCheck(1,DOM_INT);

  Sleep( (DWORD) MFint(MFarg(1)) );

  MFreturn(MFcopy(MVnull));
} MFEND

///////////////////////////////////////////////////////////////////////////////
MFUNC( message, MCnop )
{ CHECK_ARGS();
  DISPLAY( MB_ICONINFORMATION );
  RETURN( MVnull );
} MFEND

MFUNC( warning, MCnop )
{ CHECK_ARGS();
  DISPLAY( MB_ICONWARNING | MB_OK );
  RETURN( MVnull );
} MFEND

MFUNC( error, MCnop )
{ CHECK_ARGS();
  DISPLAY( MB_ICONERROR | MB_OK );
  RETURN( MVnull );
} MFEND

MFUNC( question, MCnop )
{ CHECK_ARGS();
  int answer = DISPLAY( MB_ICONQUESTION | MB_YESNO );
  if( answer == IDCANCEL )
      RETURN( MVunknown );
  MFreturn( MFbool(answer==IDYES) );
} MFEND

MFUNC( box, MCnop )
{ MFnargsCheck( 3 );
  MFargCheck( 1, DOM_STRING );
  MFargCheck( 2, DOM_STRING );
  MFargCheck( 3, DOM_INT    );

  int answer = DISPLAY( MFint(MFarg(3)) );
  MFreturn( MFlong(answer) );
} MFEND

///////////////////////////////////////////////////////////////////////////////
MFUNC( alert, MCnop )
{ MFnargsCheckRange( 0, 1 );

  UINT beep = 0xFFFFFFFF; // just a beep on the computer speaker (no soundcard)

  if( MVnargs == 1 ) {
      if     ( MFisIdent(MFarg(1),"Message" ) ) beep = MB_OK;
      else if( MFisIdent(MFarg(1),"Warning" ) ) beep = MB_ICONWARNING;
      else if( MFisIdent(MFarg(1),"Error"   ) ) beep = MB_ICONERROR;
      else if( MFisIdent(MFarg(1),"Question") ) beep = MB_ICONQUESTION;
      else if( MFisInt  (MFarg(1)) )            beep = (UINT) MFint(MFarg(1));
      else MFerror( "Invalid argument" );
  }
  MessageBeep( beep );

  MFreturn( MFcopy(MVnull) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
MFUNC( selectFile, MCnop )
{ MFnargsCheck( 0 );

  OPENFILENAME  OpenFileName;
  char          SaveFileName[1024] = "noname";

  memset( &OpenFileName, 0,      sizeof(OpenFileName) );
  OpenFileName.lStructSize     = sizeof(OpenFileName);
  OpenFileName.lpstrFile       = SaveFileName;
  OpenFileName.nMaxFile        = sizeof(SaveFileName);
  OpenFileName.lpstrTitle      = "Select a file";
  OpenFileName.lpstrFilter     = "*.*\0*.*\0";
  OpenFileName.lpstrFileTitle  = '\0';
  OpenFileName.Flags           = OFN_FILEMUSTEXIST|OFN_HIDEREADONLY;

  if( GetOpenFileName(&OpenFileName) ) {
      MFreturn( MFstring(OpenFileName.lpstrFile) );
  } else {
      MFreturn( MFstring("") );
  }
} MFEND

///////////////////////////////////////////////////////////////////////////////
MFUNC( clipboard, MCnop )
{ MFnargsCheck( 0 );

  if( !OpenClipboard(NULL) )
      MFerror( "Cannot open clipboard" );

  if( !IsClipboardFormatAvailable(CF_TEXT) )
      MFerror( "Select a text first" );

  HANDLE data = GetClipboardData( CF_TEXT );
  if( data == NULL )
      MFerror( "Cannot read cipboard data" );

  MTcell strg = MFstring( (char*) data );
  CloseClipboard();

  MFreturn( strg );
} MFEND

///////////////////////////////////////////////////////////////////////////////
MFUNC( winHelp, MCnop )
{ MFnargsCheck( 3 );
  MFargCheck( 1, DOM_STRING ); // path
  MFargCheck( 2, DOM_IDENT  ); // command
  MFargCheck( 3, DOM_STRING ); // data

  UINT cmd = HELP_INDEX;

  if     ( MFisIdent(MFarg(2),"Index"      ) ) cmd = HELP_INDEX;
  else if( MFisIdent(MFarg(2),"Key"        ) ) cmd = HELP_KEY;
  else if( MFisIdent(MFarg(2),"PartialKey" ) ) cmd = HELP_PARTIALKEY;
  else if( MFisIdent(MFarg(2),"Contents"   ) ) cmd = HELP_CONTENTS;
  else if( MFisIdent(MFarg(2),"Finder"     ) ) cmd = HELP_FINDER;
  else if( MFisIdent(MFarg(2),"Quit"       ) ) cmd = HELP_QUIT;
  else                                         MFerror("Invalid option" );

  DWORD data = (DWORD) MFstring( MFarg(3) );

  int ok = WinHelp( NULL, MFstring(MFarg(1)), cmd, data );

  MFreturn( MFbool(ok) );
} MFEND

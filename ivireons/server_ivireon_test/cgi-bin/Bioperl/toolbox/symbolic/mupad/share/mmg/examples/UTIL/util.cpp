///////////////////////////////////////////////////////////////////////////////
// MODULE: util - A collection of utilities
///////////////////////////////////////////////////////////////////////////////

MMG( info = "Module: A collection of utilities" )
MMG( win32: loption = "advapi32.lib" )
MMG( win64: loption = "advapi32.lib" )

///////////////////////////////////////////////////////////////////////////////
#ifdef WIN32
#  include <windows.h>
#endif

#include <time.h>
#include "MTBproc.h"                    // Module ToolBox for ´porcess´ support
#include "MTBfile.h"                    // Module ToolBox for ´file´ support
 

///////////////////////////////////////////////////////////////////////////////
MFUNC( time, MCnop )
{ MFnargsCheck( 0 );
  MFreturn( MFlong((long) time(NULL)) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
MFUNC( date, MCnop )
{ MFnargsCheck( 0 );

  time_t clock;
  time( &clock );

  char *string = ctime(&clock);
  string[24] = '\0';

  MFreturn( MFstring(string) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
MFUNC( busyWaiting, MCnop )
{ MFnargsCheck( 1 );
  MFargCheck  ( 1, DOM_INT );

    unsigned long sec = (unsigned long) MFlong( MFarg(1) );
    if( sec < 0L || sec > 60*60*24L ) 
        MFerror( "Integer is out of range 0..86400" );

    unsigned long   t1, t2;
    // 64Bit Windows: sizeof(int)<>sizeof(size_t)
    for( t1 = t2 = static_cast<unsigned long>(time(NULL)); (t2-t1) < sec; 
	 t2 = static_cast<unsigned long>(time(NULL)) ) ;
    MFreturn( MFcopy(MVnull) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
MFUNC( sleep, MCnop )
{ MFnargsCheck( 1 );
  MFargCheck  ( 1, DOM_INT );

  unsigned long sec = (unsigned long) MFlong( MFarg(1) );
  if( sec < 0L || sec > 60*60*24UL )   
      MFerror( "Integer is out of range 0..86400" );

#if   (defined MACINTOSH)
    MFerror( "Sorry, not supported on this platform" );
#elif (defined WIN32)
    Sleep( sec*1000UL );
#else
    sleep( sec );
#endif

    MFreturn( MFcopy(MVnull) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
MFUNC ( userName, MCnop )
{ MFnargsCheck( 0 );

  char *user = MFprocUserName();  
  if( user == NULL ) 
      MFerror( "Not supported for this operating system" );

  MFreturn( MFstring(user) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
MFUNC ( kernelPid, MCnop )
{ MFnargsCheck( 0 );
  MFreturn( MFlong(MFprocId()) );
} MFEND

///////////////////////////////////////////////////////////////////////////////
MFUNC ( kernelPath, MCnop )
{ MFnargsCheck( 0 );
  MFreturn( MFstring(MUPV_env.progName) );
} MFEND

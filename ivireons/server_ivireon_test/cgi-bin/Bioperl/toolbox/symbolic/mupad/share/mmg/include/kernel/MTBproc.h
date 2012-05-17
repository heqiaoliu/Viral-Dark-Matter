///////////////////////////////////////////////////////////////////////////////
// Part of the MuPAD product code. Protected by law. All rights reserved.
// TOOLBOX : MTBproc.h
// CONTENTS: Support of processes, signals, interrupts in dynamic modules
//
// This header file contains extension of the MuPAD Application Programming
// Interface (MAPI)  and facilitates the  development of dynamic modules in
// MuPAD. This file must only refer to MuPAD objects listed in  ´MDM_mod.h´
// and ´MKT_mapi.h´.
//
// This file requires to link the library 'advapi32.lib' on Windows 95/98/NT.
///////////////////////////////////////////////////////////////////////////////

#if   (defined MACINTOSH)
#elif (defined WIN32)
#  undef getpid
#  include <windows.h>
#  include <process.h>
#else
#endif


///////////////////////////////////////////////////////////////////////////////
// CONS: MC
// DESC: Specifies maximal length of a pathname. This constant can be
//       used to specify the length of character string buffers.
///////////////////////////////////////////////////////////////////////////////
//#define MC*


///////////////////////////////////////////////////////////////////////////////
// CONS: MVprocKernelName
// DESC: Specifies the variable which stores the name of the MuPAD kernel.
///////////////////////////////////////////////////////////////////////////////
#define MVprocKernelName    MUPV_env.progName


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFprocId
// ARGS: -
// DESC: Returns the process id of the kernel process. On operating systems
//       which do not support this feature, the value zero ´0´ is returned.
///////////////////////////////////////////////////////////////////////////////
inline int MFprocId()
{
#if   (defined MACINTOSH)
    return( 0 );
#elif (defined WIN32)
    return( getpid() );
#else
    return( getpid() );
#endif
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFprocSetSignalHandler
// ARGS: signum  - number of a signal
//       handler - signal handler
// DESC: Installs a new signal handler for the signal with number signum.
//       The signal handler is set to handler which may be a user speci-
//       fied function, or  SIG_IGN (=ignore) or  SIG_DFL (=default). On
//       operating systems which do not support UNIX style signals,  the
//       routines is just a dummy.
///////////////////////////////////////////////////////////////////////////////
inline void MFprocSetSignalHandler( int signum, void (*handler)(int) )
{
#if   (defined MACINTOSH)
#elif (defined WIN32)
#else
    MUP_setsig( signum, handler );
#endif
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFprocCatchError
// ARGS: -
// DESC: Calls the default error handler of the MuPAD kernel.
///////////////////////////////////////////////////////////////////////////////
inline void MFprocCatchError()
{
    MUP_catch_system_error();
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFprocFatalError
// ARGS: format      - a format string (refer to printf)
//       Mva_arglist - all values refered in ´format´
// DESC: Prints a fatal error message. This routine does not use the MuPAD
//       memory management and thus can be used in interrupt handlers etc.
///////////////////////////////////////////////////////////////////////////////
inline void MFprocFatalError ( char *format Mva_arglist )
{ char buffer[4096+1];

  Mva_start( args, format );
  vsprintf ( buffer, format, args );
  Mva_end( args );

  MFputsRaw( buffer );
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFprocUserName
// ARGS: -
// DESC: Returns the user name of the kernel process. On operating systems
//       which do not support this feature, the value "user"  is returned.
//       The function returns the value NULL if the user name could not be
//       determined.
///////////////////////////////////////////////////////////////////////////////m
inline char* MFprocUserName()
{
#if   (defined MACINTOSH)

  return( "user" );

#elif (defined WIN32)

  static char buffer[128+1];
  DWORD       size = 128;
  if( ! GetUserName (buffer,&size) )
      return( "user" );
  return( buffer );

#else
  return( getlogin() );                              // UNIX, SYSV compatible
#endif
}


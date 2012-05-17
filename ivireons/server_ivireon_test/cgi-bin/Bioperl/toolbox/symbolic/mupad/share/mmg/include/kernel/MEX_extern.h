
/**************************************************************************/
/* FILE   : MEX_extern.h                                                  */
/*                                                                        */
/* This file includes important non-MuPAD header files.   Many of them    */
/* strongly depend on the operating system on which MuPAD is compiled.    */
/* If possible, do not include any non-MuPAD header files in other C++    */
/* kernel source file but this.                                           */
/*                                                                        */
/* THIS FILE IS ALSO COMPILED WITH ANSI-C COMPILERS. TO NOT USE ANY C++   */
/* SPECIFIC STATEMENTS OR COMMENTS!!!!                                    */
/*                                                                        */
/**************************************************************************/

#ifndef __MEX_extern__
#define __MEX_extern__

/* Note that some tools are still compiled using an ANSI C compiler *******/

#ifdef SGI6  // dirty hack!!!
   // Using the g++ 2.8.1 on SGI6 there is a conflict between multiple
   // definitions of 'initstate' which cannot be solved by changing the
   // include paths
#  define initstate MUFFinitstateMUFF
#  include <math.h>
#  undef initstate
#endif

#if (defined __cplusplus) && (!defined C_PLUSPLUS)
#   define C_PLUSPLUS
#endif

#ifdef C_PLUSPLUS
#  include <stdlib.h>
#  ifdef SGI
#     include <new.h>
#  else
      // std::... should be only defined in new, NOT in new.h
#     include <new>
#  endif
#else
#  if !(defined sequent || defined __FreeBSD__ || defined __NetBSD__ || defined NEXTX86)
#      include <malloc.h>
#   endif
#endif

/* Which kind of header files are needed? *********************************/

#ifdef MEXDALL
#  ifndef MEXDSTANDARD
#    define MEXDSTANDARD
#  endif
#endif

/* MEXDSTANDARD ***********************************************************/

#if  (defined MEXDSTANDARD) && (!defined MEXDSTANDARD_WAS_READ_BEFORE)
#define MEXDSTANDARD_WAS_READ_BEFORE

/* Standard header files for all operating systems **************/

#include <assert.h>
#include <ctype.h>
#include <signal.h>
#include <stdio.h>

/* Standard header file for using threads *************/

#ifdef MMMDTHREAD
#   include <thread.h>
#endif 

/* Standard header files for WIN32 (no GNU Compiler!) ***********/

#if ((defined WIN32) && (!defined __GNUC__))
#  include <stdlib.h>
#  include <string.h>
#  include <time.h>
#ifndef NO_IO_HEADER // qhull has its own io.h - but we don't need the standard io.h in that module, fortunately
#  include <io.h>
#endif
#  include <sys\stat.h>
#  include <sys\types.h>

/* Standard header files for EMX architectures ******************/

#elif (defined __EMX__)
#  include <errno.h>
#  include <sys/times.h>
#  include <sys/ioctl.h>
#  include <sys/termio.h>
#  include <sys/kbdscan.h>

/* Standard header files for UNIX operating systems *************/

#else /* UNIX */
#  include <errno.h>
#  include <sys/stat.h>
#  include <sys/time.h>
#  include <unistd.h>

/* Standard header files special to IBM/RS6000/AIX ****/

#  if defined RS6000
#    include <time.h>

/* Standard header files special to DEC/ALPHA/OSF *****/

#  elif defined OSF
#    include <standards.h>
#    include <stdlib.h>
#    include <string.h>

/* Standard header files special to Sequent Symmetry **/

#  elif defined sequent
#    include <strings.h>

/* Standard header files special to UTLRIX ************/

#  elif defined ULTRIX

/* Standard header files special to some UNIX systems */

#  else
#    include <string.h>
#    include <stdlib.h>
#    include <sys/param.h>
#    include <sys/types.h>
#  endif

#endif /* UNIX */

#endif /* MEXDSTANDARD */


/********* Konstanten und Funktionsdeklarationen *************************/

/* This macro specifies that a function does not return. */
/* Currently has an effect for gcc only. */
#ifdef __GNUC__
#  define MUPC_NORETURN  __attribute__ ((noreturn))
#else
#  define MUPC_NORETURN
#endif

/* We do not want operator new to throw an exception */
#ifdef C_PLUSPLUS
#  ifdef SOLARIS
#    define MUPC_NEW new
#    define MUPC_DELETE delete
#  else
#    define MUPC_NEW new(std::nothrow)
#    define MUPC_DELETE delete
#    ifdef WIN32
// VC++ defines no operator delete(std::nothrow), thus...
inline void __cdecl operator delete(void * ptr, const std::nothrow_t&) throw()
    { ::operator delete(ptr); }
#    endif
#  endif
#endif

#if defined NEXTX86
char    *strdup(const char *s);         /* Gibts auf'm Mac nur "von Hand" */
#endif /* NEXTX86 */


#endif /* __MEX_extern__ */

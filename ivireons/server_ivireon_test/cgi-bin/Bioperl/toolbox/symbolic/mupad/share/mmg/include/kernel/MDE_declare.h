/**************************************************************************
** Part of the MuPAD product code. Protected by law. All rights reserved.**
**                          MDE_declare.h                                **
** In diesem File werden die Konstanten von MuPAD deklariert bzw. defi-  **
** niert, die nicht mit 3 gro\3en Buchstaben anfangen, sowie Makros zur  **
** Anpassung der Sourcen auf C++ bzw. auf bestimmte Compilertypen.       **
**************************************************************************/

#ifndef __MDE_declare__
#define __MDE_declare__

#include <stdio.h>
#include "MUP_constants.h"

// Die Funktion 'isSecureFileAccess' muss verwendet werden, wenn auf
// Dateien zugegriffen wird, deren Namen oder Inhalt der Anwender be-
// einflussen kann. Sie liefert entweder 'true' oder löst direkt ein-
// en Fehler aus.
bool MUT_isSecureFileAccess ( const char *filename, const char *type );

#include "MCO_compat.h"

#ifdef C_PLUSPLUS
#   ifndef __cplusplus
#   define __cplusplus
#   endif
#   ifndef ANY_ARGS
#   define ANY_ARGS ...
#   endif
#   define MDE_externCstart extern "C" {
#   define MDE_externCend }
# else
#   ifndef ANY_ARGS
#   define ANY_ARGS
#   endif
#   define MDE_externCstart
#   define MDE_externCend
#endif /* C_PLUSPLUS */

#if ( defined SOLARIS || defined SOLARIS_i86 || defined RS6000 || defined SGI || defined __linux__ || defined sequent || defined HP )
#   ifndef SYSV
#   define SYSV
#   endif
#endif

#   if ( defined ULTRIX )             /* hack fuer unsere DECstation maspar */
#      include "/usr/local/gnu/gcc/lib/gcc-lib/mips-dec-ultrix4.3/2.7.2/include/stdarg.h"
#      define NOCONST                            /* not yet implemented :-) */
#   else
#      include <stdarg.h> /* auf einigen BSD-Systemen auch varargs.h */
#   endif

#   define Mva_arglist ,...
#   define Mva_decl
typedef va_list Mva_list ;
#   define Mva_start(var,lastarg) va_list var ; \
                                  va_start(var, lastarg) ;
#   define Mva_arg(var,T) va_arg(var,T)
#   define Mva_end(var)  va_end(var)

#   ifndef CONST
#      if ( ! defined NOCONST )
#         define CONST  const
#      else
#         define CONST
#      endif
#   endif

#   define REGISTER     register

/* Funktionen zum Signal-Handling */

#if defined SGI
#   define MUP_setsig(_sig,_fun) sigset( _sig, (void(*)(ANY_ARGS)) _fun )

#elif defined SYSV && !defined __linux__ && !defined HP && !defined __EMX__

#   define MUP_setsig(_sig,_fun) sigset( _sig, (void(*)(int)) _fun )
#else
#   if defined __GNUC__ && __GLIBC__ && __linux__
#      include <signal.h>
#      define MUP_setsig(_sig,_fun) __sysv_signal( _sig, (void(*)(int)) _fun )
#   elif defined __GNUC__
#      define MUP_setsig(_sig,_fun) signal( _sig, (void(*)(int)) _fun )
#   elif defined C_PLUSPLUS && !defined HP && !defined WIN32
#      define MUP_setsig(_sig,_fun) signal( _sig, (SIG_PF) _fun )
#   else
#      define MUP_setsig(_sig,_fun) signal( _sig, (void(*)(int)) _fun )
#   endif
#endif

/* Verwaltung globaler Variable */

#   define GLOBAL_DECL(Typ,Name) extern Typ Name
#   define GLOBAL_DEF(Typ,Name) Typ Name
#   define GLOBAL_READ(Name) Name
#   define GLOBAL_WRITE(Name,value) ( Name = value )

#   define VALUE_READ(Name) Name

#endif /* __MDE_declare__ */

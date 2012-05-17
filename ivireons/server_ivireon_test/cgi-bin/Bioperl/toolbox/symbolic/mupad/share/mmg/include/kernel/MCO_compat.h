// **********************************************************************
// Part of the MuPAD product code. Protected by law. All rights reserved.
// FILE : MCO_compat.h
//
// Definitionen einiger elementarer Datentypen, um die Kompatibilität
// zwischen unterschiedlichen C++ Compilern sicher zu stellen.
// Diese Headerdatei kann derzeit unter folgenden Betriebssystemen
// eingesetzt werden (hier wurde es getestet):
//    SPARC/Solaris 2.5
//    PC/Linux 2.0
// **********************************************************************

#ifndef __MCO_compat__
#define __MCO_compat__

// Anpassung an Suns C++ Compiler
#if defined __SUNPRO_CC || defined RS6000 || defined SGI5
typedef char bool;
#ifndef true
#define true (1)
#endif
#ifndef false
#define false (0)
#endif
#endif // __SUNPRO_CC

#endif // __MCO_compat__

///////////////////////////////////////////////////////////////////////////////
// MODULE : cmath - Computing with machine floating point numbers 
// CHANGED: 24.Oct.2003 
///////////////////////////////////////////////////////////////////////////////

MMG( info = "Module: Computing with machine floating point numbers" ) 

#include "math.h"

// Macro for calling math routines with one parameter /////////////////////////

#define MATHFUNCCALL1( UFUNC )                                                \
{                                                                             \
  double value;                                                               \
                                                                              \
  MFnargsCheck(1);                                                            \
                                                                              \
  if( MFisIdent(MFarg(1),"PI") )                                              \
      value = 3.1415926535897932384;                                          \
  else if( MFisIdent(MFarg(1),"E") )                                          \
      value = 2.7182818284590452354;                                          \
  else if( MFisInt(MFarg(1)) || MFisRat(MFarg(1)) || MFisFloat(MFarg(1)) )    \
      value = MFdouble(MFarg(1));                                             \
  else                                                                        \
      MFreturn( MFcopy(MVargs) );                                             \
	                                                                      \
  MFreturn(MFdouble( UFUNC(value) ));                                         \
}

// Module function interface for math routines with one parameter /////////////

MFUNC( cacos,   MCnop ) { MATHFUNCCALL1(acos  ) } MFEND
MFUNC( casin,   MCnop ) { MATHFUNCCALL1(asin  ) } MFEND
MFUNC( catan,   MCnop ) { MATHFUNCCALL1(atan  ) } MFEND
MFUNC( ccos,    MCnop ) { MATHFUNCCALL1(cos   ) } MFEND
MFUNC( ccosh,   MCnop ) { MATHFUNCCALL1(cosh  ) } MFEND
MFUNC( cexp,    MCnop ) { MATHFUNCCALL1(exp   ) } MFEND
MFUNC( clog,    MCnop ) { MATHFUNCCALL1(log   ) } MFEND
MFUNC( clog10,  MCnop ) { MATHFUNCCALL1(log10 ) } MFEND
MFUNC( csin,    MCnop ) { MATHFUNCCALL1(sin   ) } MFEND
MFUNC( csinh,   MCnop ) { MATHFUNCCALL1(sinh  ) } MFEND
MFUNC( csqrt,   MCnop ) { MATHFUNCCALL1(sqrt  ) } MFEND
MFUNC( ctan,    MCnop ) { MATHFUNCCALL1(tan   ) } MFEND
MFUNC( ctanh,   MCnop ) { MATHFUNCCALL1(tanh  ) } MFEND


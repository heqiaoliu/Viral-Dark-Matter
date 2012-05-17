/******************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved.     */
/* FILE   : MKT_mapi.h                                                        */
/* DESCRIB: Defines the MuPAD Application Programming Interface. Also refer   */
/*          the files 'MKT_func.h' and 'MDM_mod.h' and the program 'mapi'.    */
/******************************************************************************/

#ifndef __mapi__
#define __mapi__

#include "MKT_func.h"                          /* depends on MDMD_USE_DYNLINK */
#include "MDM_kern.h"                          /* must be loaded in any case  */

#ifdef MDMD_USE_DYNLINK
#  include "MCA_calc.h"                        /* long number arithmetic is special  */
#endif

/******************************************************************************/
/*** Toolbox - Kernel Object Adress Table Mapping Macros **********************/
/******************************************************************************/
#if defined ISMODULE && !defined MDMD_USE_DYNLINK && !defined MUPD_USE_STALINK
#   define MDM_MAPI   0                              /* #( reserved entries ) */
#   include "MDM_mod.h"
#endif

/******************************************************************************/
/*** Toolbox - constants ******************************************************/
/******************************************************************************/

/*** Boolean "C" constants ****************************************************/

#define MCfalse      ( (MTbool) MUPC_constants_CAT_BOOL_FALSE   )
#define MCunknown    ( (MTbool) MUPC_constants_CAT_BOOL_UNKNOWN )
#define MCtrue       ( (MTbool) MUPC_constants_CAT_BOOL_TRUE    )
#define MCfail       ( (MTbool) MUPC_constants_CAT_FAILED       )

/*** Constants to control MF service functions ********************************/

#define MCall        -1                                  /* must be negative! */
#define MCnone       -2                                  /* must be negative! */
#define MCthis       -3                                  /* must be negative! */
#define MCcopy       -4
#define MCaddr       (-5)

/*** Function control: kind of evaluation, remember table, special options ****/

#define MCnop          0      /* No Operation / Option                  ----- */
#define MChold         1      /* No evaluation of Arguments             Bit-0 */
#define MCremember     2      /* Function uses remember table           Bit-1 */
#define MCnoeval       4      /*                                        Bit-2 */
#define MChidden       8      /* Hidden module function                 Bit-3 */
#define MCstatic      16      /* Unremovable module function            Bit-4 */
#define MCdefault  MCnop      /* Default options                        Bit-? */

/*** Constants for special type classes used for MFargCheck() *****************/

#define MCinteger       -1
#define MCnumber        -2
#define MCchar          -3

/*** The NULL element of the memory management ********************************/

#define MCnull          MMMNULL

/*** Type Translation Table:  DOM_ <=> CAT_ ***********************************/

#define DOM_ANY         0                                  /* unbekannter Typ */
#define DOM_ARRAY       CAT_ARRAY
#define DOM_BOOL        CAT_BOOL
#define DOM_COMPLEX     CAT_COMPLEX
#define DOM_DEBUG       CAT_DEBUG
#define DOM_DOMAIN      CAT_DOM
#define DOM_EXEC        CAT_EXEC
#define DOM_EXPR        CAT_EXPR
#define DOM_EXT         CAT_EXT
#define DOM_FAIL        CAT_FAILED
#define DOM_FLOAT       CAT_FLOAT
#define DOM_FUNC_ENV    CAT_FUNC_ENV
#define DOM_HFARRAY     CAT_HFARRAY
#define DOM_IDENT       CAT_IDENT
#define DOM_INT         CAT_INT
#define DOM_LIST        CAT_STAT_LIST
#define DOM_NIL         CAT_NIL
#define DOM_NULL        CAT_NULL
#define DOM_POLY        CAT_POLY
#define DOM_PROC        CAT_PROC
#define DOM_RAT         CAT_RAT
#define DOM_SET         CAT_SET_FINITE
#define DOM_STRING      CAT_STRING
#define DOM_TABLE       CAT_TABLE
#define DOM_VAR         CAT_VAR
#define DOM_PROC_ENV    CAT_PROC_ENV


/******************************************************************************/
/*** Toolbox - Routines *******************************************************/
/******************************************************************************/

//** Memory Management ********************************************************/

inline long    MFnops    ( MTcell  s ) { return( MFnopsGet(s) ); };
inline void    MFnops    ( MTcell *s, long n ) { MFnopsSet(s,n); };

inline MTcell  MFop      ( MTcell  s, long n ) { return( MFopGet(s,n) ); };
inline MTcell  MFop      ( MTcell  s, long n, MTcell t ) {
                           return( MFopSet(s,n,t) ); };

inline MUPTSize MFsize    ( MTcell  s ) { return( MFsizeGet(s) ); }
inline MUPTSize MFsize    ( MTcell *s, long n ) { return( MFsizeSet(s,n) ); }

inline char*   MFmemGet  ( MTcell  s, long offset=0 ) {
               return( MFmemoGet(s,offset) ); };
inline char*   MFmemSet  ( MTcell  s, long offset=0 ) {
               return( MFmemoSet(s,offset) ); };

//** Boolean constants ********************************************************/

#define MVtrue      (MFtrue())
#define MVfalse     (MFfalse())
#define MVunknown   (MFunknown())

//** Special arithmetic constants *********************************************/

#define MVi         (MFi())
#define MVzero      (MFzero())
#define MVhalf      (MFhalf())
#define MVone       (MFone())
#define MVone_      (MFone_())
#define MVtwo       (MFtwo())
#define MVtwo_      (MFtwo_())

//** Other special constants **************************************************/

#define MVfail      (MFfail())
#define MVnil       (MFnil())
#define MVnull      (MFnull())

//** Compare ******************************************************************/

//** Convert basic types (MTbools,numbers,strings,identifiers) ****************/

inline double  MFdouble     ( MTcell s ) { return( MFcdouble(s) ); };
inline MTcell  MFdouble     ( double v ) { return( MFmdouble(v) ); };
inline float   MFfloat      ( MTcell v ) { return( (float) MFcdouble(v) ); }
inline MTcell  MFfloat      ( float  v ) { return( MFmdouble((double)v) ); }

inline char*   MFstring     ( MTcell s, long option=MCaddr) {
                              return( MFcstring(s,option) );}
inline MTcell  MFstring     ( const char  *v ) { return( MFmstring(v) ); }

inline char*   MFident      ( MTcell s, long option=MCaddr) {
                              return( MFcident(s,option) );}
inline MTcell  MFident      ( const char  *v ) { return( MFmident(v) ); }

inline long    MFlong       ( MTcell s ) { return( MFclong(s) ); }
inline MTcell  MFlong       ( long   v ) { return( MFmlong(v) ); }
inline MTcell  MFlong       ( int    v ) { return( MFmlong((long)v) ); }
inline MTcell  MFint        ( int    v ) { return( MFmlong((long)v) ); }
inline int     MFint        ( MTcell s ) { return( (int) MFclong(s) ); }

#if !(defined WIN32)
inline FILE*   MFUstream     ( MTcell s ) { return( MFUcstream(s) ); }
inline MTcell  MFUstream     ( FILE *fp, char *mode, char *format  ) {
                               return( MFUmstream(fp,mode,format) ) ; }
#endif

typedef struct {
   short cat;
   short spec;
} CAT ;

/******************************************************************************/
/* NAME:        MFbool3                                                       */
/* PARAMETER:   s = An element of type DOM_BOOL (MTcell)                      */
/* FUNKTION:    According to 's' it returns MCtrue, MCfalse or MCunknown.     */
/******************************************************************************/
inline MTbool MFbool3( MTcell s )
{
   MMMASSERT( MFcat(s) == CAT_BOOL ) ;
   return static_cast<MTbool>(*(MMMmv(&s, sizeof(CAT), long)));
}

/******************************************************************************/
/* NAME:        MFbool3                                                       */
/* PARAMETER:   v = One of the values MCtrue, MCfalse or MCunknown            */
/* FUNKTION:    According to 'v' it returns MVtrue, MVfalse or MVunknown.     */
/******************************************************************************/
inline MTcell MFbool3( MTbool v )
{
    switch( v ) {
      case MCtrue   : return( MFcopy(MVtrue   ) );
      case MCfalse  : return( MFcopy(MVfalse  ) );
      case MCunknown: return( MFcopy(MVunknown) );
      default       : return( MFcopy(MVfail   ) );
    }
}

/******************************************************************************/
/* NAME:        MFbool                                                        */
/* PARAMETER:   s = An element of type DOM_BOOL (MTcell)                      */
/* FUNKTION:    Converts TRUE to 1 (=true) and FALSE/UNKNOWN to 0 (=false).   */
/******************************************************************************/
inline MTbool MFbool ( MTcell s )
{
    if( MFbool3(s) == MCtrue ) return( 1 );
    else                       return( 0 );
}

/******************************************************************************/
/* NAME:        MFbool                                                        */
/* PARAMETER:   v = 0 (=false) or != 0 (=false)                               */
/* FUNKTION:    Converts 1 (=true) to TRUE and 0 (=false) to FALSE.           */
/******************************************************************************/
inline MTcell MFbool ( MTbool v )
{
    if( v ) return( MFcopy(MVtrue ) );
    else    return( MFcopy(MVfalse) );
}

/******************************************************************************/
/* NAME:        MFrat                                                         */
/* PARAMETER:   numer = Numerator (DOM_INT), copy expected!                   */
/*              denom = Denominator  (DOM_INT), copy expected!                */
/* FUNKTION:    Returns the DOM_RAT 'numer/denom' and frees(!) the arguments. */
/******************************************************************************/
inline MTcell MFrat ( MTcell numer, MTcell denom ) {
       MTcell r = MFdiv( numer, denom );
       if( MFequal(r,MVhalf) ) {
           MFfree(r);
           r = MFcopy(MVhalf);
       }
       return( r );
}

/******************************************************************************/
/* NAME:        MFrat                                                         */
/* PARAMETER:   numer = Numerator (long)                                      */
/*              denom = Denominator  (long)                                   */
/* FUNKTION:    Returns a DOM_RAT of the value 'numer/denom'.                 */
/******************************************************************************/
inline MTcell MFrat ( long numer, long denom ) {
       return( MFrat(MFlong(numer),MFlong(denom)) );
}

/******************************************************************************/
/* NAME:        MFcomplex                                                     */
/* PARAMETER:   re = Real part (INT/FLOAT/RAT), copy expected!                */
/*              im = Imaginary part  (INT/FLOAT/RAT), copy expected!          */
/* FUNKTION:    Returns the DOM_COMPLEX value 're+im*I' and frees(!) its      */
/*              argumemts.                                                    */
/******************************************************************************/
inline MTcell MFcomplex ( MTcell re, MTcell im ) {
       MTcell res = MFmult(im,MFcopy(MVi));
       MFaddto( &res, re );
       return( res );
}

/******************************************************************************/
/* NAME:        MFcomplex                                                     */
/* PARAMETER:   re = Real part (long)                                         */
/*              im = Imaginary part  (long)                                   */
/* FUNKTION:    Returns a DOM_COMPLEX of the value 're+im*I'.                 */
/******************************************************************************/
inline MTcell MFcomplex ( long re, long im ) {
       return( MFcomplex(MFlong(re),MFlong(im)) );
}

/******************************************************************************/
/* NAME:        MFcomplex                                                     */
/* PARAMETER:   re = Real part (double)                                       */
/*              im = Imaginary part  (double)                                 */
/* FUNKTION:    Returns a DOM_COMPLEX of the value 're+im*I'.                 */
/******************************************************************************/
inline MTcell MFcomplex ( double re, double im ) {
       return( MFcomplex(MFdouble(re),MFdouble(im)) );
}

//** Types and Typechecking ***************************************************/

inline MTbool MFisArray    ( MTcell s ) { return( MFdom(s)==DOM_ARRAY     ); }
inline MTbool MFisBool     ( MTcell s ) { return( MFdom(s)==DOM_BOOL      ); }
inline MTbool MFisComplex  ( MTcell s ) { return( MFdom(s)==DOM_COMPLEX   ); }
inline MTbool MFisDebug    ( MTcell s ) { return( MFdom(s)==DOM_DEBUG     ); }
inline MTbool MFisDomain   ( MTcell s ) { return( MFdom(s)==DOM_DOMAIN    ); }
inline MTbool MFisExec     ( MTcell s ) { return( MFdom(s)==DOM_EXEC      ); }
inline MTbool MFisExt      ( MTcell s ) { return( MFdom(s)==DOM_EXT       ); }
inline MTbool MFisExpr     ( MTcell s ) { return( MFdom(s)==DOM_EXPR      ); }
inline MTbool MFisFail     ( MTcell s ) { return( MFdom(s)==DOM_FAIL      ); }
inline MTbool MFisFloat    ( MTcell s ) { return( MFdom(s)==DOM_FLOAT     ); }
inline MTbool MFisFuncEnv  ( MTcell s ) { return( MFdom(s)==DOM_FUNC_ENV  ); }
inline MTbool MFisHFArray  ( MTcell s ) { return( MFdom(s)==DOM_HFARRAY   ); }
inline MTbool MFisIdent    ( MTcell s ) { return( MFdom(s)==DOM_IDENT     ); }
inline MTbool MFisInt      ( MTcell s ) { return( MFdom(s)==DOM_INT       ); }
inline MTbool MFisList     ( MTcell s ) { return( MFdom(s)==DOM_LIST      ); }
inline MTbool MFisNil      ( MTcell s ) { return( MFdom(s)==DOM_NIL       ); }
inline MTbool MFisNull     ( MTcell s ) { return( MFdom(s)==DOM_NULL      ); }
inline MTbool MFisProc     ( MTcell s ) { return( MFdom(s)==DOM_PROC      ); }
inline MTbool MFisPolynom  ( MTcell s ) { return( MFdom(s)==DOM_POLY      ); }
inline MTbool MFisRat      ( MTcell s ) { return( MFdom(s)==DOM_RAT       ); }
inline MTbool MFisSet      ( MTcell s ) { return( MFdom(s)==DOM_SET       ); }
inline MTbool MFisString   ( MTcell s ) { return( MFdom(s)==DOM_STRING    ); }
inline MTbool MFisTable    ( MTcell s ) { return( MFdom(s)==DOM_TABLE     ); }
inline MTbool MFisVar      ( MTcell s ) { return( MFdom(s)==DOM_VAR       ); }

/*** Identify any type of a number ********************************************/

inline MTbool MFisInteger(MTcell s) {return( MFisInt(s) );  }
inline MTbool MFisNumber (MTcell s) {return( MFisInteger(s) || MFisComplex(s)
                                          || MFisFloat(s)   || MFisRat(s) );  }
inline MTbool MFisChar   (MTcell s) {return( MFisString(s)  || MFisIdent(s) );}

/*** Identify MTbool constants ***********************************************/

inline MTbool MFisTrue   (MTcell s){return(MFisBool(s)&&MFbool3(s)==MCtrue   );}
inline MTbool MFisFalse  (MTcell s){return(MFisBool(s)&&MFbool3(s)==MCfalse  );}
inline MTbool MFisUnknown(MTcell s){return(MFisBool(s)&&MFbool3(s)==MCunknown);}

/*** Identify special arithmetic constants ************************************/

inline MTbool MFisZero   ( MTcell s ) {return( (MTbool) MFequal(s,MVzero) );}
inline MTbool MFisOne    ( MTcell s ) {return( (MTbool) MFequal(s,MVone ) );}
inline MTbool MFisHalf   ( MTcell s ) {return( (MTbool) MFequal(s,MVhalf) );}
inline MTbool MFisOne_   ( MTcell s ) {return( (MTbool) MFequal(s,MVone_) );}
inline MTbool MFisTwo    ( MTcell s ) {return( (MTbool) MFequal(s,MVtwo ) );}
inline MTbool MFisTwo_   ( MTcell s ) {return( (MTbool) MFequal(s,MVtwo_) );}
inline MTbool MFisI      ( MTcell s ) {return( (MTbool) MFequal(s,MVi   ) );}

/*** Identify character based data types **************************************/

/******************************************************************************/
/* NAME:        MFisIdent                                                     */
/* PARAMETER:   s    = Any MuPAD Objects (DOM_...)                            */
/*              text = Name of identifier to check for                        */
/* FUNKTION:    Check if 's' is the idetifier 'text'.                         */
/******************************************************************************/
inline MTbool MFisIdent ( MTcell s, const char *text )
{
    if     ( !MFisIdent(s) )                return( 0 );
    else if( strcmp(MFident(s),text) == 0 ) return( 1 );
    else                                    return( 0 );
}

/******************************************************************************/
/* NAME:        MFisString                                                    */
/* PARAMETER:   s    = Any MuPAD Objects (DOM_...)                            */
/*              text = Text of string to check for                            */
/* FUNKTION:    Check if 's' is the string 'text'.                            */
/******************************************************************************/
inline MTbool MFisString ( MTcell s, const char *text )
{
       if     ( !MFisString(s) )                return( 0 );
       else if( strcmp(MFstring(s),text) == 0 ) return( 1 );
       else                                     return( 0 );
}

/******************************************************************************/
/* NAME:        MFisChar                                                      */
/* PARAMETER:   s    = Any MuPAD Objects (DOM_...)                            */
/*              text = Text of string to check for                            */
/* FUNKTION:    Check if 's' is the string or Identifier 'text'.              */
/******************************************************************************/
inline MTbool MFisChar  ( MTcell s, const char *text ) {
       return( MFisString(s,text)
            || MFisIdent (s,text) );
}

/*** Identify expressions *****************************************************/

inline MTbool MFisExpr ( MTcell s, MTcell op ) {
    return( MFdom(s)==DOM_EXPR && MFequal(MFop(s,0), op) );
};

/******************************************************************************/
/* NAME:        MFisExpr                                                      */
/* PARAMETER:   s    = Any category (MTcell)                                  */
/*              type = A type of an expression (char*)                        */
/* FUNKTION:    Returns 1 if 's' is an expression of type 'type'.             */
/******************************************************************************/
inline MTbool MFisExpr ( MTcell s, const char *name )
{
       if     ( !MFisExpr(s) )                         return( 0 );
       else if( strcmp(MFident(MFop(s,0)),name) == 0 ) return( 1 );
       else                                            return( 0 );
}

/******************************************************************************/
/* NAME:        MFisExt                                                       */
/* PARAMETER:   s      = Any category (MTcell)                                */
/*              domain = A domain to be checked for                           */
/* FUNKTION:    Returns 1 if 's' is an doomainelement of 'domain'             */
/******************************************************************************/
inline MTbool MFisExt ( MTcell s, MTcell domain )
{
       if     ( !MFisExt(s) )               return( 0 );
       else if( MFequal(MFop(s,0),domain) ) return( 1 );
       else                                 return( 0 );
}

//** Numbers ******************************************************************/

#define MFnewInt     MFlong
#define MFnewApm     MFlong
#define MFnewFloat   MFdouble
#define MFnewComplex MFcomplex
#define MFnewRat     MFrat

//** DOM_STRING/DOM_IDENT *****************************************************/

#define MFnewString  MFstring
#define MFnewIdent   MFident

//** DOM_EXPR *****************************************************************/

inline MTcell MFnewExpr ( MTcell s, long n=0 ) { return( MFnewExpr1(s, n) ); };
inline MTcell MFnewExpr ( long n  Mva_arglist ) {
       MTcell expr;
       Mva_start( args, n );
       expr = MFnewExpr2( n, args );
       Mva_end( args );
       return( expr );
}

inline void   MFnopsExpr( MTcell *s, long n ) { MFnops( s, n ); }
inline long   MFnopsExpr( MTcell s          ) { return( MFnops(s) ); }

inline MTcell MFtext2expr  (const  char *string, long ShowErrors=1 ) {
              return( MFtext2expr2(string,ShowErrors) ); };

//** DOM_LIST *****************************************************************/

inline void   MFnopsList( MTcell *s, long n ) { MFnops( s, n ); };
inline long   MFnopsList( MTcell s          ) { return( MFnops(s) ); };

//** DOM_EXT ******************************************************************/

inline void   MFnopsExt( MTcell *s, long n ) { MFnops( s, n ); };
inline long   MFnopsExt( MTcell s          ) { return( MFnops(s) ); };

//** DOM_SET ******************************************************************/

//** DOM_TABLE ****************************************************************/

inline void   MFdelTable   ( MTcell *s, MTcell idx, long t=-1 ) {
              MFdelTable2(s,idx,t); };
inline MTcell MFgetTable   ( MTcell *s, MTcell idx, long t=-1 ) {
              return( MFgetTable2(s,idx,t) ); };
inline MTbool MFinTable    ( MTcell *s, MTcell idx, long t=-1 ) {
              return( MFinTable2(s,idx,t) ); };
inline void   MFinsTable   ( MTcell *s, MTcell idx, MTcell v, long t=-1 ) {
              MFinsTable2(s,idx,v,t); };

//** DOM_DOMAIN ***************************************************************/

inline MTcell MFnewDomain ( MTcell key, MTbool *is_new ) {
              return( MFnewDomain1(key,is_new) ); };
inline MTcell MFnewDomain ( MTcell key ) {
              MTbool is_new;
              return( MFnewDomain1(key,&is_new) ); };

//** DOM_POLY *****************************************************************/

inline MTcell MFpoly2list ( MTcell s, MTcell *u=NULL,   MTcell *f=NULL ) {
              return( MFpoly2list2(s,u,f) ); };
inline MTcell MFlist2poly ( MTcell s, MTcell  u=MVnull, MTcell  f=MVnull ) {
              return( MFlist2poly2(s,u,f) ); };

//** DOM_ARRAY ****************************************************************/

inline MTcell MFlist2array ( MTcell list, long a,long b=0,long c=0,long d=0 ) {
              return( MFlist2array2(list,a,b,c,d) ); };

//** DOM_HFARRAY ****************************************************************/

inline MTcell MFlist2hfarray ( MTcell list, long a,long b=0,long c=0,long d=0 ) {
              return( MFlist2hfarray2(list,a,b,c,d) ); };

inline MUPTSize MFnopsHFarray(S_Pointer array) {
              MMMASSERT(CAT_HFARRAY == MFcat(array));
              return MMMsize(*MMMP(&array, 0))/sizeof(double); };

//**  DOM_... *****************************************************************/

//** Get/Set identifiers ******************************************************/

//** Service functions and Creation of special objects ************************/

//** Arbitrary Precision Numbers **********************************************/

//** Arithmetic ***************************************************************/

//** Boolean Operators ********************************************************/

//** Input/Output *************************************************************/

//** Evaluation ***************************************************************/

//** Calling kernel built-in and library functions ****************************/

/******************************************************************************/
/* NAME:        MFcall                                                        */
/* PARAMETER:   s = Any MuPAD Objects (DOM_...)                               */
/*              n = Number of function arguments                              */
/* FUNKTION:    Call the MuPAD function 's' with the argument given.          */
/******************************************************************************/
inline MTcell MFcall ( MTcell s, long n  Mva_arglist )
{
       MTcell  res;
       Mva_start( args, n );
       res = MFcall1( MFeval(s), n, args );
       Mva_end( args );
       return( res );
}

inline MTcell MFcall  ( const char *cs, long n  Mva_arglist )
{
       MTcell  s = MF(cs);
       MTcell  res;
       Mva_start( args, n );
       res = MFcall1( MFeval(s), n, args );
       Mva_end( args );
       return( res );
}

//** Kernel-Management ********************************************************/

//** Module-Management ********************************************************/

inline MTbool MFstatic  ( const char *name, short mode=1 ) {
              return( MFstatic2(name,mode) );  };


//** Module-Management (internal) *********************************************/

/******************************************************************************/
//** Kernel - Additional Kernel Objects ***************************************/
/******************************************************************************/
#if defined ISMODULE && !defined MDMD_USE_DYNLINK && (defined MUPD_USE_STALINK || defined DO_NOT_USE_THIS)

//** Kernel - Module Management (internal) ************************************/

//** Kernel - Parser and Evaluator Management *********************************/

#endif /*** Additional Kernel Objects ***/


/******************************************************************************/
/*** Toolbox - Accessing Module Function Arguments ****************************/
/******************************************************************************/


/******************************************************************************/
/* NAME:        MV_nargs                                                      */
/* FUNKTION:    Number of arguments passed to the function (unevaluated!).    */
/******************************************************************************/
#define MV_nargs                                                              \
        ( MFnops(MV_args)-1 )

/******************************************************************************/
/* NAME:        MF_arg                                                        */
/* PARAMETER:   n = Index of a function argument (long).                      */
/* FUNKTION:    The 'n'-th argument passed to the function (unevaluated!).    */
/******************************************************************************/
#define MF_arg( n )                                                           \
        MFopGet(MV_args,n)

/******************************************************************************/
/* NAME:        MVnargs                                                       */
/* FUNKTION:    Number of arguments passed to the function (evaluated!).      */
/******************************************************************************/
#define MVnargs ( MFnops(MVargs)-1 )

/******************************************************************************/
/* NAME:        MFarg                                                         */
/* PARAMETER:   n = Index of a function argument (long).                      */
/* FUNKTION:    The 'n'-th argument passed to the function (evaluated!).      */
/******************************************************************************/
#define MFarg( n )                                                            \
        MFopGet(MVargs,n)

/******************************************************************************/
/* NAME:        MFnargsCheck                                                  */
/* PARAMETER:   n = Number of arguments that are allowed.                     */
/* FUNKTION:    Sets an error if the number of argument is unequal to 'n'.    */
/******************************************************************************/
#define MFnargsCheck( n ) {                                                   \
        if( MVnargs != n )                                                    \
            MFerror( "Wrong number of arguments" );                           \
}

/******************************************************************************/
/* NAME:        MFnargsCheckRange                                             */
/* PARAMETER:   n,m = Min/Max number of arguments that are allowed.           */
/* FUNKTION:    Sets an error if the number of argument is unequal to 'n'.    */
/******************************************************************************/
#define MFnargsCheckRange( n, m ) {                                           \
        if( MVnargs < n || MVnargs > m )                                      \
            MFerror( "Wrong number of arguments" );                           \
}

/******************************************************************************/
/* NAME:        MFargCheck                                                    */
/* PARAMETER:   n = Index of argument                                         */
/*              t = Expected type of argument                                 */
/* FUNKTION:    Sets an error if MFarg(n) is not of type 't'.                 */
/******************************************************************************/
#define MFargCheck( n, t ) {                                                  \
        if( MCinteger == t ) {                                                \
            if( !MFisInteger(MFarg(n)) ) MFerror( "Invalid argument" );       \
        } else if( MCnumber == t ) {                                          \
            if( !MFisNumber(MFarg(n)) )  MFerror( "Invalid argument" );       \
        } else if( MCchar == t ) {                                            \
            if( !MFisChar(MFarg(n)) )    MFerror( "Invalid argument" );       \
        } else {                                                              \
            if( MFdom(MFarg(n)) != t )   MFerror( "Invalid argument" );       \
        }                                                                     \
}


/******************************************************************************/
/*** Toolbox - Module Function Handling ***************************************/
/******************************************************************************/

#define MD_STRING(MD_name) #MD_name

#define MD_PROTOTYPE(MD_name)                                                 \
        MTcell MD_name ( MTcell MV_args,                                      \
                         long   MV_prev_func,                                 \
                         long   MV_eval_type,                                 \
                         MTcell MV_exec                                       \
                       )

#define MD_FUNC_HEADER( MD_name, MD_options )                                 \
        MD_PROTOTYPE( MD_MF_NAME(MD_name) )                                   \
        {                                                                     \
          MTcell   MVargs;                            /* evaluated args    */ \
          MTcell   MVdomkey = MFop(MV_exec,1);        /* module domain key */ \
          MTcell   MVdomain = MFnewDomain(MVdomkey);  /* module domain     */ \
          MFfree( MVdomain );                         /* no copy is needed */ \
          long     MV_opt   = MD_options;             /* function options  */ \
          const char*    MV_name  = MD_STRING(MD_name);                       \
                                                                              \
          if( 1==MFfuncInit( MV_args, MV_prev_func, &MV_eval_type,            \
                             MV_exec, &MVargs, MV_opt ) )                     \
              return( MVargs );                                               \
          MV_errnum = 0;                                                      \
          MV_errstr = "";                                                     \
          try {

#define MD_FUNC_FOOTER()                                                      \
          } catch(...) {            /* handle error case */                   \
              if( MV_errnum > 0 ) {                                           \
                  char     buf[1024];                                         \
                  sprintf( buf, "%s [%s%s]", MV_errstr,MD_MODSTR,MV_name );   \
                  MFfree( MVargs );                                           \
                  MEV_set_error(MV_errnum, buf);                              \
              } else if( MV_errnum < 0 ) {                                    \
                  if( MV_opt & MCremember )                                   \
                      MFfuncRem( MVargs, MV_result, MV_exec );                \
                  MFfree( MVargs );                                           \
                  return( MV_result );                                        \
              } else {                                                        \
                  throw;                                                      \
              }                                                               \
          }                                                                   \
          return(MCnull);                                                     \
        }

/******************************************************************************/
/* NAME:        MFreturn                                                      */
/* PARAMETER:   result = return value of the system/module function           */
/* FUNKTION:    Call exit code, update sign- bits and return function result  */
/******************************************************************************/
#define MFreturn( result )                                                    \
{                                                                             \
    MTcell   _xxxtmp = result;                                                \
    if( MV_opt & MCremember ) MFfuncRem( MVargs, _xxxtmp, MV_exec );          \
    MFfree( MVargs );                                                         \
    return( _xxxtmp );                                                        \
}

/******************************************************************************/
/*** Declaration and definiton of s & m functions (user interface) ************/
/******************************************************************************/

#define MFUNC(MD_name, MD_options)                                            \
        MD_FUNC_HEADER( MD_name, MD_options )

#define MFEND                                                                 \
        MD_FUNC_FOOTER()

#endif /* __mapi__ */

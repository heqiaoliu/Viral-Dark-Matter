/******************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved.     */
/* FILE   :  MKT_func.h                                                       */
/* DESCRIP:  Teile des MAPI,  bindet auf Bedarf die Kern header files ein     */
/*           und enthaelt die EXTERN Deklarationen aller Kernobjekte, die     */
/*           innerhalb von Modulen als Teil des MAPI UNBEDINGT adressier-     */
/*           bar sein muessen.                                                */
/******************************************************************************/

#ifndef __MKT_func__
#define __MKT_func__

#ifndef MEXDSTANDARD
#  define MEXDSTANDARD                     /*** Aktivieren von MEX_extern.h ***/
#endif

/*** The following header files must not be included in a dynamic module ******/
/*** which does not use the resolver of the dynamic linker  but uses the ******/
/*** the restricted MAPI (symbol table 'MDMV_object_tab') instead.       ******/


#if defined ISMODULE && !defined MDMD_USE_DYNLINK
#  include "MMMstorage_lean.h"
#  include "MUP_constants.h"
#  include "MEV_evaluate_help.h"
#  include "MUP_env.h"
#  include "MEX_extern.h"
#  include "MDE_declare.h"
#  include "MUP_version.h"
#  include "MDM_kern.h"
#else

#  include "bugfixes.h" // compiler problems
#  include "COMM/mupkernel.h"
#  include "MEX_extern.h"
#  include "MEN_string.h"
#  include "MDE_declare.h"
#  include "MKT_stream.h"
#  include "MMMstorage_lean.h"
#  include "MLI_literals.h"
#  include "MUP_types.h"
#  include "MUP_constants.h"
#  include "MUP_env.h"
#  include "MUP_extern.h"
#  include "MCT_iostream.h"
#  include "MCM_compare.h"
#  include "MTA_table.h"
#  include "MEV_evaluate.h"
#  include "MAS_assoc.h"
#  include "MIV_utils.h"
#  include "MCL_client.h"
#  include "MPE_proc_env.h"
#  include "MID_ident.h"
#  include "MSG_signature.h"
#  include "MSP_pointers.h"
#  include "MCL_context.h"
#  include "MDB_debug.h"
#  include "MPA_parser.h"
#  include "MSY_sys_func.h"
#  include "MSU_eval_subs.h"
#  include "MAM_ass_mem.h"
#  include "MAR_array.h"
#  include "MGS_simplify.h"
#  include "MSR_string.h"
#  include "MSE_set.h"
#  include "MDF_diff.h"
#  include "MXP_expand.h"
#  include "MFO_open.h"
#  include "MFO_fileop.h"
#  include "MFR_utils.h"
#  include "MSY_sys_func_help.h"
#  include "MPL_parallel.h"
#  include "MSV_save.h"
#  include "MPO_poly.h"
#  include "MPO_poly_help.h"
#  include "MUP_funcs.h"
#  include "MHI_history.h"
#  include "MGH_message.h"
#  include "MLE_lineedit.h"
#  include "MDM_kern.h"
#  include "MNS_namespace.h"
#  include "MIO_collect.h"
#  include "MSC_scan.h"
#  include "MIO_io.h"
#  include "MUT_debug.h"
#  include "MUT_utils.h"
#  include "MUP_resources.h"
#  include "MVC_vector.h"
#  include "MHF_hfarray.h"

#if defined WIN32 && !defined ISMODULE
#  include "MSW_int.h"
#endif /* WIN32... */

#endif /* ISMODULE... */


/******************************************************************************/
/*** Unterhalb dieser Grenze keine Aenderungen und Erweiterungen vornehmen! ***/
/*** Die folgenden Zeilen werden vom Programm 'mapi' genutzt um die Symbol- ***/
/*** tabelle sowie die Resolvermacros automatisch zu erstellen.   Das gege- ***/
/*** bene Format muss ZWINGEND eingehalten werden.                          ***/
/******************************************************************************/

typedef S_Pointer MTcell;

/*** Basic interface (for internal use only!!!) *******************************/

#define MFcat(s_)  (MTR_cat((s_)))
#define MFspec(s_) (MTR_spec((s_)))

/*** Macros which are by the module generator otherwise ***********************/

#ifndef ISMODULE
#   define MD_MF_NAME(MD_name)  MFeval_ ## MD_name
#   define MD_MODSTR            ""
#endif

/******************************************************************************/
/*** START OF EXTERN Declaration of MAPI Objects ******************************/
/******************************************************************************/

#ifdef EXTERN
#  error "EXTERN is defined"
#  undef  EXTERN
#endif
#define   EXTERN  extern

/******************************************************************************/
//** Toolbox - Variables ******************************************************/
/******************************************************************************/

EXTERN long    MV_errnum;
EXTERN const char   *MV_errstr;
EXTERN MTcell  MV_result;

/******************************************************************************/
/*** Toolbox - Routines *******************************************************/
/******************************************************************************/

//** Memory Management ********************************************************/

EXTERN const MTcell MMMNULL;

EXTERN char   *MFmmmstring ( MTcell s );

EXTERN short   MFdom     ( MTcell s );
EXTERN MTcell  MFcopy    ( MTcell  s );
EXTERN MTcell  MFchange  ( MTcell *s );
EXTERN void    MFfree    ( MTcell  s );
EXTERN long    MFnopsGet ( MTcell  s );
EXTERN void    MFnopsSet ( MTcell *s, long n );

EXTERN MTcell* MFopAdr   ( MTcell  s, long n );
EXTERN MTcell  MFopGet   ( MTcell  s, long n );
EXTERN MTcell  MFopSet   ( MTcell  s, long n, MTcell t );

EXTERN void    MFopFree  ( MTcell  s, long n );
EXTERN void    MFopSubs  ( MTcell *s, long n, MTcell t );
EXTERN MUPTSize MFsizeGet ( MTcell  s );
EXTERN MUPTSize MFsizeSet ( MTcell *s, long n );

EXTERN char*   MFmemoGet ( MTcell  s, long offset );
EXTERN char*   MFmemoSet ( MTcell  s, long offset );

EXTERN void    MFsig     ( MTcell  s );
EXTERN void*   MFcmalloc ( size_t  n );
EXTERN void    MFcfree   ( void   *p );

//** Boolean constants ********************************************************/

EXTERN MTcell       MFtrue();
EXTERN MTcell       MFfalse();
EXTERN MTcell       MFunknown();

//** Special arithmetic constants *********************************************/

EXTERN MTcell       MFi();
EXTERN MTcell       MFzero();
EXTERN MTcell       MFhalf();
EXTERN MTcell       MFone();
EXTERN MTcell       MFone_();
EXTERN MTcell       MFtwo();
EXTERN MTcell       MFtwo_();

//** Other special constants **************************************************/

EXTERN MTcell       MFfail();
EXTERN MTcell       MFnil();
EXTERN MTcell       MFnull();

//** Compare ******************************************************************/

EXTERN MTbool MFequal ( MTcell s, MTcell t );
EXTERN int    MFcmp   ( MTcell s, MTcell t );
EXTERN MTbool MFeq    ( MTcell s, MTcell t );
EXTERN MTbool MFneq   ( MTcell s, MTcell t );
EXTERN MTbool MFlt    ( MTcell s, MTcell t );
EXTERN MTbool MFle    ( MTcell s, MTcell t );
EXTERN MTbool MFgt    ( MTcell s, MTcell t );
EXTERN MTbool MFge    ( MTcell s, MTcell t );

//** Convert basic types (MTbools,numbers,strings,identifiers) ****************/

EXTERN double  MFcdouble    ( MTcell s );
EXTERN MTcell  MFmdouble    ( double v );

EXTERN char*   MFcstring    ( MTcell s, long option);
EXTERN MTcell  MFmstring    ( const char  *v );

EXTERN char*   MFcident     ( MTcell s, long option);
EXTERN MTcell  MFmident     ( const char  *v );

EXTERN long    MFclong      ( MTcell s );
EXTERN MTcell  MFmlong      ( long   v );

EXTERN MTcell  MFratNum    ( MTcell s );
EXTERN MTcell  MFratDen    ( MTcell s );

EXTERN MTcell  MFcomplexRe ( MTcell s );
EXTERN MTcell  MFcomplexIm ( MTcell s );

//** Types and Typechecking ***************************************************/

/*** Identify any type of a number ********************************************/

/*** Identify MTbool constants ***********************************************/

/*** Identify special arithmetic constants ************************************/

/*** Identify character based data types **************************************/

/*** Identify expressions *****************************************************/

//** Numbers ******************************************************************/

//** DOM_STRING/DOM_IDENT *****************************************************/

EXTERN long MFlenString ( MTcell s );
EXTERN long MFlenIdent  ( MTcell s );

//** DOM_EXPR *****************************************************************/

EXTERN MTcell MFnewExpr1( MTcell  s, long n );
EXTERN MTcell MFnewExpr2( long n, va_list args );

EXTERN MTcell MFnewExprSeq ( long    n  Mva_arglist );
EXTERN MTcell MFgetExpr    ( MTcell *s, long n );
EXTERN void   MFsetExpr    ( MTcell *s, long n, MTcell v );
EXTERN void   MFfreeExpr   ( MTcell *s, long n );
EXTERN void   MFsubsExpr   ( MTcell *s, long n, MTcell v );

EXTERN char*  MFexpr2text  ( MTcell s );
EXTERN MTcell MFtext2expr2 ( const char *string, long ShowErrors );
EXTERN MTcell MF           ( const char *string );

//** DOM_LIST *****************************************************************/

EXTERN MTcell MFnewList  ( long    n );
EXTERN MTcell MFgetList  ( MTcell *s, long n );
EXTERN void   MFsetList  ( MTcell *s, long n, MTcell v );
EXTERN void   MFfreeList ( MTcell *s, long n );
EXTERN void   MFsubsList ( MTcell *s, long n, MTcell v );

//** DOM_EXT ******************************************************************/

EXTERN MTcell MFnewExt  ( MTcell  dom, long n );
EXTERN MTcell MFgetExt  ( MTcell *s, long n );
EXTERN void   MFsetExt  ( MTcell *s, long n, MTcell v );
EXTERN void   MFfreeExt ( MTcell *s, long n );
EXTERN void   MFsubsExt ( MTcell *s, long n, MTcell v );
EXTERN MTcell MFdomExt  ( MTcell  s );

//** DOM_SET ******************************************************************/

EXTERN MTcell MFnewSet       (  );
EXTERN MTbool MFinSet        ( MTcell s, MTcell v );
EXTERN void   MFinsSet       ( MTcell s, MTcell v );
EXTERN MTcell MFunionSet     ( MTcell s, MTcell t );
EXTERN MTcell MFminusSet     ( MTcell s, MTcell t );
EXTERN MTcell MFintersectSet ( MTcell s, MTcell t );
EXTERN MTcell MFset2list     ( MTcell v );
EXTERN MTcell MFlist2set     ( MTcell v );
EXTERN MTcell MFdelSet       ( MTcell s, MTcell v );

//** DOM_TABLE ****************************************************************/

EXTERN MTcell MFnewTable   (  );
EXTERN void   MFdelTable2  ( MTcell *s, MTcell idx, long t );

EXTERN MTcell MFgetTable2  ( MTcell *s, MTcell idx, long t );
EXTERN MTbool MFinTable2   ( MTcell *s, MTcell idx, long t );
EXTERN void   MFinsTable2  ( MTcell *s, MTcell idx, MTcell v, long t );

EXTERN MTcell MFtable2list ( MTcell v );
EXTERN MTcell MFlist2table ( MTcell v );

//** DOM_DOMAIN ***************************************************************/

EXTERN void   MFdelDomain ( MTcell dom, MTcell idx );
EXTERN MTcell MFgetDomain ( MTcell dom, MTcell idx );
EXTERN void   MFinsDomain ( MTcell dom, MTcell idx, MTcell val );
EXTERN MTcell MFnewDomain1( MTcell key, MTbool *is_new );

//** DOM_POLY *****************************************************************/

EXTERN MTcell MFpoly2list2( MTcell s, MTcell *u, MTcell *f );
EXTERN MTcell MFlist2poly2( MTcell s, MTcell  u, MTcell  f );
EXTERN long   MFdegPoly   ( MTcell s );
EXTERN MTcell MFhfaColAsPoly( MTcell array, long col, MTcell indets );

//** DOM_ARRAY ****************************************************************/

EXTERN MTcell MFarray2list ( MTcell s );
EXTERN MTcell MFlist2array2( MTcell list, long a,long b,long c,long d );
EXTERN long   MFdimArray   ( MTcell a );
EXTERN void   MFrangeArray ( MTcell a, long dim, long *l, long *r );

//** DOM_HFARRAY ****************************************************************/

EXTERN MTcell MFlist2hfarray2( MTcell list, long a,long b,long c,long d );

EXTERN double* MFaddrReHFArray       ( MTcell t );
EXTERN double* MFaddrImHFArray       ( MTcell t );
EXTERN long*   MFaddrStatusHFArray   ( MTcell t );
EXTERN bool    MFisRealHFArray       ( MTcell t );
EXTERN bool    MFisComplexHFArray    ( MTcell t );
EXTERN long    MFdimHFArray          ( MTcell t );
EXTERN long    MFdimSizeHFArray      ( MTcell t, long n );
EXTERN MUPTIndex MFlengthHFArray       ( MTcell t );
EXTERN long    MFposHFArray          ( MTcell t Mva_arglist );
EXTERN MTcell  MFcloneHFArray        ( MTcell t );
EXTERN void    MFrealToComplexHFArray( MTcell t, bool zeros );

EXTERN MTcell  MFnewHFArray_         ( unsigned long dim, unsigned long length, long **p);
EXTERN MTcell  MFnewHFArray          ( bool complex, bool zeros, long dim Mva_arglist );
EXTERN void    MFsigReHFArray        ( MTcell t );
EXTERN void    MFsigImHFArray        ( MTcell t );
EXTERN void    MFsigStatusHFArray    ( MTcell t );

EXTERN MTcell  MFaddHFArray          ( MTcell s, MTcell t );
EXTERN MTcell  MFaddConstHFArray     ( MTcell s, MTcell c );
EXTERN MTcell  MFmultHFArray         ( MTcell s, MTcell t );
EXTERN MTcell  MFmultConstHFArray    ( MTcell s, MTcell c );
EXTERN MTcell  MFnegateHFArray       ( MTcell t );

//**  DOM_... *****************************************************************/

EXTERN MTcell MFnewDebug   ( unsigned long value );
EXTERN MTcell MFnewExec    ( long n );
EXTERN MTcell MFnewFuncEnv (  );
EXTERN MTcell MFnewProc    (  );

//** Get/Set identifiers ******************************************************/

EXTERN MTcell MFgetVar( char* var );
EXTERN void   MFsetVar( char* var, MTcell val );
EXTERN void   MFdelVar( char* var );

//** Service functions and Creation of special objects ************************/

EXTERN MTcell MFdomtype ( MTcell s );
EXTERN MTcell MFtype ( MTcell s );
EXTERN MTbool MFtesttype ( MTcell s, MTcell t );


//** Arithmetic ***************************************************************/

EXTERN void   MFsubto ( MTcell*s, MTcell t);
EXTERN void   MFaddto ( MTcell*s, MTcell t);
EXTERN void   MFmultto( MTcell*s, MTcell t);
EXTERN void   MFdivto ( MTcell*s, MTcell t);
EXTERN void   MFinc   ( MTcell*s );
EXTERN void   MFdec   ( MTcell*s );
EXTERN MTcell MFadd   ( MTcell s, MTcell t);
EXTERN MTcell MFsub   ( MTcell s, MTcell t);
EXTERN MTcell MFmult  ( MTcell s, MTcell t);
EXTERN MTcell MFdiv   ( MTcell s, MTcell t);
EXTERN MTcell MFdivInt( MTcell s, MTcell t);
EXTERN MTcell MFpower ( MTcell s, MTcell t);
EXTERN MTcell MFmod   ( MTcell s, MTcell t);
EXTERN MTcell MFmods  ( MTcell s, MTcell t);
EXTERN MTcell MFbinom ( MTcell s, MTcell t);
EXTERN MTcell MFexp   ( MTcell s );
EXTERN MTcell MFgcd   ( MTcell s, MTcell t);
EXTERN MTcell MFlcm   ( MTcell s, MTcell t);
EXTERN MTcell MFln    ( MTcell s );
EXTERN MTcell MFsqrt  ( MTcell s );
EXTERN MTbool MFisNeg ( MTcell s );
EXTERN MTcell MFneg   ( MTcell s );
EXTERN MTcell MFrec   ( MTcell s );
EXTERN MTcell MFabs   ( MTcell s );

//** Boolean Operators ********************************************************/

EXTERN MTcell MFnot   ( MTcell s );

//** Input/Output *************************************************************/

EXTERN void   MFputsRaw   ( const char *str );
EXTERN void   MFprintfRaw ( const char *format  Mva_arglist );
EXTERN int    MFprintf    ( const char *format  Mva_arglist );
EXTERN void   MFputs      ( const char *str );
EXTERN MTcell MFout       ( MTcell s );
EXTERN bool   MFisSecureFileAccess ( CONST char *f, CONST char *t );
#if /*!*/ !(defined WIN32)
EXTERN FILE*  MFUcstream    ( MTcell s );
EXTERN MTcell MFUmstream    ( FILE *fp, char *mode, char *format );
#else /*!*/
EXTERN void*             DUMMY_SYMBOL;
EXTERN void*             DUMMY_SYMBOL;
#endif /*!*/

//** Evaluation ***************************************************************/

EXTERN MTcell MFexec ( MTcell s );
EXTERN MTcell MFeval ( MTcell s );
EXTERN MTcell MFread ( char* name );
EXTERN MTcell MFtrap ( MTcell s, long *error );

//** Calling kernel built-in and library functions ****************************/

EXTERN MTcell MFcall1 ( MTcell s, long n, va_list args );

//** Kernel-Management ********************************************************/

EXTERN void   MFterminate (  );
EXTERN void   MFglobal    ( MTcell *s );
EXTERN char*  MFuserOpt   (  );

//** Module-Management ********************************************************/

EXTERN void   MFpeekEvents (  );
EXTERN MTbool MFdisplace   (  );
EXTERN MTbool MFstatic2    ( CONST char *name, short mode );

//** Module-Management (internal) *********************************************/

EXTERN int    MFfuncInit ( MTcell  MV_args,      long   MV_prev_func,
                           long   *MV_eval_type, MTcell MV_exec,
                           MTcell *MVargs,       long   MV_opt );
EXTERN void   MFfuncRem  ( MTcell MVargs, MTcell result, MTcell MV_exec );
EXTERN void   MFerror    ( char   *text   );
EXTERN void   MFexit     ( MTcell  result );

/******************************************************************************/
//** Kernel - Additional Kernel Objects ***************************************/
/******************************************************************************/
#if defined ISMODULE && !defined MDMD_USE_DYNLINK && (defined MUPD_USE_STALINK || defined DO_NOT_USE_THIS)

//** Kernel - Module Management (internal) ************************************/

EXTERN MDM_list_t       *MDMV_list;
EXTERN long              MDMV_support;
EXTERN long              MDMV_unload_support;
EXTERN time_t            MDMV_age_max;
EXTERN time_t            MDMV_aging;

EXTERN long              MDM_reset      (  );
EXTERN long              MDM_kick_out   (  );
EXTERN void              MDM_aging      (  );
EXTERN void              MDM_aging_intr (  );

EXTERN MDM_jump_t        MDM_object     ( CONST unsigned long index,
                                          CONST char*         file,
                                          CONST unsigned long line );

EXTERN long              MDMV_pmod_num;
EXTERN MDM_pmod_t        MDMV_pmod[];
EXTERN long              MDMV_object_tab_len;
EXTERN MDM_jump_t        MDMV_object_tab[];

EXTERN long              MDM_invalid_name ( CONST char *name );
EXTERN long              MDM_exist        ( CONST char *name );
EXTERN long              MDM_which        ( CONST char *name,
                                            CONST char *suffix,
                                                  char *fullname );

//** C/C++ Calling Kernel Environment *****************************************/

#ifdef USE_THIS_EXTERN_DECLARATIONS_ONLY_FOR_MDM_obj_and_MDM_mod
EXTERN int    mupadInit        ( char *libpath ) ;
EXTERN int    mupadInitArgv    ( int argc, char *argv[] ) ;

EXTERN int    mupadReset       ( ) ;
EXTERN void   mupadExit        ( ) ;

EXTERN char*  mupadEvalString  ( char *string, long *errnum ) ;
EXTERN void   mupadFreeString  ( char *string ) ;

EXTERN void   mupadEvalFile    ( char *string, long *errnum, FILE *file,
                                 int   pretty ) ;

EXTERN void   mupadGarbageCollection ( );

EXTERN void   mupadSetCallback ( void (*func)() ) ;
#endif

//** Kernel Environment *******************************************************/

EXTERN MUPT_env          MUPV_env;

//** Kernel - Parser and Evaluator Management *********************************/

#if /*!*/ !(defined WIN32)
EXTERN void              osStartraw   (  );
EXTERN void              osStopraw    (  );
EXTERN int               osGetch      (  );
#else /*!*/
EXTERN void*             DUMMY_SYMBOL;
EXTERN void*             DUMMY_SYMBOL;
EXTERN void*             DUMMY_SYMBOL;
#endif /*!*/

EXTERN long              MEVV_ERROR;
EXTERN long              MEV_set_error(long err_nr, char *err_str Mva_arglist);

EXTERN void              MUP_catch_system_error(  );

#endif /*** Additional Kernel Objects ***/

/******************************************************************************/
/*** END OF EXTERN Declaration of MAPI Objects ********************************/
/******************************************************************************/

#undef EXTERN

#include "MKT_mapi.h"                     /** Include kernel declarations ***/

#endif /*** __MKT_func__ ***/

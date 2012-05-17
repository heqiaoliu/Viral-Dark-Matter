
//** BEGIN 'MDM_mod.h' created on 'Wed Apr  8 13:43:29 2009' ******************/

//** Toolbox - Variables ******************************************************/

#define MV_errnum                (*(long          *)       MDM_K(MDM_MAPI+  0))
#define MV_errstr                (*(const char*   *)       MDM_K(MDM_MAPI+  1))
#define MV_result                (*(MTcell        *)       MDM_K(MDM_MAPI+  2))

//** Memory Management ********************************************************/

#define MMMNULL                  (*(const MTcell  *)       MDM_K(MDM_MAPI+  3))
#define MFmmmstring              (*(char*        (*)(...)) MDM_K(MDM_MAPI+  4))
#define MFdom                    (*(short        (*)(...)) MDM_K(MDM_MAPI+  5))
#define MFcopy                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+  6))
#define MFchange                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+  7))
#define MFfree                   (*(void         (*)(...)) MDM_K(MDM_MAPI+  8))
#define MFnopsGet                (*(long         (*)(...)) MDM_K(MDM_MAPI+  9))
#define MFnopsSet                (*(void         (*)(...)) MDM_K(MDM_MAPI+ 10))
#define MFopAdr                  (*(MTcell*      (*)(...)) MDM_K(MDM_MAPI+ 11))
#define MFopGet                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 12))
#define MFopSet                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 13))
#define MFopFree                 (*(void         (*)(...)) MDM_K(MDM_MAPI+ 14))
#define MFopSubs                 (*(void         (*)(...)) MDM_K(MDM_MAPI+ 15))
#define MFsizeGet                (*(MUPTSize     (*)(...)) MDM_K(MDM_MAPI+ 16))
#define MFsizeSet                (*(MUPTSize     (*)(...)) MDM_K(MDM_MAPI+ 17))
#define MFmemoGet                (*(char*        (*)(...)) MDM_K(MDM_MAPI+ 18))
#define MFmemoSet                (*(char*        (*)(...)) MDM_K(MDM_MAPI+ 19))
#define MFsig                    (*(void         (*)(...)) MDM_K(MDM_MAPI+ 20))
#define MFcmalloc                (*(void*        (*)(...)) MDM_K(MDM_MAPI+ 21))
#define MFcfree                  (*(void         (*)(...)) MDM_K(MDM_MAPI+ 22))

//** Boolean constants ********************************************************/

#define MFtrue                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 23))
#define MFfalse                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 24))
#define MFunknown                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 25))

//** Special arithmetic constants *********************************************/

#define MFi                      (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 26))
#define MFzero                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 27))
#define MFhalf                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 28))
#define MFone                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 29))
#define MFone_                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 30))
#define MFtwo                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 31))
#define MFtwo_                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 32))

//** Other special constants **************************************************/

#define MFfail                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 33))
#define MFnil                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 34))
#define MFnull                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 35))

//** Compare ******************************************************************/

#define MFequal                  (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 36))
#define MFcmp                    (*(int          (*)(...)) MDM_K(MDM_MAPI+ 37))
#define MFeq                     (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 38))
#define MFneq                    (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 39))
#define MFlt                     (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 40))
#define MFle                     (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 41))
#define MFgt                     (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 42))
#define MFge                     (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 43))

//** Convert basic types (MTbools,numbers,strings,identifiers) ****************/

#define MFcdouble                (*(double       (*)(...)) MDM_K(MDM_MAPI+ 44))
#define MFmdouble                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 45))
#define MFcstring                (*(char*        (*)(...)) MDM_K(MDM_MAPI+ 46))
#define MFmstring                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 47))
#define MFcident                 (*(char*        (*)(...)) MDM_K(MDM_MAPI+ 48))
#define MFmident                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 49))
#define MFclong                  (*(long         (*)(...)) MDM_K(MDM_MAPI+ 50))
#define MFmlong                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 51))
#define MFratNum                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 52))
#define MFratDen                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 53))
#define MFcomplexRe              (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 54))
#define MFcomplexIm              (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 55))

//** Types and Typechecking ***************************************************/


//** Numbers ******************************************************************/


//** DOM_STRING/DOM_IDENT *****************************************************/

#define MFlenString              (*(long         (*)(...)) MDM_K(MDM_MAPI+ 56))
#define MFlenIdent               (*(long         (*)(...)) MDM_K(MDM_MAPI+ 57))

//** DOM_EXPR *****************************************************************/

#define MFnewExpr1               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 58))
#define MFnewExpr2               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 59))
#define MFnewExprSeq             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 60))
#define MFgetExpr                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 61))
#define MFsetExpr                (*(void         (*)(...)) MDM_K(MDM_MAPI+ 62))
#define MFfreeExpr               (*(void         (*)(...)) MDM_K(MDM_MAPI+ 63))
#define MFsubsExpr               (*(void         (*)(...)) MDM_K(MDM_MAPI+ 64))
#define MFexpr2text              (*(char*        (*)(...)) MDM_K(MDM_MAPI+ 65))
#define MFtext2expr2             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 66))
#define MF                       (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 67))

//** DOM_LIST *****************************************************************/

#define MFnewList                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 68))
#define MFgetList                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 69))
#define MFsetList                (*(void         (*)(...)) MDM_K(MDM_MAPI+ 70))
#define MFfreeList               (*(void         (*)(...)) MDM_K(MDM_MAPI+ 71))
#define MFsubsList               (*(void         (*)(...)) MDM_K(MDM_MAPI+ 72))

//** DOM_EXT ******************************************************************/

#define MFnewExt                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 73))
#define MFgetExt                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 74))
#define MFsetExt                 (*(void         (*)(...)) MDM_K(MDM_MAPI+ 75))
#define MFfreeExt                (*(void         (*)(...)) MDM_K(MDM_MAPI+ 76))
#define MFsubsExt                (*(void         (*)(...)) MDM_K(MDM_MAPI+ 77))
#define MFdomExt                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 78))

//** DOM_SET ******************************************************************/

#define MFnewSet                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 79))
#define MFinSet                  (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 80))
#define MFinsSet                 (*(void         (*)(...)) MDM_K(MDM_MAPI+ 81))
#define MFunionSet               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 82))
#define MFminusSet               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 83))
#define MFintersectSet           (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 84))
#define MFset2list               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 85))
#define MFlist2set               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 86))
#define MFdelSet                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 87))

//** DOM_TABLE ****************************************************************/

#define MFnewTable               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 88))
#define MFdelTable2              (*(void         (*)(...)) MDM_K(MDM_MAPI+ 89))
#define MFgetTable2              (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 90))
#define MFinTable2               (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+ 91))
#define MFinsTable2              (*(void         (*)(...)) MDM_K(MDM_MAPI+ 92))
#define MFtable2list             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 93))
#define MFlist2table             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 94))

//** DOM_DOMAIN ***************************************************************/

#define MFdelDomain              (*(void         (*)(...)) MDM_K(MDM_MAPI+ 95))
#define MFgetDomain              (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 96))
#define MFinsDomain              (*(void         (*)(...)) MDM_K(MDM_MAPI+ 97))
#define MFnewDomain1             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 98))

//** DOM_POLY *****************************************************************/

#define MFpoly2list2             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+ 99))
#define MFlist2poly2             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+100))
#define MFdegPoly                (*(long         (*)(...)) MDM_K(MDM_MAPI+101))
#define MFhfaColAsPoly           (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+102))

//** DOM_ARRAY ****************************************************************/

#define MFarray2list             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+103))
#define MFlist2array2            (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+104))
#define MFdimArray               (*(long         (*)(...)) MDM_K(MDM_MAPI+105))
#define MFrangeArray             (*(void         (*)(...)) MDM_K(MDM_MAPI+106))

//** DOM_HFARRAY ****************************************************************/

#define MFlist2hfarray2          (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+107))
#define MFaddrReHFArray          (*(double*      (*)(...)) MDM_K(MDM_MAPI+108))
#define MFaddrImHFArray          (*(double*      (*)(...)) MDM_K(MDM_MAPI+109))
#define MFaddrStatusHFArray      (*(long*        (*)(...)) MDM_K(MDM_MAPI+110))
#define MFisRealHFArray          (*(bool         (*)(...)) MDM_K(MDM_MAPI+111))
#define MFisComplexHFArray       (*(bool         (*)(...)) MDM_K(MDM_MAPI+112))
#define MFdimHFArray             (*(long         (*)(...)) MDM_K(MDM_MAPI+113))
#define MFdimSizeHFArray         (*(long         (*)(...)) MDM_K(MDM_MAPI+114))
#define MFlengthHFArray          (*(MUPTIndex    (*)(...)) MDM_K(MDM_MAPI+115))
#define MFposHFArray             (*(long         (*)(...)) MDM_K(MDM_MAPI+116))
#define MFcloneHFArray           (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+117))
#define MFrealToComplexHFArray   (*(void         (*)(...)) MDM_K(MDM_MAPI+118))
#define MFnewHFArray_            (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+119))
#define MFnewHFArray             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+120))
#define MFsigReHFArray           (*(void         (*)(...)) MDM_K(MDM_MAPI+121))
#define MFsigImHFArray           (*(void         (*)(...)) MDM_K(MDM_MAPI+122))
#define MFsigStatusHFArray       (*(void         (*)(...)) MDM_K(MDM_MAPI+123))
#define MFaddHFArray             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+124))
#define MFaddConstHFArray        (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+125))
#define MFmultHFArray            (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+126))
#define MFmultConstHFArray       (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+127))
#define MFnegateHFArray          (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+128))

//**  DOM_... *****************************************************************/

#define MFnewDebug               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+129))
#define MFnewExec                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+130))
#define MFnewFuncEnv             (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+131))
#define MFnewProc                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+132))

//** Get/Set identifiers ******************************************************/

#define MFgetVar                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+133))
#define MFsetVar                 (*(void         (*)(...)) MDM_K(MDM_MAPI+134))
#define MFdelVar                 (*(void         (*)(...)) MDM_K(MDM_MAPI+135))

//** Service functions and Creation of special objects ************************/

#define MFdomtype                (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+136))
#define MFtype                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+137))
#define MFtesttype               (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+138))

//** Arithmetic ***************************************************************/

#define MFsubto                  (*(void         (*)(...)) MDM_K(MDM_MAPI+139))
#define MFaddto                  (*(void         (*)(...)) MDM_K(MDM_MAPI+140))
#define MFmultto                 (*(void         (*)(...)) MDM_K(MDM_MAPI+141))
#define MFdivto                  (*(void         (*)(...)) MDM_K(MDM_MAPI+142))
#define MFinc                    (*(void         (*)(...)) MDM_K(MDM_MAPI+143))
#define MFdec                    (*(void         (*)(...)) MDM_K(MDM_MAPI+144))
#define MFadd                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+145))
#define MFsub                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+146))
#define MFmult                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+147))
#define MFdiv                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+148))
#define MFdivInt                 (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+149))
#define MFpower                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+150))
#define MFmod                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+151))
#define MFmods                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+152))
#define MFbinom                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+153))
#define MFexp                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+154))
#define MFgcd                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+155))
#define MFlcm                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+156))
#define MFln                     (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+157))
#define MFsqrt                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+158))
#define MFisNeg                  (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+159))
#define MFneg                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+160))
#define MFrec                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+161))
#define MFabs                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+162))

//** Boolean Operators ********************************************************/

#define MFnot                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+163))

//** Input/Output *************************************************************/

#define MFputsRaw                (*(void         (*)(...)) MDM_K(MDM_MAPI+164))
#define MFprintfRaw              (*(void         (*)(...)) MDM_K(MDM_MAPI+165))
#define MFprintf                 (*(int          (*)(...)) MDM_K(MDM_MAPI+166))
#define MFputs                   (*(void         (*)(...)) MDM_K(MDM_MAPI+167))
#define MFout                    (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+168))
#define MFisSecureFileAccess     (*(bool         (*)(...)) MDM_K(MDM_MAPI+169))

#if /*!*/ !(defined WIN32)

#define MFUcstream               (*(FILE*        (*)(...)) MDM_K(MDM_MAPI+170))
#define MFUmstream               (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+171))

#else /*!*/

//                               /* not used */            MDM_K(MDM_MAPI+170))
//                               /* not used */            MDM_K(MDM_MAPI+171))

#endif /*!*/


//** Evaluation ***************************************************************/

#define MFexec                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+172))
#define MFeval                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+173))
#define MFread                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+174))
#define MFtrap                   (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+175))

//** Calling kernel built-in and library functions ****************************/

#define MFcall1                  (*(MTcell       (*)(...)) MDM_K(MDM_MAPI+176))

//** Kernel-Management ********************************************************/

#define MFterminate              (*(void         (*)(...)) MDM_K(MDM_MAPI+177))
#define MFglobal                 (*(void         (*)(...)) MDM_K(MDM_MAPI+178))
#define MFuserOpt                (*(char*        (*)(...)) MDM_K(MDM_MAPI+179))

//** Module-Management ********************************************************/

#define MFpeekEvents             (*(void         (*)(...)) MDM_K(MDM_MAPI+180))
#define MFdisplace               (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+181))
#define MFstatic2                (*(MTbool       (*)(...)) MDM_K(MDM_MAPI+182))

//** Module-Management (internal) *********************************************/

#define MFfuncInit               (*(int          (*)(...)) MDM_K(MDM_MAPI+183))
#define MFfuncRem                (*(void         (*)(...)) MDM_K(MDM_MAPI+184))
#define MFerror                  (*(void         (*)(...)) MDM_K(MDM_MAPI+185))
#define MFexit                   (*(void         (*)(...)) MDM_K(MDM_MAPI+186))

//** Kernel - Additional Kernel Objects ***************************************/


//** Kernel - Module Management (internal) ************************************/

#define MDMV_list                (*(MDM_list_t*   *)       MDM_K(MDM_MAPI+187))
#define MDMV_support             (*(long          *)       MDM_K(MDM_MAPI+188))
#define MDMV_unload_support      (*(long          *)       MDM_K(MDM_MAPI+189))
#define MDMV_age_max             (*(time_t        *)       MDM_K(MDM_MAPI+190))
#define MDMV_aging               (*(time_t        *)       MDM_K(MDM_MAPI+191))
#define MDM_reset                (*(long         (*)(...)) MDM_K(MDM_MAPI+192))
#define MDM_kick_out             (*(long         (*)(...)) MDM_K(MDM_MAPI+193))
#define MDM_aging                (*(void         (*)(...)) MDM_K(MDM_MAPI+194))
#define MDM_aging_intr           (*(void         (*)(...)) MDM_K(MDM_MAPI+195))
#define MDM_object               (*(MDM_jump_t   (*)(...)) MDM_K(MDM_MAPI+196))
#define MDMV_pmod_num            (*(long          *)       MDM_K(MDM_MAPI+197))
#define MDMV_pmod                ( (MDM_pmod_t    *)       MDM_K(MDM_MAPI+198))
#define MDMV_object_tab_len      (*(long          *)       MDM_K(MDM_MAPI+199))
#define MDMV_object_tab          ( (MDM_jump_t    *)       MDM_K(MDM_MAPI+200))
#define MDM_invalid_name         (*(long         (*)(...)) MDM_K(MDM_MAPI+201))
#define MDM_exist                (*(long         (*)(...)) MDM_K(MDM_MAPI+202))
#define MDM_which                (*(long         (*)(...)) MDM_K(MDM_MAPI+203))

//** C/C++ Calling Kernel Environment *****************************************/

#define mupadInit                (*(int          (*)(...)) MDM_K(MDM_MAPI+204))
#define mupadInitArgv            (*(int          (*)(...)) MDM_K(MDM_MAPI+205))
#define mupadReset               (*(int          (*)(...)) MDM_K(MDM_MAPI+206))
#define mupadExit                (*(void         (*)(...)) MDM_K(MDM_MAPI+207))
#define mupadEvalString          (*(char*        (*)(...)) MDM_K(MDM_MAPI+208))
#define mupadFreeString          (*(void         (*)(...)) MDM_K(MDM_MAPI+209))
#define mupadEvalFile            (*(void         (*)(...)) MDM_K(MDM_MAPI+210))
#define mupadGarbageCollection   (*(void         (*)(...)) MDM_K(MDM_MAPI+211))
#define mupadSetCallback         (*(void         (*)(...)) MDM_K(MDM_MAPI+212))

//** Kernel Environment *******************************************************/

#define MUPV_env                 (*(MUPT_env      *)       MDM_K(MDM_MAPI+213))

//** Kernel - Parser and Evaluator Management *********************************/


#if /*!*/ !(defined WIN32)

#define osStartraw               (*(void         (*)(...)) MDM_K(MDM_MAPI+214))
#define osStopraw                (*(void         (*)(...)) MDM_K(MDM_MAPI+215))
#define osGetch                  (*(int          (*)(...)) MDM_K(MDM_MAPI+216))

#else /*!*/

//                               /* not used */            MDM_K(MDM_MAPI+214))
//                               /* not used */            MDM_K(MDM_MAPI+215))
//                               /* not used */            MDM_K(MDM_MAPI+216))

#endif /*!*/

#define MEVV_ERROR               (*(long          *)       MDM_K(MDM_MAPI+217))
#define MEV_set_error            (*(long         (*)(...)) MDM_K(MDM_MAPI+218))
#define MUP_catch_system_error   (*(void         (*)(...)) MDM_K(MDM_MAPI+219))

//** END **********************************************************************/


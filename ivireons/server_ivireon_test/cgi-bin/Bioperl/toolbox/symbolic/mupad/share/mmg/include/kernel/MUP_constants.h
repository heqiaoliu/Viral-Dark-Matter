/**************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved. */
/* FILE:  MUP_constants.h                                                 */
/**************************************************************************/

#ifndef __MUP_constants__
#define __MUP_constants__

/* Prozedur-Optionen */


#define NO_SYM_BIT             0x0

enum {
  OPTIONS_CHECKED_BIT = (1 << 3),
  NO_DEBUG_BIT        = (1 << 4),
  HOLD_BIT            = (1 << 5),
  REMEMBER_BIT        = (1 << 6),
  ARROW_BIT           = (1 << 7),
  ESCAPE_BIT          = (1 << 8),
  NO_EXPOSE_BIT       = (1 << 9),
  
  // these do not affect equality of objects:
  TRACE_BIT           = (1 << 14),
  NO_LEXENV_BIT       = (1 << 15)
};

/* Oder-Maske aller fuer Vergleiche beruecksichtigten Bits */
#define COMPARE_BITS_MASK      (NO_DEBUG_BIT | HOLD_BIT | REMEMBER_BIT | ARROW_BIT | ESCAPE_BIT | NO_EXPOSE_BIT | OPTIONS_CHECKED_BIT)

#ifdef WIN32
#  define SYS_SIGNAL SIGQUIT    /* Dummy, da WIN32 SIGUSR2 nicht kennt  */
#else
#  define SYS_SIGNAL SIGUSR2    /* Signal an mupad zur Ank"undigung     */
                                /* eines Systembefehls                  */
#endif


/************* Defintion der Datentypen der Speicherverwaltung ***********
 *
 * Bei MMM-Typen, von denen Signaturen berechnet werden, muss die zugehoerige
 * MMM_-Konstante kleiner als MUPC_MaxStorTypes sein.
 */

enum MMME_type {
    MMM_NONE            = 0,
    // MMM_MSV_* must have these values, for backwards binary compatibility!
    MMM_MSV_null        = 0,
    MMM_MSV_domain      = 1,
    MMM_MSV_refs        = 4,
    MMM_MSV_ident       = 5,
    
    MMM_LIST            = 15,
    MMM_EXT_LIST        = 16,
    MMM_CATEGORY        = 17,
    MMM_STRING          = 18,
    MMM_ASS_MEM         = 19,
    MMM_VECTOR          = 20, // multi-purpose vector of s-pointers, generates
                              // r/o literal
    MMM_INTERVAL        = 21,
    MMM_VALUE           = 26,
    MMM_DOMAIN          = 27,
    MMM_ARRAY           = 28,
    MMM_STRING_HELP     = 29, // Hilfstyp, der vom MCode benutzt wird
    MMM_VAR             = 32,
    MMM_PROC_ENV        = 33,
    MMM_ASSOC           = 34,
    MMM_RW_LIT          = 35, // multi-purpose type for internal use only,
                              // generates r/w literal
    MMM_RO_LIT          = 36, // multi-purpose type for internal use only,
                              // generates r/o literal
    MMM_FRAME           = 37, // see CAT_FRAME
    MMM_IDENT           = 38, ///< internal data structure for identifiers
    MMM_EXEC            = 40,
    MMM_CODE            = 41,

    MMM_DIST_POLY       = 45,
    MMM_FUNCLIST        = 46,
    MMM_TMP             = 102,
    MMM_HIDDEN          = 103,
    MMM_CLTCTX          = 104,
    MMM_HFARRAY         = 105,
    MMM_OUT_COLLECT     = 109,
    MMM_OUT_NODE        = 110,
    MMM_OUT_TEXT        = 111,
    MMM_OUT_FIELD       = 112
};


/****************** Defintion der Kategorietypen *************************/
/*
 * ACHTUNG: Bei Erweiterungen/Aenderungen muss auch die Tabelle der
 * zugehoerigen Namen (MEVV_CAT_NAMES) angepasst werden!
 *
 * ACHTUNG: Die Konstanten duerfen nicht geaendert werden, da der MCode-
 * Parser sie zur Serialisierung verwendet!
 */

enum MTRE_cat_type {
    CAT_FLOAT      =  2,      //// These values must not be changed,
    CAT_INT        =  3,      ////
    CAT_RAT        =  4,      ////
    CAT_COMPLEX    =  6,      ////
    // everything up to here is assumed numerical, i.e., a single
    // number.  Do not use the numbers 5 or 7!
    CAT_INTERVAL   =  8,
    CAT_STRING     = 10,
    CAT_BOOL       = 11,
    CAT_NULL       = 13,
    CAT_NIL        = 14,
    CAT_EXT2       = 18,  ///< Special type used inside the MCODE
    CAT_FRAME      = 19,  ///< interactive namespaces for variables
    CAT_IDENT      = 20,
    CAT_SET_FINITE = 21,
    CAT_STAT_LIST  = 23,
    CAT_ARRAY      = 24,
    CAT_TABLE      = 25,
    CAT_EXPR       = 26,
    CAT_FUNC_ENV   = 27,
    CAT_VAR        = 28,
    CAT_PROC_ENV   = 29,
    CAT_EXEC       = 31,
    CAT_DEBUG      = 32,
    CAT_PROC       = 33,
    CAT_POLY       = 34,
    CAT_DOM        = 35,
    CAT_EXT        = 36,
    CAT_FAILED     = 37,
// 38, 39 were CAT_POLYGON, CAT_POINT
    CAT_HFARRAY    = 38,
// 40 was CAT_RPOLY
    // Attention MUPC_MaxCatTypes is 50 but if one chooses a number greater
    // than 42 one have to increase the definement MEVC_MAX_OPERANDS because
    // otherwise the definement MEV_CAT_2_MEV finds an entry in
    // MEVV_LegalOpTab which does not exist
};

#define MUPC_MaxCatTypes 50

#define MUPC_real         5
#define MUPC_num          7
#define MUPC_simple      20

/********************* Konstanten ****************************************/

#define MUPC_MaxStorTypes  120   /* Maximale Anzahl der verschiedenen    */
                                 /* Speichertypen (MMM)                  */

/*********** Rechnerabhaengige Konstanten *******************************/

#define MAX_INT        2147483647
#define MIN_INT        2147483648
// Der Wert MUPC_MAXDIGITS ist der maximale Wert den die MuPAD Variable
// DIGITS annehmen kann. Dieser Wert ist pragmatisch gewählt.
// Hintergrund: MPFR_PREC_MAX ist auf 32Bit Architekturen 2^31-1 und
//   64Bit Architekturen 2^63-1 und hierdurch ist die Genauigkeit von MPFR
//   beschränkt. Durch interne Berechnungen (siehe MCA_dec_digits_to_bin())
//   ist 2^29 daher eine gute Beschränkung für DIGITS auf der MuPAD Seite
//   die auf allen Architekturen gültig ist.
#define MUPC_MAXDIGITS 536870912 // 2^29
/************************************************************************/

#ifndef TRUE
#define TRUE      1
#endif

#ifndef FALSE
#define FALSE     0
#endif

/************************************************************************/

/* Modi fuer fopen() */

/// Maximale Länge des Zugriffsmodus auf eine Datei
#define MUPC_MAX_MODE_LENGTH 10

#ifdef WIN32

#  define MUPC_READ_BIN    "rb"
#  define MUPC_READ_TEXT   "rt"
// for all the write formats, add "c": commit. Otherwise,
// when writing to network shares, Windows occasionally does not flush
// data before quitting the program.
// see KB899149 for why not "wb"
#  define MUPC_WRITE_BIN   "w+bc"
#  define MUPC_WRITE_TEXT  "wtc"
#  define MUPC_APPEND_BIN  "abc"
#  define MUPC_APPEND_TEXT "atc"
#  define MUPC_READ_WRITE_BIN "rb+c"
#  define MUPC_READ_WRITE_TEXT "rt+c"

#else

#  define MUPC_READ_BIN    "r"
#  define MUPC_READ_TEXT   "r"
#  define MUPC_WRITE_BIN   "w"
#  define MUPC_WRITE_TEXT  "w"
#  define MUPC_APPEND_BIN  "a"
#  define MUPC_APPEND_TEXT "a"
#  define MUPC_READ_WRITE_BIN "r+"
#  define MUPC_READ_WRITE_TEXT "r+"

#endif /* !WIN32 */

/**************************  GLOBAL MACROS  *****************************/

#ifdef OLD_OUTPUT_TYPES
#define MUP_flush_stdout()  MIO_write('\0')
#else
#define MUP_flush_stdout()
#endif

#if (defined WIN32)
#  define MUP_exit(n)   { MSW_exit(n); }
#ifdef MUPAD_DLL
#  define MUP_fatal(s)  { MEVC_THROW_ERR_FATAL }
#else
#  define MUP_fatal(s)  { MSW_fatal(s); }
#endif
#else //       UNIX
#  define MUP_exit(c)   { osStopraw();  exit(c); }
#  define MUP_fatal(t)  { fprintf(stderr,"\n%s\n", (t)); \
                          fflush(stderr);                \
                          osStopraw();                   \
                          exit(MUPC_FATAL_ERR); }
#endif

/*********** Default - Werte veraenderbarer MuPAD - Systemvariablen *****/

#define MEVC_LEVEL_DEFAULT          100
#define MEVC_MAXLEVEL_DEFAULT       100
#define MEVC_MAXDEPTH_DEFAULT       500
#define MEVC_TEXTWIDTH_DEFAULT       75
// this constant is determined at startup time
// on Winsows it is 1000, on Unix it depends on the current stack size
extern long MEVC_MAXMAXDEPTH;

#define MEVC_DQ_DEFAULT       "\"" /* Darf nicht ver"andert werden */

/****************** Konstanten des Evaluierers **************************/

#define MEVC_LEVEL_INF     2147483647  /* 2^31 - 1 */

#if defined WIN32 && !defined __GNUC__
/* Dummy-Vereinbarungen */
#define kill(a,b)               0
#define getppid()               0
#endif

#define MUPC_constants_CAT_BOOL_FALSE   3  /* FALSE < UNKNOWN < TRUE ! */
#define MUPC_constants_CAT_BOOL_UNKNOWN 4
#define MUPC_constants_CAT_BOOL_TRUE    5
// MUPC_constants_RECURSIVE must be different from the the
// boolean values above
#define MUPC_constants_RECURSIVE 6


#if (defined WIN32)
#  define MUPC_PATHLIST_SEPARATOR ';' /* Trennung von Pfaden in Listen */
#  define MUPC_PATH_SEPARATOR '\\'    /* Trennung von Directory-Namen  */
#  ifdef __GNUC__
#    define MUPC_MAX_PATH 512           /* max. Pfadlaenge von Filenamen */
#  else
#    define MUPC_MAX_PATH _MAX_PATH     /* max. Pfadlaenge von Filenamen */
#  endif
#else
#  define MUPC_PATHLIST_SEPARATOR ':'
#  define MUPC_PATH_SEPARATOR '/'
#  ifdef PATH_MAX
#    define MUPC_MAX_PATH PATH_MAX
#  else
#    define MUPC_MAX_PATH 512
#  endif
#endif

#endif /* __MUP_constants__ */

/*******************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved.      */
/* DATEI:       MDM_kern.h                                                     */
/* INHALT:      Definitionen zur Verwaltung dynamischer Module in MuPAD        */
/*                                                                             */
/* Hier (incl.'MDM_base.h') werden alle globalen MDM-Definitionen vorgenommen. */
/*******************************************************************************/

#ifndef __MDM_kern__
#define __MDM_kern__

#include "MDM_base.h"                            /* Basis der Modulverwaltung */
#if !( defined ISMODULE && !defined MDMD_USE_DYNLINK )     /* nicht notwendig */
#   include "MTR_tree.h"
#endif

/** @name MDM\_kern.h */
//@{

/** @name Bezeichner der Systemfunktionen
*/
//@{
/* Die MuPAD-Bezeichner der MDM-Systemfunktionen ****************************/

/// Laden eines Moduls
#define MDMC_LOADMOD     "loadmod"
/// Ausladen eines Moduls
#define MDMC_UNLOADMOD   "unloadmod"
/// Ausfuehren einer Modulfunktion
#define MDMC_EXTERNAL    "external"
//@}

/** @name Bezeichner fuer Optionen
*/
//@{
/* Die MuPAD-Bezeichner fuer Optionen von MDM-Systemfunktionen **************/

/// Erzwingt das Ausladen statischer Module
#define MDMC_FORCE       "Force"
//@}


/** @name Suffixe der Moduldateien
*/
//@{
/* Suffixe fuer die verschiedenen MDM-Datei-Typen ***************************/

#define MDMC_SUFFIX_MDM  ".mdm"                       /* Ein MuPAD-Modul mit  */
#define MDMC_SUFFIX_GEN  ".mdg"                       /* Generischen Objekten */
#define MDMC_SUFFIX_HLP  ".mdh"                       /* Modul-Helpdatei      */
//@}


/** @name Bezeichner der Modul-Initialisierungsfunktionen
*/
//@{
/* Name der Modul-Initialisierungsfunktion **********************************/

#define MDMC_INIT_MODFUNC "initmod"
#define MDMC_EXIT_MODFUNC "exitmod"
#define MDMC_INFO_MODFUNC "infomod"
//@}


/** @name Bezeichner fuer generische Objekte
*/
//@{
/* Name des Tabelleneintrags fuer generische Methoden  **********************/

#define MDMC_GENERIC_METHODS "generic_methods"
#define MDMC_INCLUDE_METHODS "include"
//@}


/* Im EXEC-Knoten einer Modulfunktion wird hinter der remember-table ein ****/
/* direkter Verweis auf das zugehoerige Moduldomain eingetragen.         ****/

#define MDMC_EXEC_DOMAIN 4

/* Die Counter-Anzahl eines "normalen" Modulfunktion-EXEC enspricht der *****/
/* Startposition der generischen Objekte in einem erweiterten EXEC      *****/

#define MDMC_EXEC_COUNT  (MDMC_EXEC_DOMAIN+1)      /* STD: Counter-Anzahl    */
#define MDMC_GENERICS    MDMC_EXEC_COUNT            /* ERW: Generics-Position */


/* Makros *******************************************************************/

#define MDM_modul_domain(ex)   ( *MMMP(&ex,MDMC_EXEC_DOMAIN) )
#define MDM_numof_generics(ex) ( MMMcounter((ex)) - MDMC_EXEC_COUNT )


/* Globale Variablen ********************************************************/

#if !( defined ISMODULE && !defined MDMD_USE_DYNLINK )     /* nicht notwendig */
MTR_DECL_LITERAL(MDMV_EVAL_EXEC);               /* mcode: MDM_eval_exec */
#endif


/** @name Prototypen
*/
//@{
/* Prototypen der MDM-System-Funktionen *************************************/

/// Laden eines Moduls
S_Pointer MDM_eval_loadmod      ( S_Pointer      s,
                                  long           prev_func,
                                  long           eval_type,
                                  S_Pointer      exec
                                );

/// Ausladen eines Moduls
S_Pointer MDM_eval_unloadmod    ( S_Pointer      s,
                                  long           prev_func,
                                  long           eval_type,
                                  S_Pointer      exec
                                );

/// Aufruf einer Modulfunktion
S_Pointer MDM_eval_external     ( S_Pointer      s,
                                  long           prev_func,
                                  long           eval_type,
                                  S_Pointer      exec
                                );


/* Prototypen weiterer Funktionen *******************************************/

/// Pruefen der Namensgueltigkeit
long      MDM_invalid_name      ( CONST char    *name );

/// Erstellen einer Modul-Funktionsumgebung
S_Pointer MDM_create_func_env   ( S_Pointer      func,
                                  S_Pointer      modul,
                                  S_Pointer      domain,
                                  S_Pointer      tab_of_generics
                                );

/// Evaluieren eines Modulfunktion EXEC-Knotens
S_Pointer MDM_eval_exec         ( S_Pointer      s,
                                  long           prev_func,
                                  long           eval_type,
                                  S_Pointer      exec
                                );

/// Testen ob die Datei existiert
long      MDM_exist             ( CONST char    *name );

/// Ermitteln des Zugirffpfades
long      MDM_which             ( CONST char    *name,
                                  CONST char    *suffix,
                                  char          *fullname
                                );

/// Fehlerfunktion
void      MDM_set_error         ( long           error,
                                  const char    *text,
                                  const char    *func
                                );

/// Zugriff auf generische Objekte
S_Pointer MDM_get_generic       ( S_Pointer      exec,
                                  long           idx,
                                  long           copy
                                );

/// Initialisieren generischer Objekte
long      MDM_init_generics     ( S_Pointer     *exec
                                );

/// Lesen generischer Objekte
long      MDM_read_generics     ( char          *gen_name,
                                  S_Pointer     *tab_of_generics
                                );

/// Anhaengen generischer Objekte
long      MDM_append_generics   ( S_Pointer     *exec,
                                  S_Pointer      tab_of_generics
                                );

/// Prefix code zur Simulation von Prozeduren
void      MDM_prefix            ( S_Pointer      args,
                                  S_Pointer      pv,
                                  S_Pointer      lv,
                                  S_Pointer     *pvc,
                                  S_Pointer     *lvc
                                );

/// Postfix code zur Simulation von Prozeduren
S_Pointer MDM_postfix           ( S_Pointer      args,
                                  S_Pointer     *result,
                                  S_Pointer      exec,
                                  long           remember,
                                  long           prev_func,
                                  S_Pointer      pv,
                                  S_Pointer      lv
                                );
//@}
//@}

#endif /* __MDM_kern__ */

/* ****************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved.     */
/* DATEI:       MDM_base.h                                                    */
/* INHALT:      Definitionen zur system-unab-haengigen Modul-Verwaltung.      */
/*                                                                            */
/* Diese Datei enthaelt Basis-Definitionen der Modul-Verwaltung und wird so-  */
/* wohl vom MuPAD-Kern, als auch von jedem MuPAD-Modul benoetigt.             */
/* ****************************************************************************/

#ifndef __MDM_base__
#define __MDM_base__

#include <time.h>
#include "MMMstorage_lean.h"
#include "MUP_version.h"

/** @name MDM\_base.h */
//@{
/** @name Definements zur Kern-Versionsverwaltung
    Der Modulgenerator hat eine 3-stellige Versionsnummer, die er in jedes
    Modul eintraegt.  Stimmen die beiden hoestwertigen Ziffern dieser Nummer
    mit der im folgenden definierten Kernversion ueberein,  so ist die
    Kompatibilitaet gewaehrleistet. Andernfalls sollte das Modul NICHT geladen
    werden.
*/

/// Versionsnummer des Kerns / der Modulverwaltung im Kern
#define MDMC_RELEASE   (MUP_MAJOR*1000UL+  \
                        MUP_MINOR*100UL+MUP_PATCH*10UL+MMG_PATCH)

/// Das Definement stellt fest, ob ein korrektes Release vorliegt
#define MDM_BAD_RELEASE(r)      (r != MDMC_RELEASE)
//@}

// MDM-Infostring (fuer den Fall, dass vom Modul keiner gegeben wurde)
#define MDMC_MODINFO     "Modul: unknown\nInfo : unknown";


/** @name MDM-Fehlerkode
    Die folgenden Fehlerkodes werden von den Funktionen der systemunabhaengigen
    Modulverwaltung (Basis-Ebene) verwendet. Es ist MDMC\_OK gleich 0.
*/
//@{
///
#define MDMC_OK          0
///
#define MDMC_CLOSE       1
///
#define MDMC_EMPTY       2
///
#define MDMC_EXIST       3
///
#define MDMC_FULL        4
///
#define MDMC_INIT        5
///
#define MDMC_LOAD        6
///
#define MDMC_MEM         7
///
#define MDMC_READ        8
///
#define MDMC_TYPE        9
///
#define MDMC_UNDEF      10
///
#define MDMC_UNKNOWN    11
///
#define MDMC_USED       12
///
#define MDMC_GEN        13
///
#define MDMC_REL        14
///
#define MDMC_NAME       15
///
#define MDMC_SECURITY   16
///
#define MDMC_SIGNATURE  17
//@}

/** @name Modul-Attribute
    Module koennen Attribute tragen, die sie als Pseudomodul kennzeichnen oder
    das Ein-/Ausladeverhalten des Modulmanagers steuern.
*/
//@{
/// Leeres Attribut zum Ruecksetzen
#define MDMC_FLAG_ZERO   0

/// Modul niemals ausladen!
#define MDMC_NO_UNLOAD   1

/// Modul schnellstmoeglich ausladen!
#define MDMC_DO_UNLOAD   2

/// Pseudo-Modul (ist statisch gelinkt)
#define MDMC_PSEUDO      4

/// Secure-Modul (darf in 'kernel secure mode' geladen werden)
#define MDMC_SECURE      8
//@}

/** @name Funktions-Attribute und zugehoerige Makros
    Funktionen koennen Attribute tragen, die als unsichtbar (hidden) kenn\-
    zeichnen etc.
*/
//@{
/// Leeres Attribut zum Reucksetzen
#define MDMC_FF_ZERO     0

/// Die Funktion erscheint nicht im Interface des Moduldomains
#define MDMC_FF_HIDDEN   1

/// Die Funktion erscheint nur im Interface des Moduldomains ist
/// jedoch nicht als Modulfunktion aufrufbar. (MPROC)
#define MDMC_FF_NAME     2

/// Makro: Ist 'fun' eine unsichtbare Funktion ?
#define MDMD_IS_HIDDEN(fun) ( (fun).attr & MDMC_FF_HIDDEN )

/// Makro: Ist 'fun' eine unsichtbare Funktion ?
#define MDMD_IS_NAME(fun)   ( (fun).attr & MDMC_FF_NAME   )
//@}


/** @name Laengen fuer interne Listen und Puffer
    Aus Gruenden der Effizienz, des Aufwandes und aufgrund der Tatsache
    dass die hier behandelten Probleme klein sind, werden fuer die
    Modulverwaltung statische Listen und Puffer eingesetzt.
*/
//@{
/// Maximale Anzahl gleichzeitig geladener Module (Ueberlauf ausgeschlossen)
#define MDMC_LIST_MAX   256

/// Laenge fuer temporaere Puffer (Bytes)
#define MDM_BUF_LEN    2048
//@}

/** @name Typen und Datenstruktutren der Modulverwaltung
    Die hier aufgefuehrten Typen werden vornehmlich in der system- und CAS-
    unabhaengigen Basis-Ebene der Modulverwaltung eingesetzt.
*/
//@{
/// Zeiger auf eine Evaluierungsfunktion des MuPAD-Kerns
typedef S_Pointer (*MDM_jump_t)
                        ( S_Pointer           s,
                          long                prev_func,
                          long                eval_type,
                          S_Pointer           exec
                        );

/// Funktions-Verwaltungs-Struktur
class MDM_fun_t {
public:
                                        /// Der (MuPAD-)Name der Funktion
   const char    *name;

                                        /// ggf. Einsprungadresse der Funktion
   MDM_jump_t    jump;

                                        /// Funktionsattribute
   unsigned int  attr;
} ;

/// Zeiger auf die Kernroutine zur Adressevaluierung
typedef MDM_jump_t (*MDM_jump_fun_t) (
                     CONST unsigned long index,
                     CONST char*         file,
                     CONST unsigned long line );

/// Zeiger auf die (Pseudo-)Modul-Initialisierungsfunktion
typedef long (*MDM_pinit_t)
                        ( unsigned long   release,
                          unsigned long  *lsc,
                          const char    **info,
                          unsigned long  *flags,
                          long           *funcs,
                          MDM_fun_t     **func_list,
                          MDM_jump_fun_t  kernel
                        );

/// Modul-Verwaltungs-Struktur
class MDM_mod_t {
public:
                                         /// Kompatibilitaetskode: 3st. Release
   unsigned long    mmg_release;
                                         /// Der (MuPAD-)Name des Moduls
   char            *name;
                                         /// lsc des Moduls
   unsigned long    lsc;
                                         /// Der Infostring zum Modul
   const char      *info;
                                         /// System-ab-haengiger Modul-Handle
   void            *handle;
                                         /// Vektor der Funktions-Handle
   MDM_fun_t       *func;
                                         /// Anz. der Modul-Funktionen
   long             funcs;
                                         /// Flags des Moduls
   unsigned long    flags;
                                         /// Anz. aktiver Modul-Funktionen
   long             active;
                                         /// Zeit des letzten Zugriffs
   time_t           access;
} ;

/// Struktur der Modul-Verwaltungsliste
class MDM_list_t {
public:
                                         /// Vektor der Moduleintraege
   MDM_mod_t      **mod;
                                         /// Anz. der geladenen Module
   long             len;
                                         /// Maximale Anz. geladener Module
   long             max;
} ;

/// Pseudomodul-Verwaltungs-Struktur
class MDM_pmod_t {
public:
        const char      *name;
                                      /// Modul Initialisierungfunktion
        MDM_pinit_t     *init;
} ;
//@}

// Prototypen globaler Variablen (Kern)

extern MDM_list_t       *MDMV_list;
extern long              MDMV_support;
extern long              MDMV_unload_support;
extern time_t            MDMV_age_max;
extern time_t            MDMV_aging;
extern char              MDMV_version[256];

// Prototypen globaler Funktionen (Kern)

extern long              MDM_init       ( CONST long list_max );
extern void              MDM_exit       (  );
extern long              MDM_reset      (  );
extern long              MDM_kick_out   (  );
extern void              MDM_aging      (  );
extern void              MDM_aging_intr (  );
extern long              MDM_load       ( CONST char     *name,
                                          MDM_mod_t     **modul );
extern long              MDM_unload     ( CONST char     *name,
                                          MDM_mod_t      *modul,
                                          long            force );
extern long              MDM_call       ( CONST char     *mod_name,
                                          CONST char     *fun_name,
                                          S_Pointer      *result,
                                          S_Pointer       s,
                                          long            prev_func,
                                          long            eval_type,
                                          S_Pointer       exec );
extern MDM_jump_t        MDM_object     ( CONST unsigned long index,
                                          CONST char*         file,
                                          CONST unsigned long line );


// Prototypen weiterer Verwaltungs-Funktionen (Kern, wizards only)

// Hier muss Andi noch etwas schreiben
extern MDM_mod_t        *MDM_get_entry  ( CONST char *name );


// Prototypen zum Debuggen (for wizards only)

// Anzahl der Pseudomodule
extern long              MDMV_pmod_num;

// Liste  der Pseudomodule
extern MDM_pmod_t        MDMV_pmod[];

// Laenge der Adresstabelle
extern long              MDMV_object_tab_len;

// Adresstabelle des Kerns
extern MDM_jump_t        MDMV_object_tab[];

//@}

#endif /* __MDM_base__ */

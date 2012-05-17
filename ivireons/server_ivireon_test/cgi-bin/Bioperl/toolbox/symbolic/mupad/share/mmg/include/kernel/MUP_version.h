/**************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved. */
/* FILE: MUP_version.h                                                    */
/**************************************************************************/

/* Die Variablen MUP_* und COPYRIGHT_DATE werden auch fuer den Installer
   verwendet.  Bei strukturellen Aenderungen und Umbenennungen muss auch
   QT/INSTALL/mkSetup.sh angefasst werden.                                */


/* Fuer mupad und mmg */

#define MUP_MAJOR 5    /* Major Release Number */
#define MUP_MINOR 5    /* Minor Release Number */
#define MUP_PATCH 0    /* Patch Level */

#define MUP_SETUPPATCH 1    /* Patch Level of the Setup */

#define MUPAD_VERSION_MAJOR  "5"  // wie oben, nur Strings
#define MUPAD_VERSION_MINOR  "5"
#define MUPAD_VERSION_PATCH  "0"

#define MUPAD_VERSION_SETUPPATCH  "1"

// used in frontends about box
#define MATLAB_VERSION  "R2010b"

#define MMG_PATCH 0    /* Patch Level des Modul-Generators */


#define MMG_VERSION "MMG -- MuPAD-Module-Generator -- V-5.5.0-0"

/* Jahreszahl fuer Copyright-Hinweis im Banner */
#define COPYRIGHT_DATE  "2010"

#define MUPAD_VERSION_YEAR  COPYRIGHT_DATE



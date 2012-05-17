/******************************************************************************/
/* MODUL  : stdmod - Extended Module Management                               */
/* AUTHOR : Andreas Sorgatz                                                   */
/* CREATED: 19/04/93                                                          */
/* CHANGED: 27/08/99                                                          */
/*                                                                            */
/* age      : Get/Set maximum age of modules (aging algorithm)                */
/* help     : Get the module help-information in a string                     */
/* max      : Get/Set maximum number of simultaneously loaded modules         */
/* stat     : Get current state of module management in a table               */
/* which    : Get fullname (path) of a module                                 */
/******************************************************************************/

MMG( attribute = "secure" )
MMG( info = "Module: Extended Module Management" )

#include "MTBfile.h"                      // Module ToolBox for ´file´ support
#include <time.h>

/******************************************************************************/
/* FUNCTION: age( [max : DOM_INT] [, interval : DOM_INT] ) : DOM_INT          */
/*                                                                            */
/* The default value of 'max' is '0', which means that aging is inactive. If  */
/* 'max' is set to a value in [1..3600], module aging will be activated. Then */
/* all (non-static) modules,which was't used for 'max'-th seconds will be un- */
/* loaded automatically.  The value 'interval' determines the minimum number  */
/* seconds between two calls of the aging algorithm. If no argument is given, */
/* this function returns the current value of 'max'.                          */
/* The module aging algorithm is periodically called by the MuPAD kernel and  */
/* also from the functions 'loadmod', 'unloadmod' and 'age'.                  */
/* Systems with interval-timer support may call it asynchron, too.            */
/******************************************************************************/
MFUNC( age, MCnop )
{   
    MDM_aging();                        // Run the module aging algorithm first
    MFnargsCheckRange(0,2);

    if( MVnargs == 0 )                  // No paramter ==> return current value
        MFreturn( MFlong((long) MDMV_age_max) );

    MFargCheck( 1, DOM_INT );

    long  maxage = MFlong( MFarg(1) );
    if( maxage < 0 || maxage > 3600 )
        MFerror( "Specified age is out of range 1..3600" );
    MDMV_age_max = maxage;

    if( MVnargs == 2 ) {
        MFargCheck( 2, DOM_INT );

        long  interval = MFlong( MFarg(2) );
        if( interval < 1 ||  interval > 60 )
            MFerror("Specified interval is out of range 1..60");
        MDMV_aging = interval; 
    } 

    MFreturn( MFlong((long) MDMV_age_max) );
} MFEND

/******************************************************************************/
#define STDMOD_HELP_REST        " -->"
#define STDMOD_HELP_FBEGIN      "<!-- BEGIN-FUNC "
#define STDMOD_HELP_FEND        "<!-- END-FUNC -->"

/******************************************************************************/
/* FUNCTION: help( mname : DOM_STRING [,fname : DOM_STRING] ) : DOM_STING     */
/*                                                                            */
/* If the function can't find a help-file for module 'mname' or a description */
/* of its module-function 'fname', FAIL will be returned. Otherwise the func- */
/* returns the description  or  (if no 'fname' is given)  the general infor-  */
/* mation about the module. This function is called from the library function */
/* 'module::help' to print out help pages.                                    */
/******************************************************************************/
MFUNC( help, MCnop )
{
    MDM_aging();                        // Run the module aging algorithm first
    MFnargsCheckRange(1,2);

    char  *fun, *mod;

    if( MVnargs == 2 ) {
        if( !MFisString(MFarg(2)) ) 
            MFerror( "Second argument must be a function name string" );
        fun = MFstring( MFarg(2) );
    } else {
      fun = (char*) "\0";
    }

    if( !MFisString(MFarg(1)) ) 
        MFerror(" First argument must be a module name string" );
    mod = MFstring( MFarg(1) );
    
    // Look for help file and open it //////////////////////////////////////////

    char   help[MCpathMaxLen];

    if( strlen(mod)+strlen(fun) > (MCpathMaxLen/2) )
        MFerror("Module or function name is too long" );

    if( MFwhich(help,mod,MCsuffixModuleHelp) != MDMC_OK ) {
        MFpathAppend( help, MVpathAsciiHelp, mod );
        strcat( help, MCsuffixModuleHelp );
        if( !MFexist(help) ) 
            MFreturn( MFcopy(MVfail) );
    }

    // Get contents of help file in a character string /////////////////////////

    char  *text = MFfileContents( help );
    char  *start, *end;
    
    if( !*fun ) {                      // Get general module introduction page

        start = text;
        if( (end=strstr(text,STDMOD_HELP_FBEGIN)) != NULL ) {
            *end = '\0';
        }
        while( --end > start && isspace(*end) ) *end = '\0';

    } else {                           // Get description of specified function

        sprintf( help, "%s%s%s", STDMOD_HELP_FBEGIN, fun, STDMOD_HELP_REST );
        if( (start = strstr(text,help)) == NULL ) {
            MFcfree( text );
            MFreturn( MFcopy(MVfail) );
        }
        start += strlen(help);
        if( (end = strstr(start,STDMOD_HELP_FEND)) == NULL ) {
            MFcfree( text );
            MFreturn( MFcopy(MVfail) );
        }
        *end = '\0';
        while( --end > start && isspace(*end) ) *end = '\0';

    }

    // Hack: Convert UNIX control characters into blank characters
#ifdef WIN32
    for( end = start; *end; end++ ) {
        if( *end == '\r' ) {
            *end = ' ';
        }
    }
#endif

    // Convert to MuPAD character string and free allocated memory /////////////
    MTcell  strg = MFstring( start );
    MFsig( strg );
    MFcfree( text );

    MFreturn( strg )
} MFEND


/******************************************************************************/
/* FUNCTION: max( [max : DOM_INT] ) : DOM_INT                                 */
/*                                                                            */
/* The default value of 'max' depends on the system. The given value must be  */
/* in the range [ max{0,#(loaded)}..256 ]. After that, the maximum number of  */
/* simultaniously loaded moduls is limited to 'max'. If unloading modules is  */
/* supported on the current system,then new modules may replace old modules.  */
/******************************************************************************/
MFUNC( max, MCnop )
{
    MDM_aging();                        // Run the module aging algorithm first
    MFnargsCheckRange( 0, 1 );

    if( MVnargs == 0 ) 
        MFreturn( MFlong(MDMV_list->max) ) 

    MFargCheck( 1, DOM_INT );
    
    long max = MFlong( MFarg(1) );
    if( max < 1L ) 
        MFerror( "Integer be positive" );
    if( max < MDMV_list->len )
        MFerror( "Integer must be greater than number of loaded modules" );
    if( max > MDMC_LIST_MAX ) {
        MFerror( "Integer is too large" );
    }
    MDMV_list->max = max;

    MFreturn( MFlong(max) )
} MFEND


/******************************************************************************/
/* FUNCTION: stat() : DOM_TABLE                                               */
/*                                                                            */
/* Returns the current state of the MuPAD module management in a table:       */
/* table(  "mupad" = [ 'num. of active entries in kernel function table',     */
/*                      'num. of all    entries in kernel function table',    */
/*                      'MuPAD kernel supports unloading of modules ?' ],     */
/*         "aging"  = [ 'maximum age of modules (seconds)',                   */
/*                      'minimum interval between tow aging-calls (seconds)', */
/*                      'name of least-recently-used module' ],               */
/*         "modul"  = [ 'number of active modules',                           */
/*                      'number of loaded modules',                           */
/*                      'maximum number of simultaniously loaded modules' ],  */
/*         "entry"  = table( 'name of module' = [ 'Age of module',            */
/*                                               'num. of active functions',  */
/*                                               'num. of all functions',     */
/*                                               'set of attributes', ],      */
/*                           ...                                              */
/*                    )                                                       */
/* )                                                                          */
/******************************************************************************/
MFUNC( stat, MCnop )
{
    MDM_aging();                        // Run the module aging algorithm first
    MFnargsCheck( 0 );

    /*** Look for active entries in the kernel function table *************/
    
    long used, i;
    for( used = i = 0L; i < MDMV_object_tab_len; i++ ) { 
        if( MDMV_object_tab[i] != NULL ) 
            used++;
    }
    
    /*** Determine the number of active modules and the LRU module ********/
    
    long active, lru;
    for( active = lru = i = 0L; i < MDMV_list->len; i++ ) {
        if( MDMV_list->mod[i]->active ) 
            active++; 
        if( MDMV_list->mod[i]->access < MDMV_list->mod[lru]->access ) 
            lru = i;
    }
    
    MTcell table = MFnewTable();
    MTcell list, mtable, set;

            /*** MUPAD ****************************************************/

    list = MFnewList( 3 );
    MFsetList( &list, 0, MFlong(used               ) );
    MFsetList( &list, 1, MFlong(MDMV_object_tab_len) );
    MFsetList( &list, 2, MFcopy(MDMV_unload_support ? MVtrue:MVfalse) );
    MFsig( list );
    MFinsTable( &table, MFstring("mupad"), list );

            /*** MPATH ****************************************************/

    MFinsTable( &table, MFstring("mpath"), MFstring(MVpathModuleBin) );

            /*** AGING ****************************************************/

    list = MFnewList( 3 );
    MFsetList( &list, 0, MFlong  ((long)MDMV_age_max       ) );
    MFsetList( &list, 1, MFlong  ((long)MDMV_aging         ) );
    MFsetList( &list, 2, MFstring(MDMV_list->mod[lru]->name) );
    MFsig( list );
    MFinsTable( &table, MFstring("aging"), list );

            /*** MODUL ****************************************************/

    list = MFnewList( 3 );
    MFsetList( &list, 0, MFlong(active        ) );
    MFsetList( &list, 1, MFlong(MDMV_list->len) );
    MFsetList( &list, 2, MFlong(MDMV_list->max) );
    MFsig( list );
    MFinsTable( &table, MFstring("modul"), list );

            /*** psmod ***************************************************/

    set = MFnewSet();
    for( i = 0L; i < MDMV_pmod_num; i++ ) {
         MFinsSet( set, MFstring(MDMV_pmod[i].name) );
    }
    MFsig( set );
    MFinsTable( &table, MFstring("psmod"), set );

            /*** ENTRY ****************************************************/

    mtable = MFnewTable();
    
    for( i = 0L; i < MDMV_list->len; i++ ) {
            
                    /*** Set of module attributes *************************/

        set = MFnewSet();
        if( (MDMV_list->mod[i]->flags) & MDMC_NO_UNLOAD ) { 
            MFinsSet( set, MFstring("static") );
        }
        if( (MDMV_list->mod[i]->flags) & MDMC_DO_UNLOAD ) { 
            MFinsSet( set, MFstring("unload") );
        }
        if( (MDMV_list->mod[i]->flags) & MDMC_PSEUDO ) { 
            MFinsSet( set, MFstring("pseudo") );
        }
        if( (MDMV_list->mod[i]->flags) & MDMC_SECURE ) { 
            MFinsSet( set, MFstring("secure") );
        }

        // 64Bit Windows: sizeof(int)<>sizeof(size_t)
        long sec = static_cast<long>(time(NULL) - MDMV_list->mod[i]->access);
            
        list = MFnewList( 4 );
        MFsetList( &list, 0, MFlong(sec                      ) );
        MFsetList( &list, 1, MFlong(MDMV_list->mod[i]->active) );
        MFsetList( &list, 2, MFlong(MDMV_list->mod[i]->funcs ) );
        MFsetList( &list, 3, set                               );
        MFsig( list );
        MFinsTable( &mtable, MFstring(MDMV_list->mod[i]->name), list );
    }
    MFinsTable( &table, MFstring("entry"), mtable );

    /*** Return data ******************************************************/

    MFreturn( table )
} MFEND


/******************************************************************************/
/* FUNCTION: which( name : DOM_STRING ) : DOM_STRING                          */
/*                                                                            */
/* If the given module was found in the MuPAD modul directory,the directories */
/* defined in  'READ_PATH'  or in the current directory, then the fullname is */
/* returned. Otherwise, the function returns 'FAIL'.                          */
/******************************************************************************/
MFUNC( which, MCnop )
{
    MDM_aging();                        // Run the module aging algorithm first
        
    MFnargsCheck( 1 );
    MFargCheck( 1, DOM_STRING );
        
    char  path[MCpathMaxLen];
    if( strlen(MFstring(MFarg(1))) > (MCpathMaxLen/2) ) 
        MFerror( "Module or function name is too long" );

    if( MFwhich(path,MFstring(MFarg(1)),MCsuffixModuleBin) != MDMC_OK ) 
        MFreturn( MFcopy(MVfail) );

    MFreturn( MFstring(path) );
} MFEND


/* File: rtwdemo_shrlib_app.c $Revision: 1.1.8.1 $ 
 *
 * Abstract:
 *      Example application program to be used with shared library target 
 * generated from rtwdemo_shrlib.mdl
 * 
 * Usage:
 *      See run_rtwdemo_shrlib_app.m for an example script to compile, link 
 * and execute this example.
 * 
 * Copyright 2006-2007 The MathWorks, Inc.
 */

#include <stdio.h>
#include <stddef.h>
#include "rtwtypes.h"

#if (defined(_WIN32)||defined(_WIN64)) /* WINDOWS */
#include <windows.h>
#define GETSYMBOLADDR GetProcAddress
#define LOADLIB LoadLibrary
#define CLOSELIB FreeLibrary

#else /* UNIX */
#include <dlfcn.h>
#define GETSYMBOLADDR dlsym
#define LOADLIB dlopen
#define CLOSELIB dlclose

#endif

#include "rtwdemo_shrlib_app.h"

int main()
{
    int32_T i;
    void* handleLib;
    void (*mdl_initialize)(boolean_T);
    void (*mdl_step)(void);
    void (*mdl_terminate)(void);
    
    ExternalInputs_rtwdemo_shrlib (*mdl_Uptr);
    ExternalOutputs_rtwdemo_shrlib (*mdl_Yptr);
	
    uint8_T (*sum_outptr);

#if defined(_WIN64)
    handleLib = LOADLIB("./rtwdemo_shrlib_win64.dll");
#else
#if defined(_WIN32)
    handleLib = LOADLIB("./rtwdemo_shrlib_win32.dll");
#else /* UNIX */
    handleLib = LOADLIB("./rtwdemo_shrlib.so", RTLD_LAZY);
#endif
#endif

    if (!handleLib) {
        printf("Cannot open the specified shared library.\n");
        return(-1);
    }

#if (defined(LCCDLL)||defined(BORLANDCDLL))
    /* Exported symbols contain leading underscores when DLL is linked with LCC or BORLANDC */
    mdl_initialize =(void(*)(boolean_T))GETSYMBOLADDR(handleLib , "_rtwdemo_shrlib_initialize");
    mdl_step       =(void(*)(void))GETSYMBOLADDR(handleLib , "_rtwdemo_shrlib_step");
    mdl_terminate  =(void(*)(void))GETSYMBOLADDR(handleLib , "_rtwdemo_shrlib_terminate");
    mdl_Uptr       =(ExternalInputs_rtwdemo_shrlib*)GETSYMBOLADDR(handleLib , "_rtwdemo_shrlib_U");
    mdl_Yptr       =(ExternalOutputs_rtwdemo_shrlib*)GETSYMBOLADDR(handleLib , "_rtwdemo_shrlib_Y");
    sum_outptr     =(uint8_T*)GETSYMBOLADDR(handleLib , "_sum_out");
#else	
    mdl_initialize =(void(*)(boolean_T))GETSYMBOLADDR(handleLib , "rtwdemo_shrlib_initialize");
    mdl_step       =(void(*)(void))GETSYMBOLADDR(handleLib , "rtwdemo_shrlib_step");
    mdl_terminate  =(void(*)(void))GETSYMBOLADDR(handleLib , "rtwdemo_shrlib_terminate");
    mdl_Uptr       =(ExternalInputs_rtwdemo_shrlib*)GETSYMBOLADDR(handleLib , "rtwdemo_shrlib_U");
    mdl_Yptr       =(ExternalOutputs_rtwdemo_shrlib*)GETSYMBOLADDR(handleLib , "rtwdemo_shrlib_Y");
    sum_outptr     =(uint8_T*)GETSYMBOLADDR(handleLib , "sum_out");
#endif
    
    if ((mdl_initialize && mdl_step && mdl_terminate && mdl_Uptr && mdl_Yptr && sum_outptr)) {
        /* === user application initialization function === */
        mdl_initialize(1); 
        /* insert other user defined application initialization code here */
        
        /* === user application step function === */
        for(i=0;i<=12;i++){ 
            mdl_Uptr->Input = i;
            mdl_step(); 
            printf("Counter out(sum_out): %d\tAmplifier in(Input): %d\tout(Output): %d\n", 
                   *sum_outptr, i, mdl_Yptr->Output); 
            /* insert other user defined application step function code here */
        }
        
        /* === user application terminate function === */
        mdl_terminate();
        /* insert other user defined application termination code here */
    }
    else {
        printf("Cannot locate the specified reference(s) in the shared library.\n");
        return(-1);
    }	
    return(CLOSELIB(handleLib));
}

/* End of file */


/*
 * MATLAB Compiler: 4.8 (R2008a)
 * Date: Fri Mar 16 16:19:40 2012
 * Arguments: "-B" "macro_default" "-o" "ivireonn" "-W" "main" "-d"
 * "/home/seguritan/segall-lab/src" "-T"
 * "link:exe" "-v" "-N"
 * "/home/seguritan/segall-lab/nets/ann_vote.m" "-a"
 * "/home/seguritan/segall-lab/nets/AA_ONLY_96.15_129" "-a"
 * "/home/seguritan/segall-lab/nets/AA_ONLY_94.94_39" "-a"
 * "/home/seguritan/segall-lab/nets/AA_ONLY_93.67_67" "-a"
 * "/home/seguritan/segall-lab/nets/AA_ONLY_93.67_38" "-a"
 * "/home/seguritan/segall-lab/nets/AA_ONLY_93.67_37" 
 */

#include <stdio.h>
#include "mclmcrrt.h"
#ifdef __cplusplus
extern "C" {
#endif

extern mclComponentData __MCC_ivireonn_component_data;

#ifdef __cplusplus
}
#endif

static HMCRINSTANCE _mcr_inst = NULL;


#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_ivireonn_C_API 
#define LIB_ivireonn_C_API /* No special import/export declaration */
#endif

LIB_ivireonn_C_API 
bool MW_CALL_CONV ivireonnInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler
)
{
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!mclInitializeComponentInstanceWithEmbeddedCTF(&_mcr_inst,
                                                     &__MCC_ivireonn_component_data,
                                                     true, NoObjectType,
                                                     ExeTarget, error_handler,
                                                     print_handler, 5502540, (void *)(ivireonnInitializeWithHandlers)))
    return false;
  return true;
}

LIB_ivireonn_C_API 
bool MW_CALL_CONV ivireonnInitialize(void)
{
  return ivireonnInitializeWithHandlers(mclDefaultErrorHandler,
                                        mclDefaultPrintHandler);
}

LIB_ivireonn_C_API 
void MW_CALL_CONV ivireonnTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

int run_main(int argc, const char **argv)
{
  int _retval;
  /* Generate and populate the path_to_component. */
  char path_to_component[(PATH_MAX*2)+1];
  separatePathName(argv[0], path_to_component, (PATH_MAX*2)+1);
  __MCC_ivireonn_component_data.path_to_component = path_to_component; 
  if (!ivireonnInitialize()) {
    return -1;
  }
  _retval = mclMain(_mcr_inst, argc, argv, "ann_vote", 1);
  if (_retval == 0 /* no error */) mclWaitForFiguresToDie(NULL);
  ivireonnTerminate();
  mclTerminateApplication();
  return _retval;
}

int main(int argc, const char **argv)
{
  if (!mclInitializeApplication(
    __MCC_ivireonn_component_data.runtime_options,
    __MCC_ivireonn_component_data.runtime_option_count))
    return 0;
  
  return mclRunMain(run_main, argc, argv);
}

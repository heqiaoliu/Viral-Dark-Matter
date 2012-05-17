/**
 * Use this include file to conditionalize header files
 * for use within a library, outside of the library, 
 * or for standalone code. 
 *
 * The essential byproduct is the define of SPC_DECL.
 */

#ifndef SPC_DECL_H
#define SPC_DECL_H


#if defined(SPC_EXPORTS)
#  include "version.h"
#  define SPC_DECL DLL_EXPORT_SYM
#elif defined(SPC_IMPORTS)
#  include "version.h"
#  define SPC_DECL DLL_IMPORT_SYM
#else
#  define SPC_DECL
#endif


#endif /* SPC_DECL_H */

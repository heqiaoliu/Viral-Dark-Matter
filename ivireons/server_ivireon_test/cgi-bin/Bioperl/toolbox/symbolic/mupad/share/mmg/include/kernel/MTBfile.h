///////////////////////////////////////////////////////////////////////////////
// Part of the MuPAD product code. Protected by law. All rights reserved.
// TOOLBOX : MTBfile.h
// CONTENTS: Support for accessing files and directories in dynamic modules
//
// This header file contains extension of the MuPAD Application Programming
// Interface (MAPI)  and facilitates the  development of dynamic modules in
// MuPAD. This file must only refer to MuPAD objects listed in  ´MDM_mod.h´
// and ´MKT_mapi.h´.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
#if   (defined MACINTOSH)
#elif (defined WIN32)
#else
#   include <sys/types.h>
#   include <sys/stat.h>
#endif


///////////////////////////////////////////////////////////////////////////////
// CONS: MCpathMaxLen
// DESC: Specifies maximal length of a pathname. This constant can be
//       used to specify the length of character string buffers.
///////////////////////////////////////////////////////////////////////////////
#define MCpathMaxLen 512


///////////////////////////////////////////////////////////////////////////////
// CONS: MCpathRoot
// DESC: Specifies the token which is used to specify the root directory
//       of a file system. This token depends on the operating system.
///////////////////////////////////////////////////////////////////////////////
#if   (defined WIN32)
#  define MCpathRoot          "\\"
#elif (defined MACINTOSH)
#  define MCpathRoot          "::"
#else         /* UNIX */
#  define MCpathRoot          "/"
#endif


///////////////////////////////////////////////////////////////////////////////
// CONS: MCpathDelimiter
// DESC: Specifies the token which is used as pathname delimiter. This
//       token depends on the operating system.
///////////////////////////////////////////////////////////////////////////////
#if   (defined WIN32)
#  define MCpathDelimiter     "\\"
#elif (defined MACINTOSH)
#  define MCpathDelimiter     ":"
#else         /* UNIX */
#  define MCpathDelimiter     "/"
#endif


///////////////////////////////////////////////////////////////////////////////
// CONS: MCsuffixModuleBin, MCsuffixModuleGen, MCsuffixModuleHelp
// DESC: Specifies the character string which are used as suffix for
//       module binary files,  module online documentation files and
//       module scipt files for embedded (generic) objects.
///////////////////////////////////////////////////////////////////////////////
#define MCsuffixModuleBin    MDMC_SUFFIX_MDM
#define MCsuffixModuleGen    MDMC_SUFFIX_GEN
#define MCsuffixModuleHelp   MDMC_SUFFIX_HLP


///////////////////////////////////////////////////////////////////////////////
// CONS: MVpathAsciiHelp, MVpathModuleBin
// DESC: Specifies the path variables which store the current pathnames
//       of the MuPAD ASCII online documentation and the dynamic module
//       binary files.
///////////////////////////////////////////////////////////////////////////////
#define MVpathAsciiHelp      MUPV_env.helpPath
#define MVpathModuleBin      MUPV_env.modPath


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFpathAppend
// ARGS: dest    - character string buffer to store the new pathname
//       prefix  - first part of the new pathname
//       postfix - second part of the new pathname
// DESC: Constructs a new pathname by concating the  ´prefix´ and  ´postfix´
//       using the correct path delimiter depending on the operating system.
//       ATTENTION:  The buffer ´dest´ must be large enough to store the new
//       pathname. The routine returns the return code of ´sprintf´.
///////////////////////////////////////////////////////////////////////////////
inline int MFpathAppend( char *dest, char *prefix, char *postfix )
{
  return( sprintf(dest, "%s%s%s", prefix, MCpathDelimiter, postfix) );
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFexist
// ARGS: name - name of the file to be checked
// DESC: If the specified file exists, the routine returns a value unequal
//       to zero. Otherwise it returns zero (´0´).
///////////////////////////////////////////////////////////////////////////////
inline int MFexist( char *name )
{
  return( MDM_exist(name) );
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFwhich
// ARGS: fullname - character string buffer to store the absolute pathname
//       name     - name of the file to be searched (without suffix)
//       suffix   - suffix (with a leading dot) of the file to be searched
// DESC: Searches for the  specified file  in the directories specified in
//       the MuPAD variable  ´READ_PATH´ and in the current directory. The
//       routine returns the return code zero ('0') and the absolute path-
//       name in the variable ´fullname´ if the file was found.  Otherwise
//       it returns an error code unequal to zero.
///////////////////////////////////////////////////////////////////////////////
inline int MFwhich( char *fullname, char *name, const char *suffix )
{
  return( MDM_which(name, suffix, fullname) );
}


///////////////////////////////////////////////////////////////////////////////
// FUNC: MFfileContents
// ARGS: name - name of the file to be read in
// DESC: Returns the contents of the specified file as character string.
//       If an error occures, the routine returns NULL.
///////////////////////////////////////////////////////////////////////////////
inline char *MFfileContents( char *name )
{
    FILE  *file = fopen( name, "rb" );
    if( file == NULL ) {
        return( NULL );
    }

    char *text = NULL;
    unsigned int cursize = 256;
    size_t read = 0, read_in_all = 0;
    text = (char*) MFcmalloc(cursize+1);
    while((read = fread(text + read_in_all, 1,
                        cursize - read_in_all, file))) {
      read_in_all += read;
      if(read_in_all >= cursize) {
        cursize *= 2;
        char *tmp = (char*) MFcmalloc(cursize+1);
        memcpy(tmp, text, read_in_all);
        MFcfree(text);
        text = tmp;
      }
    }
    text[read_in_all] = '\0';
    fclose( file );
    return( text );
}

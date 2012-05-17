///////////////////////////////////////////////////////////////////////////////
// MODULE : shell - tool to access shell commands and launch programs 
///////////////////////////////////////////////////////////////////////////////

MMG( info = "Module: Shell command, directory and file utilities" ) 

///////////////////////////////////////////////////////////////////////////////

#include <sys/types.h> 
#include <time.h>

#if defined WIN32
#  include <windows.h> 
#  include <direct.h>
#else
#  include <dirent.h>   
#  include <time.h>   
#endif

#include "MTBfile.h"

///////////////////////////////////////////////////////////////////////////////
// FUNCTION: changeDir( dir:DOM_STRING ) : DOM_BOOL
// 
// The function changes the current working directory of the MuPAD kernel to
// the path 'dir' and returns TRUE. If this operation fails, the function
// returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( changeDir, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  MFreturn(MFbool( !chdir(MFstring(MFarg(1))) ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: currentDir() : DOM_STRING
// 
// The function returns the name of the current working directory of the MuPAD
// kernel.
///////////////////////////////////////////////////////////////////////////////

MFUNC( currentDir, MCnop )
{ MFnargsCheck(0);

  char buffer[1024+1];

  if( getcwd(buffer,1024)==NULL ) 

	  *buffer='\0';

  MFreturn( MFstring(buffer) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: exist( file:DOM_STRING ) : DOM_BOOL
// 
// The function returns TRUE if the specified 'file' exists. Otherwise it
// returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( exist, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  MFreturn(MFbool( (MTbool) MDM_exist(MFstring(MFarg(1))) ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: find ( path:DOM_STRING [,pathlist:DOM_LIST]) : DOM_STRING 
// 
// The function looks for a directory entry named 'path' and returns its
// full pathname. If this file cannot be found, the function returns the
// value FAIL.
///////////////////////////////////////////////////////////////////////////////

MFUNC( find, MCnop )
{ MFnargsCheck(2);
  MFargCheck(1,DOM_STRING);
  MFargCheck(2,DOM_LIST  );


  char*  file=MFstring(MFarg(1));
  MTcell list=MFarg(2);
  char   path[1024];

  for( long i=0; i<MFnops(list); i++ ) {
	  if( !MFisString(MFop(list,i)) ) 
		   MFerror( "Invalid argument" );

	  sprintf( path, "%s%s%s", MFstring(MFop(list,i)), MCpathDelimiter, file );

      if( MDM_exist(path) ) 
	      MFreturn(MFstring( path ));
  }
  MFreturn(MFcopy( MVfail ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: getEnv ( varname:DOM_STRING]) : DOM_STRING 
// 
// The function returns the value of the environment variable 'varname' as
// character string. If 'varname' is undefined, the function returns the
// empty string.
///////////////////////////////////////////////////////////////////////////////

MFUNC( getEnv, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  char* strg = getenv( MFstring(MFarg(1)) );

  MFreturn( MFstring(strg == NULL ? "" : strg) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: isDir( path:DOM_STRING ):DOM_BOOL
//
// The function returns TRUE if the given path is a directory and returns
// FALSE otherwise.
///////////////////////////////////////////////////////////////////////////////

MFUNC( isDir, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  struct stat  st;	

  if( stat(MFstring(MFarg(1)),&st) == -1 )
      MFreturn( MFcopy(MVfail) );

#ifdef WIN32
  MFreturn( MFbool(((st.st_mode & _S_IFDIR) != 0)) );
#else
  MFreturn( MFbool(S_ISDIR(st.st_mode)) );
#endif
} MFEND



///////////////////////////////////////////////////////////////////////////////
// FUNCTION: isFile( path:DOM_STRING ):DOM_BOOL
//
// The function returns TRUE if the given path is a regular file and returns
// FALSE otherwise.
///////////////////////////////////////////////////////////////////////////////

MFUNC( isFile, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  struct stat  st;

  if( stat(MFstring(MFarg(1)),&st) == -1 )
      MFreturn( MFcopy(MVfail) );

#ifdef WIN32
  MFreturn( MFbool(((st.st_mode & _S_IFREG) != 0))  );
#else
  MFreturn( MFbool(S_ISREG(st.st_mode)) );
#endif
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: listDir( mask:DOM_STRING [,ListMode:{All,File,Dir}] ):DOM_STRING 
// 
// The function lists either files, directories or both of them which fits 
// into the scheme given with 'mask'. 'mask' may contain wildcards.
///////////////////////////////////////////////////////////////////////////////

MFUNC( listDir, MCnop )
{ MFnargsCheckRange(1,2);
  MFargCheck(1,DOM_STRING);

#if defined WIN32
  HANDLE            Handle;
  LPCTSTR           lpszSearchFile;
  WIN32_FIND_DATA   ffd;
  char              buffer[1024];

  sprintf( buffer, "%s\\*.*", MFstring(MFarg(1)) );
  lpszSearchFile = (LPCTSTR) buffer;

  if( strlen(lpszSearchFile) > MAX_PATH ) 
      MFreturn(MFcopy( MVfail ));

  MTcell set=MFnewSet();
  if( (Handle = FindFirstFile(lpszSearchFile,&ffd)) == INVALID_HANDLE_VALUE ) {
      MFreturn(MFcopy( MVfail ));
  }

  for( BOOL Found=1; Found; Found=FindNextFile(Handle,&ffd) ) {
      MFinsSet(set, MFstring(ffd.cFileName));
  }
  FindClose( Handle );

#else

  DIR             *dirp;
  struct dirent   *dp; 	

  MTcell set=MFnewSet();

  if( (dirp = opendir(MFstring(MFarg(1)))) == NULL ) {
      MFreturn(MFcopy( MVfail ));
  }
  for( dp = readdir(dirp); dp!=NULL; dp=readdir(dirp) ) {
      MFinsSet(set, MFstring(dp->d_name));
  }
  closedir( dirp );
#endif

  MFreturn( set );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: makeDir( dir:DOM_STRING ) : DOM_BOOL
// 
// The function creates a new directory named 'dir' and returns TRUE. If the
// directory cannot be created, the function returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( makeDir, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

#ifdef WIN32
  MFreturn(MFbool( !mkdir(MFstring(MFarg(1))) ));
#else
  MFreturn(MFbool( !mkdir(MFstring(MFarg(1)), 0777) ));
#endif
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: modified( file:DOM_STRING ) : DOM_STRING
// 
// The function returns a character string containing the date at which the
// specified 'file' was changed last.   If the corresponding file cannot be
// found, the funtion returns the value FAIL.
///////////////////////////////////////////////////////////////////////////////

MFUNC( modified, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  struct stat buf;

  if( stat(MFstring(MFarg(1)),&buf)!=0 )
      MFreturn( MFcopy(MVfail) );

  char* cs = ctime( &buf.st_atime );
  cs[24] = '\0';

  MFreturn(MFstring( cs ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: pathname( path:DOM_STRING [,...] ) : DOM_STRING 
// 
// The function concatenates all character strings given as argument to a new
// pathname. Note, that the path delimiter depends on your operating system.
///////////////////////////////////////////////////////////////////////////////

MFUNC( pathname, MCnop )
{ if( MVnargs==0 )
      MFreturn(MFstring( "" ));

  if( !MFisString(MFarg(1)) )
	  MFerror( "Invalid argument" );

  MTcell path=MFcopy(MFarg(1));

  for( long i=2; i<=MVnargs; i++ ) {
	  if( !MFisString(MFarg(i)) ) {
		  MFfree(path);
		  MFerror( "Invalid argument" );
	  }
      path=MFcall("_concat",3,path,MFstring(MCpathDelimiter),MFcopy(MFarg(i)));
  }

  MFreturn( path );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: putEnv ( varname:DOM_STRING]) : DOM_BOOL 
// 
// The function sets the environment variable 'var=value' and returns TRUE.
// If this operation fails, the function returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( putEnv, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  if( putenv(MFstring(MFarg(1))) != 0 )
      MFreturn( MFcopy(MVfalse) );

  MFreturn( MFcopy(MVtrue) );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: readFile( file:DOM_STRING [, option:DOM_IDENT] ) : DOM_STRING
// 
// The function returns the contents of the specified 'file' as a character
// string.
///////////////////////////////////////////////////////////////////////////////

MFUNC( readFile, MCnop )
{ MFnargsCheckRange(1,2);
  MFargCheck(1,DOM_STRING);

  bool binary = false;

  if( MVnargs==2 ) {
      MFargCheck(2,DOM_IDENT);
      if     ( MFisIdent(MFarg(2),"Binary") )
          binary = true;
      else if( MFisIdent(MFarg(2),"Text"  ) )
          binary = false;
      else
          MFerror("Invalid option" );
  }

  FILE  *file;
  if( (file = fopen(MFstring(MFarg(1)),(binary?"rb":"r"))) == NULL ) 
      MFerror( "Cannot open file" );

  struct stat  st;
  if( fstat(fileno(file),&st) != 0 ) {
      fclose( file );
      MFerror( "Cannot access file" );
  }

  MTcell result;

  if( binary ) { // Read Binary file as list of bytes

      result = MFnewList( st.st_size );
      int c, i;

      for( i=0; i<st.st_size; i++ ) {
          if( (c=fgetc(file)) == EOF ) {
              fclose( file );
              MFerror( "Read error" );
          }
          MFsetList( &result, i, MFint(c) );
      }
      MFsig( result );

  } else {       // Read Text file as character string

    char  *text;
    if( (text = (char*) MFcmalloc(st.st_size+1)) == NULL ) {
        fclose( file );
        MFerror( "Not enough memory" );
    }

    // Note that textsize may be less than st.st_size because
    // line breaks are converted from two to one character. 

    size_t textsize = fread( text, 1, st.st_size, file );
    text[textsize]= '\0';
    result = MFstring( text );
    MFcfree( text );

  }
  fclose( file );

  MFreturn( result );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: removeDir( dir:DOM_STRING ) : DOM_BOOL
// 
// The function removes the directory 'dir' and returns TRUE. If the directory
// cannot be removed, the function returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( removeDir, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  MFreturn(MFbool( !rmdir(MFstring(MFarg(1))) ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: removeFile( file:DOM_STRING ) : DOM_BOOL 
// 
// The function removes the file 'file' and returns TRUE. If the file cannot
// be removed, the function returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( removeFile, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  MFreturn(MFbool( !unlink(MFstring(MFarg(1))) ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: rename( file:DOM_STRING, newfile:DOM_STRING ) : DOM_BOOL 
// 
// The function renames the specified 'file' to the new name 'newfile' and
// returns TRUE. If the file or directory cannot be renamed, the function 
// returns FALSE.
///////////////////////////////////////////////////////////////////////////////

MFUNC( rename, MCnop )
{ MFnargsCheck(2);
  MFargCheck(1,DOM_STRING);
  MFargCheck(2,DOM_STRING);

  MFreturn(MFbool( !rename(MFstring(MFarg(1)), MFstring(MFarg(2))) ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: sizeofFile( file:DOM_STRING ) : DOM_INT
// 
// The function returns the length of the specified 'file' in bytes.
///////////////////////////////////////////////////////////////////////////////

MFUNC( sizeofFile, MCnop )
{ MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  struct stat buf;
  if( stat(MFstring(MFarg(1)),&buf)!=0 )
	  MFreturn( MFcopy(MVfail) );

  MFreturn(MFlong((long) buf.st_size ));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: system( program:DOM_STRING ) : DOM_INT 
// 
// The function executes a shell command or a program and returns the error
// code 0, if it was successful or a non-zero value if it failed. As a side-
// effect, under Windows 95/98/NT a command shell window may be opened.
///////////////////////////////////////////////////////////////////////////////

MFUNC( system, MCnop )
{ MFnargsCheckRange(1,2);
  MFargCheck(1,DOM_STRING);
  
  // Create command string as a physical copy

  MTcell cmd = MFstring(MFstring(MFarg(1)));

  // Create a temporary input file if necessary

  char tmpinp[512] = "\0";

  if( MVnargs==2 ) {
      MFargCheck(2,DOM_STRING);

#ifdef WIN32
      const char *tmi =  tempnam(NULL,"mt");
      if('\\' == tmi[0]) {
        ++tmi;
      }
      strcpy(tmpinp, tmi);
#else
      strcpy(tmpinp, tmpnam(NULL));
#endif
      FILE *inp = fopen( tmpinp, "w" );
      if( inp == NULL ) {
          MFfree( cmd );
          MFerror( "Cannot create input file" );
      }
      if( fputs(MFstring(MFarg(2)),inp) == EOF ) {
          fclose( inp );
          MFfree( cmd );
          MFerror( "Cannot create input file" );
      }
      fclose( inp );
      cmd = MFcall( "_concat", 3, cmd, MFstring(" < "), MFstring(tmpinp) );
  }
  
  // Create a temporary output file to check write permission

  char *tmpout ;

#ifdef WIN32
  tmpout = tempnam(NULL,"mt");
  if('\\' == tmpout[0])
    ++tmpout;
#else
  tmpout = tmpnam(NULL) ;
#endif

  FILE* out = fopen(tmpout,"w");
  if( out == NULL ) {
      if( *tmpinp  )
          unlink( tmpinp );
      MFerror("Cannot create output file");
  }
  fclose( out );
  unlink( tmpout );

  // Create and execute command

  cmd = MFcall( "_concat", 5, MFstring("("), cmd, MFstring(")"), MFstring(" > "), MFstring(tmpout) );

  long errcode = system( MFstring(cmd) );
  MFfree( cmd );

  // Read result and remove temporary files

  if( *tmpinp )
      unlink( tmpinp );

  if( errcode != 0 ) {
      unlink( tmpout );
      MFerror( "Execution failed" );
  }
  if( (out = fopen(tmpout,"r")) == NULL ) {
      unlink( tmpout );
      MFerror( "Cannot open output file" );
  }
  struct stat  st;
  if( fstat(fileno(out),&st) != 0 ) {
      fclose( out );
      unlink( tmpout );
      MFerror( "Cannot access output file" );
  }
  char* text;
  if( (text = (char*) MFcmalloc(st.st_size+1)) == NULL ) {
      fclose( out );
      unlink( tmpout );
      MFerror( "Not enough memory" );
  }
  size_t size = fread( text, 1, st.st_size, out );
  text[size]= '\0';
  fclose( out );
  unlink( tmpout );

  MTcell result = MFstring( text );
  MFcfree( text );

  MFreturn( result );
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: tempFilename() : DOM_STRING
// 
// The function returns the name of a new temporary file.
///////////////////////////////////////////////////////////////////////////////

MFUNC( tempFilename, MCnop )
{ MFnargsCheck(0);
  char *str ; 
#if defined WIN32
  str = tempnam(NULL,"mt") ;
#else
  str = tmpnam(NULL) ;
#endif
  if ( str == NULL )
    MFerror( "Cannot create a temporary filename." );
  MFreturn(MFstring(str));
} MFEND


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: writeFile( file:DOM_STRING, value:{DOM_STRING,DOM_LIST} ):DOM_STRING
// 
// The function returns the contents of the specified 'file' as a character
// string.
///////////////////////////////////////////////////////////////////////////////

MFUNC( writeFile, MCnop )
{ MFnargsCheck(2);
  MFargCheck(1,DOM_STRING);

  MTcell value  = MFarg(2);
  bool   binary = false;

  if     ( MFisString(value) )
      binary = false;
  else if( MFisList(value) )
      binary = true;
  else
      MFerror("Invalid argument" );

  FILE  *file;
  if( (file = fopen(MFstring(MFarg(1)),"wb")) == NULL ) 
      MFerror( "Cannot open file" );

  if( binary ) { // Write Binary file as list of bytes

      int i;
      for( i=0; i<MFnops(value); i++ ) {
          if( (fputc(MFint(MFgetList(&value,i)), file)) == EOF ) {
              fclose( file );
              MFerror( "Write error" );
          }
      }

  } else {       // Write Text file as character string

    if( fwrite(MFstring(value),1,MFlenString(value),file) != (size_t) MFlenString(value) ) {
        fclose( file );
        MFerror( "Write error" );
    }

  }
  fclose( file );

  MFreturn( MFcopy(MVnull) );
} MFEND


/******************************************************************************/
/* MODULE : vcam - run mupad vcam in batch mode                               */
/* One may run mupad in batch mode from the command line in order to export   */
/* mupad graphics to other formats.                                           */
/*                                                                            */
/* See Exporting Foreign Graphics Formats for a list of possible formats and  */
/* further remarks.                                                           */
/*                                                                            */
/* Options (options have changed with V4, see mupad):                         */
/*                                                                            */
/* /t time        Timestamp between TimeBegin and TimeEnd of an animation.    */
/*                                                                            */
/* /e out-file    Output file. An extension must be given, this defines the   */
/*                format of the output file.                                  */
/* /c             Reduce to 256 colors, may be useful for some raster image   */
/*                formats in order to reduce the images size. The default is  */
/*                not to reduce colors.                                       */
/* /r resolution  Resolution of resulting raster image, given in dots per     */
/*                inch (DPI). The default value is the resolution of the      */
/*                computers display.                                          */
/* /q quality     Quality value for JPEG output, 3D EPS shading or AVI out-   */
/*                put. A percentage value. The default is 75%.                */
/* /m mode        Output mode, depends on the output format. May be used for  */
/*                JPEG, 3D EPS and AVI output.                                */
/* /f frames      Number of frames per second for AVI output. Default is 15.  */
/* in-file        Input file (*.xvz, *.xvc, *.vc or *.vca format).            */
/*                                                                            */
/* The possible mode values are:                                              */
/*                                                                            */
/* JPEG Output                                                                */
/* 0    baseline sequential (the default mode)                                */
/* 1    progressive (may not be supported by every display software)          */
/* 2    sequential optimized                                                  */
/* 3D EPS Output                                                              */
/* 0    painters algorithm (the default mode)                                 */
/* 1    BSP tree algorithm                                                    */
/* AVI Output                                                                 */
/* 0    Microsoft Video 1 codec (the default mode)                            */
/* 1    uncompressed single frame codec                                       */
/* 2    Radius Cinepak codec                                                  */
/******************************************************************************/

MMG( attribute = "secure" )
MMG( info = "Module: run MuPAD vcam in batch mode" )

// Depending on the operating system linker options must be set
MMG( linux:   loption = "-L../../../KEYGEN/CRYPTO/linux/lean_pro -lcryptopp" )

#ifdef WIN32
#include <Windows.h>
#include <direct.h>
#else
#include <time.h>
#include <dirent.h>
#endif
#include "MTBproc.h"                   // Module ToolBox for ´process´ support
#include "MTBfile.h"                   // Module ToolBox for ´file´    support

///////////////////////////////////////////////////////////////////////////////
//#define DEBUG

///////////////////////////////////////////////////////////////////////////////
#ifdef WIN32
#  define PROGNAME "mupad.exe"
#else
#  define PROGNAME "mupad"
#endif

///////////////////////////////////////////////////////////////////////////////
int runShellCmd( MTcell cmdLine );
void removeInputFile( MTcell inpFile );

/*****************************************************************************/
/* NAME : vcam::new                                                          */
/* PARAM: ["inpfile" = "outfile"], <, attr = value>                          */
/*****************************************************************************/
MFUNC( new, MCnop )
{
   bool remove  = false;
   bool verbose = false;

#ifdef  DEBUG
   verbose = true;
#endif

   MTcell      typeEqual   = MFstring("_equal");
   MTcell      vcamOptions = MFstring(" ");
   MTcell      fileName    = MCnull;
   static char buf[128];
   long        i, t;

   // VCamNG must be installed in the MuPAD bin folder
   // Under Linux systems this module works via mupad-pro-ui
   char vcambin[2048];
#ifdef WIN32
   sprintf(vcambin, "%s%s%s", MUPV_env.binPath, MCpathDelimiter, PROGNAME);
   if (!MFexist(vcambin)) {
     // neither mupad.exe found
     MFerror("'mupad.exe' must be installed in MuPAD 'win32\\bin' folder.");
   }
#else
   // use the wrapper script in share/bin/
   sprintf(vcambin, "\"%s%s%s%s%s%s%s\"", 
           MUPV_env.rootPath, MCpathDelimiter, "share", MCpathDelimiter, 
           "bin", MCpathDelimiter, PROGNAME);

#endif

   // scan arguments
   for(i=1; i <= MVnargs; i++)
   {
      // filenames: list of equations
      if (MFisList(MFarg(i)))
      {
         if (fileName == MCnull)
         {
            fileName = MFarg(i);
            continue;
         }
         else
         {
            MFfree(typeEqual);
            MFfree(vcamOptions);
            sprintf(buf, "argument #%ld: multiple list of file names", i);
            MFerror(buf);
         }
      }

      // boolean attributes
      if(MFisIdent(MFarg(i)) && strcmp(MFident(MFarg(i)),"ReduceColors") == 0)
      {
         vcamOptions = MFcall("_concat", 2, vcamOptions, MFstring("-reduce-colors "));
         continue;
      }
      if(MFisIdent(MFarg(i)) && strcmp(MFident(MFarg(i)),"Remove") == 0)
      {
         remove = true;
         continue;
      }
      if (MFisIdent(MFarg(i)) && strcmp(MFident(MFarg(i)),"Verbose") == 0)
      {
         verbose = true;
         continue;
      }

      // attributes: equation name=value
      if (!MFtesttype(MFarg(i), typeEqual) || !MFisIdent (MFop(MFarg(i),1)))
      {
         MFfree(typeEqual);
         MFfree(vcamOptions);
         sprintf(buf, "invalid argument: #%ld", i);
         MFerror(buf);
      }

      char   *name = MFident(MFop(MFarg(i),1));
      MTcell value =         MFop(MFarg(i),2) ;

      if(strcmp(name,"Frames") == 0)
      {
         if (MFisInt(value))
         {
            char *val = MFexpr2text(value);
            vcamOptions = MFcall("_concat", 4, vcamOptions,
                                 MFstring("-frames "), MFstring(val), MFstring(" "));
            //MFcfree(val); Absturz, warum? Siehe DM Seite 70
            continue;
         }
      }

      if(strcmp(name,"Mode") == 0)
      {
         if (MFisInt(value))
         {
            char *val = MFexpr2text(value);
            vcamOptions = MFcall("_concat", 4, vcamOptions,
                                 MFstring("-mode "), MFstring(val), MFstring(" "));
            //MFcfree(val); Absturz, warum? Siehe DM Seite 70
            continue;
         }
      }

      if(strcmp(name,"Quality") == 0)
      {
         if (MFisInt(value))
         {
            char *val = MFexpr2text(value);
            vcamOptions = MFcall("_concat", 4,vcamOptions,
                                 MFstring("-quality "), MFstring(val), MFstring(" "));
            //MFcfree(val); Absturz, warum? Siehe DM Seite 70
            continue;
         }
      }

      if(strcmp(name,"Resolution") == 0)
      {
         if (MFisInt(value))
         {
            char *val = MFexpr2text(value);
            vcamOptions = MFcall("_concat", 4, vcamOptions,
                                 MFstring("-resolution "), MFstring(val), MFstring(" "));
            //MFcfree(val); Absturz, warum? Siehe DM Seite 70
            continue;
         }
      }

      // invalid argument
      sprintf(buf, "invalid argument: #%ld", i);
      MFfree(typeEqual);
      MFfree(vcamOptions);
      MFerror(buf);
   }

   if (fileName == MCnull)
   {
      MFerror("list of equations \"inpfile\"=\"outfile\" expected");
   }

   // compute number of files to create
   long fileNum = 0, ctrFileNum = 0; 
   //long fileNum = 1, ctrFileNum = 1;  // attention, first entry is reserved!!!
   for(i=0; i < MFnops(fileName); i++)
   {
      MTcell eq = MFgetList(&fileName,i);
      if (MFtesttype(eq,typeEqual))
         fileNum ++;
      else if (MFisList(eq) && MFnops(eq) == 2 && MFisList(MFgetList(&eq,1)))
         fileNum += MFnops(MFgetList(&eq,1));
      else {
         MFfree(typeEqual);
         MFfree(vcamOptions);
         MFerror("list of file names: \"inpfile\"=\"outfile\" or [\"inpfile\"=\"outfile\", [timestamp,...] expected");
      }
   }
#ifdef DEBUG
   MFprintf("Number of file to create: %d\n", fileNum);
#endif
   
   // create empty list of output files
   MTcell retList = MFnewList(fileNum);
   for(i=0; i < fileNum; i++)
   {
      MFsetList(&retList,i,MMMNULL);
   }
   //MFsetList(&retList,0,MFstring("##PLOTFILELIST##");
   
   // process files...
   for(i=0; i < MFnops(fileName); i++)
   {
      MTcell eq = MFgetList(&fileName,i);
      MTcell tsl;
      bool   timestamps;

      // inpFile=outFile or [inpFile=outFile, [timestamps]]
      if (MFisList(eq) && MFnops(eq) == 2 && MFisList(MFgetList(&eq,1)))
      {
         tsl = MFcopy(MFgetList(&eq,1));
         eq  = MFgetList(&eq,0);
         timestamps = true;
      }
      else
      {
         tsl = MFnewList(1);
         MFsetList(&tsl,0,MFint(0));
         timestamps = false;
      }

      if (!MFtesttype(eq,typeEqual) || !MFisString(MFop(eq,1)) || 
          !MFisString(MFop(eq,2)))
      {
         MFfree(tsl);
         MFfree(retList);
         MFfree(typeEqual);
         MFfree(vcamOptions);
         MFerror("list of file names: \"inpfile\"=\"outfile\" or [\"inpfile\"=\"outfile\", [timestamp,...] expected");
      }
      MTcell inpFile = MFop(eq,1);

      // check read permissions
      if (!MFisSecureFileAccess(MFstring(inpFile), "r"))
      {
         MFfree(tsl);
         MFfree(retList);
         MFfree(typeEqual);
         MFfree(vcamOptions);
         MFerror("Secure kernel, read permission denied");
      }

      // check if inpFile exists
      if (access(MFstring(inpFile),0) == -1)
      {
         MFfree(tsl);
         MFfree(retList);
         MFfree(typeEqual);
         MFfree(vcamOptions);
         MFerror("cannot access input file");
      }

      // for all timestamps or for the only file to be exported, respectively
      for(t=0; t < MFnops(tsl); t++)
      {
         MTcell outFile = MFcopy(MFop(eq,2));
         MTcell ts = MFgetList(&tsl,t);

         if (!MFisNumber(ts))
         {
            MFfree(tsl);
            MFfree(retList);
            MFfree(typeEqual);
            MFfree(vcamOptions);
            MFerror("list of timestamps: number expected");
         }

         // substitute %n in outFile by current timestamp
         if (timestamps)
         {
            char buf[16];
            sprintf(buf,"\"%%n\"=\"%03ld\"", t+1);
            outFile = MFcall("stringlib::subs",2,outFile,MF(buf));
         }
         else
         {
            outFile = MFcopy(outFile);
         }

         // print user information
         if (verbose)
         {
            MFprintf("File[%d/%d]:\nin : %s\nout: %s\n",
                     i+1, MFnops(fileName),
                     MFstring(inpFile), MFstring(outFile)
            );
            if (timestamps)
            {
               MFprintf("time: %f\n", MFfloat(ts));
            }
         }

         // check write permissions
         if (!MFisSecureFileAccess(MFstring(outFile), "w"))
         {
            MFfree(tsl);
            MFfree(outFile);
            MFfree(retList);
            MFfree(typeEqual);
            MFfree(vcamOptions);
            MFerror("Secure kernel, write permission denied");
         }

         // create export command
         bool runShell = true ;
         
         MTcell shellCmd;
         if (timestamps)
         {
            shellCmd = MFcall("_concat", 10,
                MFstring(vcambin),
                MFstring(" -convert \""), MFcopy(outFile), MFstring("\" "),
                MFcopy(vcamOptions),
                MFstring(" -time "), MFstring(MFexpr2text(ts)),
                MFstring(" \""), MFcopy(inpFile), MFstring("\"")
            );
         }
         else
         {
            shellCmd = MFcall("_concat", 8,
                MFstring(vcambin),
                MFstring(" -convert \""), MFcopy(outFile), MFstring("\" "),
                MFcopy(vcamOptions),
                MFstring(" \""), MFcopy(inpFile), MFstring("\"")
            );
         }
         // create output file
         if ( runShell )
         {
            if (runShellCmd(shellCmd) == -1)
            {
               // if there is an error remove temporary files
               if (remove) {
                 removeInputFile(inpFile) ;
               }
               MFfree(shellCmd);
               MFfree(outFile);
               MFfree(tsl);
               MFfree(retList);
               MFfree(typeEqual);
               MFfree(vcamOptions);
               MFerror("cannot launch mupad process");
            }
            MFfree(shellCmd);
         }

         // check output file
         if (access(MFstring(outFile),0) == -1)
         {
            // if there is an error remove temporary files
            if (remove) {
              removeInputFile(inpFile) ;
            }
            MFfree(outFile);
            MFfree(tsl);
            MFfree(retList);
            MFfree(typeEqual);
            MFfree(vcamOptions);
            MFerror("cannot create output file");
         }
         
         // insert name of output file in return list
         if (ctrFileNum == fileNum)
         {
            // if there is an error remove temporary files
            if (remove) {
              removeInputFile(inpFile) ;
            }
            MFfree(outFile);
            MFfree(tsl);
            MFfree(retList);
            MFfree(typeEqual);
            MFfree(vcamOptions);
            MFerror("internal error: too many output files");
         }
         MFsetList(&retList,ctrFileNum,outFile);
         ctrFileNum++;
      }
      MFfree(tsl);

      // remove input file
      if (remove)
      {
         if (!MFisSecureFileAccess(MFstring(inpFile),"w"))
         {
            MFfree(retList);
            MFfree(typeEqual);
            MFfree(vcamOptions);
            MFerror("Secure kernel, remove permission denied");
         }
         if (unlink(MFstring(inpFile)) == -1)
         {
            MFfree(retList);
            MFfree(typeEqual);
            MFfree(vcamOptions);
            MFerror("cannot remove input file");
         }
      }
   }
   MFfree(typeEqual);
   MFfree(vcamOptions);

   if (ctrFileNum < fileNum)
   {
      MFfree(retList);
      MFerror("internal error: too few output files");
   }
   MFreturn( retList );
} MFEND

///////////////////////////////////////////////////////////////////////////////
#ifdef WIN32
PROCESS_INFORMATION  PROCPID;
#  ifdef DEBUG
#    define PROCMODE CREATE_NEW_CONSOLE
#  else
#    define PROCMODE DETACHED_PROCESS
#  endif
#endif

/*****************************************************************************/
/* NAME : runShellCmd                                                        */
/* PARAM: cmdLine - command line to be executed                              */
/* Executes the given command line in the background.                        */
/*****************************************************************************/
int runShellCmd( MTcell cmdLine )
{
#ifdef WIN32
#ifdef DEBUG
   MFprintf("run: '%s'\n", MFstring(cmdLine));
#endif
   STARTUPINFO start;
   ZeroMemory(&start, sizeof(STARTUPINFO));
   start.cb = sizeof(STARTUPINFO);
   ZeroMemory(&PROCPID, sizeof(PROCESS_INFORMATION));
   if (CreateProcess(NULL, MFstring(cmdLine),
                     NULL, NULL, FALSE, PROCMODE,
                     NULL, NULL, &start, &PROCPID) == 0)
   {
      return( -1 ) ;
   }

   int termstat;
   _cwait( &termstat, (int) PROCPID.hProcess, _WAIT_CHILD );

   return( 0 );
#else // Linux
#ifdef DEBUG
   cmdLine = MFcall("_concat", 2, cmdLine, MFstring(" > /dev/null 2>&1"));
   MFprintf("run: '%s'\n", MFstring(cmdLine));
#endif
   if (system(MFstring(cmdLine)) != 0)
   {
      return( -1 );
   }
   return( 0 );
#endif
}

/*****************************************************************************/
/* NAME : removeInputFile                                                    */
/* PARAM: inpFile - file to remove   e executed                              */
/* Just remove the file, used as a small utilitycur .                        */
/*****************************************************************************/
void removeInputFile( MTcell inpFile )
{
  if (!MFisSecureFileAccess(MFstring(inpFile),"w")) {
    MFprintf("Secure kernel, remove permission denied");
  } 
  else if (unlink(MFstring(inpFile)) == -1) {
    MFprintf("cannot remove input file");
  }
}

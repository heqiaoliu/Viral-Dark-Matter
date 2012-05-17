/**************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved. */
/* FILE   : MUP_env.h                                                     */
/* DESCRIP: This file declares the MuPAD Kernel Environment class.        */
/**************************************************************************/

// doxygen Kommentar
// The file section is only here, so that the file is shown in the file
// list of the created documentation
/** \file MUP_env.h
    \brief MuPAD Kernel environment

*/

#ifndef __MUP_env__
#define __MUP_env__


#include "MUP_constants.h"

#if (!defined WIN32)
class MCLT_classic_switch;
#endif

extern bool MDB_tcov();
extern bool MDB_tcov_initOK(const char *);// needed for test coverage
extern void MDB_tcov_exit();             // needed for test coverage

extern long MUT_set_alarm(long s, bool hard=false); // needed for the watchdog
extern void MUT_reset_alarm();           // needed for the watchdog
void        MUP_env_catchWatchdog();     // soft traperror watchdog handler
void        MUP_env_catchHardWatchdog(); // Global watchdog handler




/** \brief MuPAD Kernel Status

    stores the status of the evaluator
*/
class MUPT_status {
public:
   /** possible values for MuPAD Kernel Status represents the status
       of the evaluator */
  enum KernelStatus {
    Continue, Return, Quit, Next, Break
  };
  KernelStatus status_;  // continue, return, quit, next or break
  short count_;   // next or break level counter
};

class MCLT_bytestream;                          // external declaration

/** \brief MuPAD Kernel Environment

    The MuPAD kernel environment specifies and controlles the behaviour of
    the kernel.  This includes features like suppressing a banner message,
    specifying the library path, etc. The environment is first set to some
    default values.  It can be changed via command line options as well as
    by directly accessing method and variables of the MUPT_env class.
*/
class MUPT_env {

public:
  /// Constructor
  MUPT_env();

  /// Destructor
  ~MUPT_env();

  /// Sets default values for all options of the MuPAD kernel environment
  void setDefaults ( int argc, char* argv[] );

  /// Frees allocated S_Pointers
  void freeEnvironment();

  /// Parses command line options to initialise the kernel environment
  int  setCommandLineOptions ( int argc, char* argv[] );

  /// Displays information about the usage of command line options
  void printUsage ();

  /// Prints out the current values of the MuPAD kernel environment.
#if (defined MUP_ENV_DEBUG) || (defined DEBUG_ON)
  void debugDisplay ( );
#endif

  /// Sets/Gets the type of communication switch that is used
  inline void setTermSwitch()  {        terminalMode =  'T' ; }
  inline int   isTermSwitch()  { return(terminalMode == 'T'); }
  inline void setEmacsSwitch() {        terminalMode =  'E' ; }
  inline int   isEmacsSwitch() { return(terminalMode == 'E'); }
#ifdef DARWIN
  inline void setAppleEventSwitch() {        terminalMode =  'A' ; }
  inline int   isAppleEventSwitch() { return(terminalMode == 'A'); }
#endif // DARWIN
  void setUnixDomainSocketSwitch(const char* so_path);
  inline int isUnixDomainSocketSwitch() { return terminalMode == 'X'; }

#if (!defined WIN32)
  /// This variables stores the handle of the communication switch.
  /// The classic (old) communication is only used on Macintosh and
  /// UNIX systems.
  MCLT_classic_switch *theSwitch;
#endif

  // switches global test coverage on/off
  inline void setTcovOn ()    { MDB_tcov_initOK(tcovOutputFile); }
  inline void setTcovOff (){
    if (MDB_tcov())
      MDB_tcov_exit();
  }

  /// Sets/Gets the debug modes. Note that on Macintosh and Windows
  /// systems a graphical debugger front end is used by default and
  /// thus debugging takes place always in connect mode.


  /// Debug mode for the parser: insert debug nodes.
#if (defined WIN32)
  inline void setDebugOn ()            { debugMode |=  1 ;
                                         setDebugConnect(); };
#else
  inline void setDebugOn()             { debugMode |=  1 ; };
#endif
  /// Restore debug state as received from getDebugMode().
  inline void setDebugMode (short dm)   { debugMode  = dm ; };
  /// Switch off debugger during critical evaluations like error output.
  inline void setDebugOff()            { debugMode  =  0 ; };
  /// Output flag for visibility of debug nodes.
  inline void setDebugVerbose()        { debugMode |=  4 ; };
  /// We are connected to a UI.
  inline void setDebugConnect(bool on = true) { (on) ? (debugMode |=  8) :  (debugMode &=  ~8); };
  /// Debugger is active, we are in debug(...)
  inline void setDebugInteractive()    { debugMode |= 17 ; };
  inline void setDebugNotInteractive() { debugMode &= ~16; };
  /// Stop debugger at next possible moment.
  inline void setDebugQuitRequest()    {
    dbgQuitRequested_ = true;
    setUserInterrupt();
  };
  inline void resetDebugQuitRequest()    {
    dbgQuitRequested_ = false;
  };
  inline bool  getDebugQuitRequest()    { return(dbgQuitRequested_);};
  inline short getDebugMode()           { return(debugMode      ); };
  inline short isDebugOn()              { return(debugMode &   1); };
  inline short isDebugVerbose()         { return(debugMode &   4); };
  inline short isDebugConnect()         { return(debugMode &   8); };
  inline short isDebugInteractive()     { return(debugMode &  16); };

  inline bool  callStackRequested()     { return(callStackRequested_ == true); }
  inline void  requestCallStack(bool req=true) { callStackRequested_ = req; }


  /// MCA_primes/MCA_ifactor prime number limit
  long primeNumberLimit;

  /// Access functions to maxEvalSteps_ for traperror(..., MaxSteps=n)
  inline long getMaxEvalSteps() { return(maxEvalSteps_); };
  inline void setMaxEvalSteps(long i) { maxEvalSteps_ = i; };
  inline long decrementMaxEvalSteps() {
    assert(maxEvalSteps_ > 0);
    --maxEvalSteps_ ;
    return maxEvalSteps_;
  };

  /// These streams define the default output and error devices
  MCLT_bytestream *stdOutput;
  MCLT_bytestream *errOutput;

  /// These time stamps are set when the kernel is started up.
  /// Varable sessionBeginMSec is used for real time measuring.
  double sessionBegin;
  long sessionBeginMSec;    // process start real time in msec's

  /// This flag specifies if a banner is printed or not.
  bool printBanner;

  /// This flag specifies if MuPAD is used for educational units
  bool eduUnits ;
  // The user fpr the educational units
  char eduUser      [MUPC_MAX_PATH];
  // The password for user
  char eduPassword  [MUPC_MAX_PATH];

  /// Sets/Gets the watchdog times and installs a new watchdog
  void         resetWatchdog()        { MUT_reset_alarm(); };
  inline long  setWatchdog(long msec) { return(MUT_set_alarm(msec)); };
  inline long  setHardWatchdog(long msec) { return(MUT_set_alarm(msec, true)); };

  /// Controls user interrupt in critical kernel sections
  /// There are 2 possible interrupts:
  /// 1 -  CTRL-C hit by user
  /// 2 -  traperror timelimit intterrupt
  bool setUserInterrupt       ( int interrupt=1 );
  bool setBlockUserInterrupts ( bool block=true );
  bool isUserInterrupt        ( );

  /// Tests if the kernel is in a critical section of initialization
  bool isInitializing( );

  /// Variables to control critical sections of kernel initialization.
  bool inInit;
  bool inPreInit;

  /// Is set to 'true' when the memory management has been set up
  bool isMemUp;

  /// Default new Handler of the kernel
#ifdef WIN32
  new_handler origNewHandler;
#else
  std::new_handler origNewHandler;
#endif

  /// This flag specifies whether the userinit file is read or not. It
  /// is needed when the kernel is launched or reset.  The default value
  /// should be true.
  bool readUserInit;

  /// This flag specifies whether the init file of user packages are read or
  /// not. It is needed when the kernel is launched or reset.  The default
  /// value is true.
  bool readUserPack;

  /// Process-id of the MuPAD kernel
  int parentPid;

  /// Pathname of the MuPAD kernel binary file
  char *progName;

  /// Pathname of the MuPAD installation directory
  char rootPath [MUPC_MAX_PATH];

  /// Pathname of the MuPAD binary directory
  char binPath [MUPC_MAX_PATH];

  /// Pathname of the MuPAD dynamic modules directory
  char modPath [MUPC_MAX_PATH];
  char modPathAbs [MUPC_MAX_PATH];

  /// Pathname of the MuPAD library directory
  inline const char *libPath() const { return libPath_; }

  /**
    Sets the pathname of the MuPAD library directory.
    Replaces the current libPath_ string by tmp.
    The string tmp is now owned by this!
   */
  void setLibPath(char *tmp);

  /// Pathname of the MuPAD standard library directory
  inline const char *libMainPath() const { return libMainPath_; }

   /**
       sets the pathname of the MuPAD standard library directory
       using the existing lib path,. which contains the standard
       library as the last component
   */
  void setLibMainPath() ;

  /// Pathname of the MuPAD package directory
  inline const char *packPath() const { return packPath_; }

  /// Pathname of the MuPAD user init file and preferences/resources
  /// On Macintosh systems it is not used.  On Windows systems it is
  /// used only if it is defined via a command line option.
  char userPath [MUPC_MAX_PATH];

  /// Pathname of the MuPAD help pages and help index file
  char helpPath      [MUPC_MAX_PATH];
  char helpIndexPath [MUPC_MAX_PATH];

  /// Pathname which can be used to temporary files
  char tempPath      [MUPC_MAX_PATH];

  /// Pathname of UNIX domain socket used to connect to kernel
  inline const char *unixDomainServerSocket() const {
    return unixDomainServerSocket_;
  }

  /// Output file when batch mode is active. This variable either
  /// contains a file name,  the value - for the default output
  /// device or NULL  when the output file could not be opened or
  /// batch mode is inactive.
  const char *batchOutputFile;

  /// file used for test coverage outputs
  const char *tcovOutputFile;

  /// Stores a user option which may be specified via the command line
  const char *userOption;

  /// functions to get/set the current read file name
  const char* get_READ_FILENAME();
  void set_READ_FILENAME(const char *str);


  /// Methods to access Pref options stored in MUPT_env.
  inline void setSecureKernel(bool value) { SecureKernel = value;  };
  inline bool getSecureKernel() const     { return(SecureKernel);  };
  inline void setSignedLibOnly(bool value){ SignedLibOnly |= value;}; // can't be unset
  inline bool getSignedLibOnly() const    { return(SignedLibOnly); };
  inline bool getPrintEcho() const        { return(PrintEcho   );  };
  inline bool getPrintPrompt() const      { return(PrintPrompt );  };

  /// Methods to access the SecureReadPath, SecureWritePath, SecureExecPath
  inline const char *getSecureReadPath() const  { return(SecureReadPath ); };
  inline const char *getSecureWritePath() const { return(SecureWritePath); };
  inline const char *getSecureExecPath() const  { return(SecureExecPath);  };
  void  setSecureReadPath(const char *value);
  void  appendSecureReadPath(const char *value);
  void  setSecureWritePath(const char *value);
  void  appendSecureWritePath(const char *value);
  void  setSecureExecPath(const char *value);
  void  appendSecureExecPath(const char *value);

  /// Methods to access the current state or the evaluator
  inline bool getStatusContinue()
  { return(status.status_ == MUPT_status::Continue); };
  inline void setStatusContinue()
    { status.status_ = MUPT_status::Continue; };

  inline bool getStatusQuit()
    { return(status.status_ == MUPT_status::Quit); };
  inline void setStatusQuit()
    { status.status_ = MUPT_status::Quit; };

  inline bool getStatusReturn()
    { return(status.status_ == MUPT_status::Return); };
  inline void setStatusReturn()
    { status.status_ = MUPT_status::Return; };

  inline short getStatusBreak()
    { return((status.status_ == MUPT_status::Break) ? status.count_ : 0); };
  inline short decreaseStatusBreak() {
    if (status.status_ == MUPT_status::Break) {
      status.count_ -= 1;
      if (status.count_ == 0) {
        status.status_ = MUPT_status::Continue;
        return true;
      }
    }
    return false;
  };
  inline void setStatusBreak( short level ) {
    assert(level > 0);
    status.status_ = MUPT_status::Break;  status.count_ = level;
  };

  inline short getStatusNext()
    { return((status.status_ == MUPT_status::Next) ? status.count_ : 0); };
  inline short decreaseStatusNext() {
    if (status.status_ == MUPT_status::Next) {
      status.count_ -= 1;
      if (status.count_ == 0) {
        status.status_ = MUPT_status::Continue;
        return true;
      }
    }
    return false;
  };
  inline void setStatusNext( short level ) {
    assert(level > 0);
    status.status_ = MUPT_status::Next;  status.count_ = level;
  };


  // needed for saving and restoring the status
  inline MUPT_status getStatus()
    { return(status); };
  inline void setStatus( MUPT_status stat )
    { status = stat; };

  // functions for getting/setting internal representations
  // of environment variables
  inline S_Pointer getLIBPATH()   { return(LIBPATH); };
  inline void setLIBPATH(S_Pointer path) {
    if (LIBPATH != MMMNULL) MMMfree(LIBPATH);
    LIBPATH = path;
  };
  inline S_Pointer getREADPATH()   { return(READPATH); };
  inline void setREADPATH(S_Pointer path) {
    if (READPATH != MMMNULL) MMMfree(READPATH);
    READPATH = path;
  };
  inline S_Pointer getWRITEPATH()   { return(WRITEPATH); };
  inline void setWRITEPATH(S_Pointer path) {
    if (WRITEPATH != MMMNULL) MMMfree(WRITEPATH);
    WRITEPATH = path;
  };
  inline S_Pointer getPACKAGEPATH()   { return(PACKAGEPATH); };
  inline void setPACKAGEPATH(S_Pointer path) {
    if (PACKAGEPATH != MMMNULL) MMMfree(PACKAGEPATH);
    PACKAGEPATH = path;
  };

  // after the memory management is up and running,
  // register our S-Pointers as global
  void registerGlobals();

private:
  /// This flag specifies the terminal mode that is used to launch the
  /// kernel. Currently supported modes are (I)nteractive, (M)otif and
  /// (X)view.
  char terminalMode;

  /// This flag specifies the debug modes that are used by the kernel.
  /// Currently the following bits are supported: 1=active, 4=verbose,
  /// 8=connected, 16=interactive. Bit 4,8,16 requires also to set bit
  /// 1. If no bit is set, debugging in inactive.
  short debugMode;

  /// This flacg indicated that the debugger has requested a call stack.
  bool callStackRequested_;

  /// This flag controls the action of isUserInterrupt.  If true
  /// and the debugger is active then we want to quit the debugger.
  /// If the debugger is active and this flag is set to false
  /// we switch into step mode.
  bool dbgQuitRequested_;

  /// This is the counter for traperror(..., MaxSteps=n).
  long maxEvalSteps_;


  /// Stores the action mode of the watchdog timer. Supported modes
  /// are: (E)xit program and (C)atch error code.
  volatile char watchdogAction;

  /// Variables to control user interrupt in critical kernel sections.
  int  UserInt;
  bool BlockUserInt;

  /// Variables that store command line flags which influence options
  /// that can be set with the Pref command. This is needed for the
  /// MuPAD reset command.
  bool SecureKernel;
  bool PrintEcho;
  bool PrintPrompt;
  bool SignedLibOnly;

  /// Pathname list of secure read paths
  char *SecureReadPath;

  /// Pathname list of secure write paths
  char *SecureWritePath;

  /// Pathname list of secure execute paths
  char *SecureExecPath;

  ///  the status of the evaluator
  MUPT_status  status;

  /// the values of the corresponding environment variables
  S_Pointer LIBPATH;
  S_Pointer READPATH;
  S_Pointer WRITEPATH;
  S_Pointer PACKAGEPATH;

  // filename of the file currently read
  const char *READ_FILENAME;

  // package path
  char *packPath_;

  // lib path
  char *libPath_;

  // path name of UNIX domain socket for connecting the kernel
  char *unixDomainServerSocket_;

  // lib path of the standard library
  char libMainPath_[MUPC_MAX_PATH];

  /// test the length of an argument string, it must be smaller then
  /// MUPC_MAX_PATH
  bool testArgLength(const char* arg) ;
};

//@Include: MUP_env.cpp

#endif /* __MUP_env__ */

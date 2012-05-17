%MCC Invoke MATLAB to C/C++ Compiler (Version 4.11).
%   MCC [-options] fun [fun2 ...]
%   
%   Prepare fun.m for deployment outside of the MATLAB environment.  
%   Generate wrapper files in C or C++ and optionally build standalone
%   binary files. 
%   
%   Write any resulting files into the current directory, by default.
%   
%   For all targets except standalone, if more than one M-file is 
%   specified, a C or C++ interface is generated for each M-file.
%   The only exception to this rule is when the file is specified 
%   with a '-a' flag.
%   
%   If C or object files are specified, they are passed to MBUILD along
%   with any generated C files.
%   
%   If conflicting options are presented to MCC, the rightmost conflicting
%   option is used.
%   
%   OPTIONS:
%   
%   a <filename> Add <filename> to the CTF archive. If the specified file
%       is an M, mex or p file, this function will not be exported in the
%       resulting target.
%   
%   b   Generate an MS Excel compatible formula function for the
%       given list of M-files (requires MATLAB Builder EX). This option
%       will be obsoleted in a future release of MATLAB Builder for EX.
%   
%   B <filename>[:<arg>[,<arg>]] Specify bundle file. <filename> is a text  
%       file containing Compiler command line options. The Compiler behaves
%       as if the "-B <filename>" were replaced by the contents of the
%       bundle file. Newlines appearing in these files are allowed and are
%       treated as whitespace. The MathWorks provides options files for the
%       following:
%   
%           ccom        Used for building COM objects on Windows (requires
%                       MATLAB Builder NE)
%           
%           cexcel      Used for building Excel components (requires
%                       MATLAB Builder EX installed)
%           
%           cpplib      Used for building a C++ shared library.
%   
%           csharedlib  Used for building a C shared library.
%           
%           dotnet      Used for building .NET components on Windows 
%                       (requires MATLAB Builder NE installed)
%           
%   C For stand-alone applications and shared libraries, generate a separate
%       CTF archive. If this option is not specified, the CTF will be embedded
%       within the stand-alone application or library.
%   
%   c C only. Generate C wrapper code.  This is equivalent to "-T codegen" 
%       as the rightmost argument on the command line.
%   
%   d <directory> Output directory. All generated files will be put in
%       <directory>.
%   
%   e   Macro that generates a C Windows application on the Windows platform. On
%       non-Windows platforms, it is the same as the macro -m. This is 
%       equivalent to the options "-W WinMain -T link:exe", which can be found
%       in the file <MATLAB>/toolbox/compiler/bundles/macro_option_e.
%   
%   f <filename> Override the default options file with the specified
%       options file when calling MBUILD. This allows you to use different
%       ANSI compilers. This option is a direct pass-through to the MBUILD
%       script. See "External Interfaces" documentation for more
%       information.
%   
%   g   Debug. Include debugging symbol information. 
%   
%   G   Debug only. Simply turn debugging on, so debugging symbol
%       information is included.
%   
%   I <path> Include path. Add <path> to the list of paths to search for
%       M-files. The MATLAB path is automatically included when running
%       from MATLAB. When running from DOS or the UNIX shell, the
%       MATLAB Compiler includes the paths from pathdef.m in 
%       <matlabroot>/toolbox/local.
%   
%   l   Create function library. This option is equivalent to -W lib  
%       -T link:lib. It generates library wrapper functions for each M-file
%       on the command line and calls your C compiler to build a shared
%       library, which exports these functions. The library name is the
%       component name, which is either derived from the name of the first
%       M-file on the command line or specified with the -n option.
%   
%   m   Macro that generates a C stand-alone application. This is 
%       equivalent to the options "-W main -T link:exe", which can be found
%       in the file <MATLAB>/toolbox/compiler/bundles/macro_option_m. 
%   
%   M "<string>" Pass <string> to the MBUILD script to build an
%       executable. If -M is used multiple times, the rightmost occurrence
%       is used.
%   
%   N Clear path. Clear the compilation search path of all directories 
%       except the following core directories:
%           <matlabroot>/toolbox/matlab
%           <matlabroot>/toolbox/local
%           <matlabroot>/toolbox/compiler
%           <matlabroot>/toolbox/javabuilder for building Java components
%           <matlabroot>/toolbox/dotnetbuilder for building .NET components
%       It also retains all subdirectories of the above list that appear on
%       the MATLAB path at compile time.
%   
%   o <outputfilename> Output name. Set the name of the final component and
%       CTF archive to <outputfilename>. A suitable, possibly 
%       platform-dependent, extension is added to <outputfilename> (e.g., 
%       ".exe" for Windows stand-alone applications). The default output 
%       filename is the name of the first M-file (for stand-alone target)
%       or the name specified with the -W option. See option W for more 
%       information.
%   
%   p <directory>  Add <directory> to the compilation search path. This
%       option can only be used in conjunction with the -N option. This
%       option will add <directory> to the compilation search path in the
%       same order as in your MATLAB path. If directory is not an absolute
%       path, it is assumed to be under the current working directory. The
%       rules for how these directories are included are
%       * If <directory> is on the original MATLAB path, the <directory>
%         and all its subdirectories that appear on the original path are
%         added to the compilation search path in the same order as it
%         appears on MATLAB path.
%       * If <directory> is not on the original MATLAB path, it is not
%         included in the compilation. (You can use -I to add it.) 
%       If the same directory is added with both the -I and -p option (-N
%       appearing before both the options), the directory will be added as
%       per the rules of -p.
%   
%   R <option> Specify the run-time options for the MATLAB Common Runtime 
%       (MCR) usage:
%       Supported MCR options are -nojvm, -nodisplay (UNIX ony) and -logfile.
%       The -logfile option should always be followed by the name of the log 
%       file.
%       EXAMPLES:
%       mcc -e -R '-logfile,bar.txt' -v foo.m
%       mcc -m -R -nojvm -v foo.m
%       mcc -m -R -nodisplay -v foo.m 
%       mcc -m -R -nojvm -R -nodisplay -v foo.m 
%       mcc -m -R '-nojvm,-nodisplay' foo.m        
%       mcc -m -R '-logfile,bar.txt,-nojvm,-nodisplay' -v foo.m
%   
%   S Create Singleton MCR
%      Create a singleton MCR when compiling a COM object. Each
%      instance of the component uses the same MCR (requires MATLAB
%      Builder NE).
%   
%   T <option> Specify target phase and type. The following table shows  
%       valid <option> strings and their effects:
%   
%       codegen            - Generate a C/C++ wrapper file.
%                            (This is the default -T setting.)
%       compile:exe        - Same as codegen, plus compile C/C++ files to 
%                            object form suitable for linking into a
%                            stand-alone executable.
%       compile:lib        - Same as codegen, plus compile C/C++ files to 
%                            object form suitable for linking into a shared 
%                            library/DLL.
%       link:exe           - Same as compile:exe, plus link object files  
%                            into a stand-alone executable.
%       link:lib           - Same as compile:lib, plus link object files  
%                            into a shared library/DLL.
%   
%   v   Verbose. Show compilation steps.
%   
%   w list. List the warning strings that could be thrown by the MATLAB 
%       Compiler during compilation. These <msgs> can be used with another
%       form of the w option to enable or disable the warnings or to throw
%       them as error messages. 
%   
%   w <option>[:<msg>] Warnings. The possible options are "enable", 
%       "disable", and "error". If "enable:<msg>" or "disable:<msg>" is
%       specified, enable or disable the warning associated with <msg>. If
%       "error:<msg>" is specified, enable the warning associated with
%       <msg> and treat any instances of that warning as an error. If the
%       <option> but not ":<msg>" is specified, the Compiler applies the
%       action to all warning messages. For backward compatibility with
%       previous Compiler revisions, "-w" (with no option) is the same as
%       "-w enable".
%   
%   W <option> Wrapper functions. Specify which type of wrapper file
%       should be generated by the Compiler. <option> can be one of
%       "main", "WinMain", "lib:<string>", "cpplib:<string>", 
%       "com:<component-name>,<class-name>,<version>", or "none"
%       (default). For the lib wrapper, <string> contains the name of the
%       shared library to build.
%   
%   Y <license.dat file> Override the default license.dat file with the
%       specified argument.
%   
%   ?   Help. Display this help message.
%   
%   Command Line Option Available Only on Windows Platforms
%   
%   win32 Directs the execution of the 32-bit version of the MATLAB Compiler
%       The -win32 option is processed as a unit
%       and does interfere with other option settings.
%   
%   EXAMPLES:
%   
%   Note: * Before using mcc, users should run 'mbuild -setup' from MATLAB and 
%           choose a supported C/C++ compiler.
%         * The executable generated using mcc can be run from MATLAB command 
%           window using the ! operator e.g !myfun.exe
%   
%   Make a stand-alone C executable for myfun.m:
%       mcc -m myfun
%   
%   Make stand-alone C executable for myfun.m. Look for
%    myfun.m in the directory /files/source, and put the resulting C files 
%    and executable in the directory /files/target:
%       mcc -m -I /files/source -d /files/target myfun
%   
%   Make a stand-alone C executable from myfun1.m and myfun2.m
%    (using one mcc call):
%       mcc -m myfun1 myfun2
%   
%   Make a C shared/dynamically linked library called "liba" from a0.m and
%   a1.m
%       mcc -W lib:liba -T link:lib a0 a1
%   
%   Make a CPP shared/dynamically linked library called "liba" from a0.m
%   and a1.m
%       mcc -W cpplib:liba -T link:lib a0 a1
%
%
%   See also CTFROOT, DEPLOYTOOL, ISDEPLOYED, ISMCC, MBUILD.

% Copyright 1984-2007 The MathWorks, Inc.

function [varargout] = mcc(varargin)
%#mex
error('Compiler:mcc:notPresent','MEX file not present');

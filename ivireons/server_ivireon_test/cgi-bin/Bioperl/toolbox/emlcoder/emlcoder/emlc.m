function varargout = emlc(varargin)
%EMLC Generate C code from MATLAB code.
% EMLC [-options] [files] fun1 [fun2 ...]
% 
%   Translate fun1.m, fun2.m, ... to C-code.  The MATLAB functions fun1, 
%   fun2, ... must comply with Embedded MATLAB syntax and semantics, a 
%   subset of the MATLAB language.  The generated C-code can be targeted to 
%   a MEX function, an embeddable library or an embeddable executable. In
%   any case, the generated code is specialized for inputs of specific 
%   class, size and complexness, based on assertions in the source code or 
%   example inputs specified on the compiler command-line (see the -eg 
%   option below).
%     
%   By default, generate C-files and compilation reports in the emcprj 
%   directory (see the -d option below). When the target is a MEX file or
%   embeddable executable, also write the generated target file to the 
%   current directory by default (see the -o option below).
%     
%   You can specify auxiliary files to include in the build with the 
%   generated files. The following filename extensions are supported:
%
%   .c    Specifies a custom C file to be included in the build.
%   .cpp  Specifies a custom C++ file to be included in the build.
%   .h    Specifies a custom header file to be included by generated files.
%   .o    Specifies an object file to be included in the build.
%   .obj
%   .a    Specifies a library to be included in the build.
%   .so
%   .lib
%
%   For custom RTW builds, the following extension is also recognized:
%
%   .tmf  Specifies the name of a TMF file to use in a custom RTW build.
%
%   Compilation options (-options), including configuration objects, may be
%   specified to control the compilation process.
%
%   OPTIONS:
%  
%   c   Generate code only, without compiling the generated code. This is
%       applicable only for RTW builds (see the -T option, below).
%
%   d <directory> Output directory. All generated files will be placed in
%       <directory>. The default is to place all generated files in the
%       directory named ./emcprj/<target>/<function>, where <target> is
%       derived from the compilation target type (see the -T option below)
%       and <function> is the name of the primary MATLAB function specified
%       on the command-line. The following directory <target> names are 
%       used:
%       -T option    <target>
%       MEX          mexfcn
%       RTW:LIB      rtwlib
%       RTW:EXE      rtwexe
%     
%   eg <example> Example inputs for the function. Specify a cell array of 
%       example values to predefine size, class, and complexity of the 
%       function inputs. The cell array should contain one example value 
%       for each function input. In the case that there are multiple
%       MATLAB functions named on the command line, the -eg option
%       corresponding to each function should immediately succeed it.
%
%   F <fimath> Specify the default FIMATH for FI inputs. If not specified,
%       the FIMATH of FI function inputs must either be specified by using 
%       assertions in the MATLAB-function or by using the -eg option to 
%       give an example FI input.
%     
%   g   Debug. Applicable to MEX targets. Compile the generated code in
%       debug mode. By default, compile the code in release (or optimized) 
%       mode.
%     
%   global <values> Specify initial values for global data variables used
%       inside Embedded MATLAB files. 
%
%   I <path> Include path. Add <path> to the list of paths to search first 
%       for Embedded MATLAB files. This path list initially consists of 
%       the current directory and the Embedded MATLAB library directories.
%       If a MATLAB file (including a top-level MATLAB file funn.m 
%       specified on the command line) is not found on this path list, then
%       the standard MATLAB path is searched.
% 
%   launchreport Generate and automatically launch a compilation report. 
%     
%   N <numerictype> Specify the default NUMERICTYPE for FI inputs. If not
%       specified, the NUMERICTYPE of FI function inputs must either be 
%       specified by using assertions in the MATLAB-function or by using 
%       the -eg option to give an example FI input.
%     
%   o <outputfilename> Output name. Set the name of the C-MEX function, the
%       RTW library or the RTW executable, depending on the target type 
%       (see -T option below). A suitable, possibly platform-dependent, 
%       extension is added to <outputfilename> (e.g., ".mex32" for Windows 
%       C-MEX files). The default output filename is the name of fun1. 
%       This option affects only the final output file. The generated C
%       files have the same base name as the corresponding MATLAB files, 
%       with the ".m" extension replaced with ".c".
%       For C-MEX and RTW:EXE targets, the output file is written to the 
%       current directory as well as the output directory (see -d option) 
%       unless <outputfilename> includes a path specification.
%     
%   O <option> Compiler optimization option. Valid <option> strings are:
%     
%       enable:inline  - Enable function inlining (the default).
%       disable:inline - Disable function inlining.
%       enable:blas    - Use BLAS library if available (the default).
%       disable:blas   - Disable BLAS library.
%
%   report Generate a compilation report. If neither this option nor the 
%       launchreport option is specified, produce a compilation report only
%       if there are compilation messages.
%     
%   s <object> Configuration object. Valid configuration objects are:
%
%       emlcoder.HardwareImplementation
%       Specifies properties of the hardware implementation for which code 
%       is generated. If not specified, generate code compatible with the 
%       MATLAB host computer. Applies only to RTW builds.
%     
%       emlcoder.MEXConfig
%       Specifies properties for C-MEX code generation. Applies only to
%       C-MEX builds.
%     
%       emlcoder.RTWConfig
%       Specifies properties for embeddable code generation. Applies only 
%       to RTW builds.
%
%       If not specified, default configuration values are used, based on 
%       the default values of the corresponding configuration objects.
%     
%   T <type> Specify target type. Valid <type> strings are:
%
%       MEX     - Generate a C-MEX function (the default).
%       RTW     - Generate embeddable C-code, and compile it to a library.
%       RTW:LIB - Same as -T RTW.
%       RTW:EXE - Generate embeddable C-code, and compile it to an executable.
%
%   v   Verbose. Show compilation steps in the command window. Applies only 
%       to RTW targets. The default is not to show the compilation steps.
%     
%   ?   Help. Display this help message.
%
%   If emlc detects conflicting options or configuration objects, it uses
%   the rightmost one.
%
%   Examples:
%
%   To create a MEX function from a MATLAB function foo.m, which takes two 
%   inputs, the first of which is class single and the second of which is
%   class double, use:
%
%       emlc foo -eg { single(0), double(0) }
%
%   To create a MEX function xbar from a MATLAB function bar.m which takes
%   no inputs use:
%
%       emlc -o xbar bar
%
%   To generate a MEX function with two entry points, ep1.m and ep2.m, 
%   where function ep1.m takes one input, a single scalar, and ep2.m takes 
%   two inputs, a double scalar and a double vector, and name the generated 
%   MEX function sharedmex, use
%
%       emlc ep1 -eg single(0) ep2 -eg { 0, zeros(1,1024) } -o sharedmex
%
%   To generate a MEX function xfoo from a MATLAB function foo.m, which 
%   takes one variable input and one constant input, use:
%
%       emlc -o xfoo foo -eg { single(0), emlcoder.egc(42) }
%
%   Note that you should not specify constant inputs when invoking MEX
%   functions. In this example, you invoke xfoo with the variable argument 
%   only, as follows:
%
%       xfoo(u);
%
%   In contrast, you must invoke the equivalent MATLAB function with both 
%   input arguments, as follows:
%
%       foo(u,42);
%
%   To provide initial values for a global variable, you can use the -global 
%   flag as follows:
%      
%       emlc foo -global {'g1',1}
%
%   To provide initial values for variable-sized global data, use an example
%   object with the -global flag. In this example, global variable 'g1' will 
%   have initial value [1 1] and upper bound [2,2]:
%      
%       emlc foo -global {'g1',emlcoder.egs([1 1],[2 2])}
%
%   See also emlmex, emlcoder.egc, emlcoder.egs, 
%   emlcoder.HardwareImplementation, emlcoder.MEXConfig, emlcoder.RTWConfig.
     
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.10.15 $  $Date: 2009/11/13 04:17:09 $

% To handle the example inputs and coder objects, we want to evaluate them 
% in the caller's workspace.
% We can only do that from this top-level function.
argc = 1;
while argc <= nargin
    arg = varargin{argc};
    argc = argc + 1;
    if ischar(arg) && argc <= nargin
        switch strtrim(arg)
            case {'-eg', '-global'}
                eg = varargin{argc};
                if ~iscell(eg)
                    try
                        val = evalin('caller',eg);
                        if ~iscell(val)
                            val = {val}; 
                        end 
                        varargin{argc} = val;
                    catch %#ok Errors are handled later
                    end
                end
                argc = argc + 1;
            case { '-s', '-F', '-N' }
                val = varargin{argc};
                if ischar(val)
                    try
                        varargin{argc} = evalin('caller',val);
                    catch %#ok Errors are handled later
                    end
                end
                argc = argc + 1;
        end
    end
end

% Now we can start using subroutines

report = emlckernel(true,varargin{:});
if nargout > 0
    varargout{1} = report;
else
    emcError(mfilename,report);
end

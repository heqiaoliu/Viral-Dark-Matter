function varargout = emlmex(varargin)
%EMLMEX Generate a C-MEX file from MATLAB code.
% EMLMEX [-options] fun1 [fun2 ...]
% 
%   Translate fun1.m, fun2.m, ... to a MEX file. The MATLAB functions 
%   fun1, fun2, ... must comply with Embedded MATLAB syntax and semantics, 
%   a subset of the MATLAB language. The generated MEX file is specialized 
%   for inputs of specific class, size and complexity, based on assertions 
%   in the source code or example inputs specified on the EMLMEX command-
%   line (see -eg option below).
%     
%   By default, generate the MEX file into the current directory, and 
%   other resulting files such as error reports into the emcprj directory
%   (see -d option below).
%     
%   Compilation options (-options), including configuration objects, may be
%   specified to control the compilation process.
%
%   OPTIONS:
%  
%   d <directory> Output directory. Generate files other than the C-MEX 
%       file in <directory>. If not specified, generate all files other than
%       the C-MEX file in the directory named ./emcprj/mexfcn/<function>, 
%       where <function> is the name of fun1.
%     
%   eg <example> Example inputs for the function. Specify a cell array of 
%       example data values to predefine the size, class and complexity of 
%       the function inputs. The cell array should contain one example
%       value for each function input. In the case that there are multiple
%       MATLAB functions named on the command line, the -eg option
%       corresponding to each function should immediately succeed it.
%
%   F <fimath> Specify the default FIMATH for FI inputs. If not specified,
%       the FIMATH of FI function inputs must either be specified by using 
%       assertions in the M-function or by using the -eg option to give an
%       example FI input.
%     
%   g   Debug. Compile the C-MEX function in debug mode. By default, compile
%       the C-MEX function in release (or optimized) mode.
%     
%   global <values> Specify initial values for global data variables used
%       inside Embedded MATLAB files. 
%     
%   I <path> Include path. Add <path> to the list of paths to search first 
%       for Embedded MATLAB files. This path list initially consists of 
%       the current directory and the Embedded MATLAB library directories.
%       If a MATLAB file (including the top-level MATLAB file funn.m 
%       specified on the command line) is not found on this path list, then
%       the standard MATLAB path is searched.
%   
%   launchreport Generate and automatically launch a compilation report. 
%     
%   N <numerictype> Specify the default NUMERICTYPE for FI inputs. If not
%       specified, the NUMERICTYPE of FI function inputs must either be 
%       specified by using assertions in the M-function or by using the -eg
%       option to give an example FI input.
%     
%   o <outputfilename> Output name. Set the name of the C-MEX function. A
%       suitable, possibly platform-dependent, extension is automatically 
%       added to <outputfilename> (e.g., ".mex32" for Windows C-MEX files).
%       The default output filename is the name of fun. Write the output 
%       file to the current directory unless <outputfilename> includes a 
%       path specification.
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
%       emlcoder.CompilerOptions
%       Specifies properties for fine-tuning the behavior of the compiler.
%     
%   ?   Help. Display this help message.
%
%   If emlmex detects conflicting options or configuration objects, it uses
%   the rightmost one.
%
%   Examples:
%
%   To create a MEX function from a MATLAB function foo.m, specialized for
%   two inputs, the first of which is class single and the second of which 
%   is class double, use:
%
%       emlmex foo -eg { single(0), double(0) }
%
%   To create a MEX function xbar from a MATLAB function bar.m which takes
%   no inputs, use:
%
%       emlmex -o xbar bar
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
%       emlmex -o xfoo foo -eg { single(0), emlcoder.egc(42) }
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
%   See also mex, emlcoder.CompilerOptions, emlcoder.egc, emlcoder.egs.
     
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.10.15 $  $Date: 2009/11/13 04:17:10 $

% To handle the example inputs and coder objects, we want to evaluate them 
% in the caller's workspace.
% We can only do that from this top-level function.
argc = 1;
while argc <= nargin
    arg = varargin{argc};
    argc = argc + 1;
    if ischar(arg) && argc <= nargin
        switch strtrim(arg)
            case '-eg'
                eg = varargin{argc};
                if ~iscell(eg)
                    try
                        val = evalin('caller',eg);
                        if ~iscell(val)
                            val = {val}; 
                        end
                        varargin{argc} = val;
                    catch %#ok -- Errors are handled later
                    end
                end
                argc = argc + 1; 
            case { '-s', '-F', '-N' }
                val = varargin{argc};
                if ischar(val)
                    try
                        varargin{argc} = evalin('caller',val);
                    catch %#ok -- Errors are handled later
                    end
                end
                argc = argc + 1; 
        end
    end
end

% Now we can start using subroutines

report = emlckernel(false,varargin{:});
if nargout > 0
    varargout{1} = report;
else
    emcError(mfilename,report);
end

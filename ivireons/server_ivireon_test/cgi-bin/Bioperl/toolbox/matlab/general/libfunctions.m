function out=libfunctions(libname,full)
%LIBFUNCTIONS Return information on functions in a shared library.
%   M = LIBFUNCTIONS('LIBNAME') returns the names of all functions 
%   defined in the external shared library LIBNAME that has been 
%   loaded into MATLAB with the LOADLIBRARY function.  The return 
%   value, M, is a cell array of strings.
%
%   M = LIBFUNCTIONS('LIBNAME', '-full') returns a full description 
%   of the functions in the library, including function signatures.
%   This includes duplicate function names with different signatures.
%   The return value, M, is a cell array of strings.
%
%   See also LOADLIBRARY, LIBFUNCTIONSVIEW, CALLLIB, UNLOADLIBRARY.

%   Copyright 2003-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2008/06/24 17:12:12 $
error(nargchk(1,2,nargin,'struct'));

if ischar(libname)
    libname=['lib.' libname];
end

if nargout==0
    if nargin==1
        meth=evalc('methods(libname)');
    else
        meth=evalc('methods(libname,full)');
    end
    disp(strrep(meth,'Methods for class lib.','Functions in library '));
else
    if nargin==1
        out=methods(libname);
    else
        out=methods(libname,full);
    end
end

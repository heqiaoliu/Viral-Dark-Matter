function libfunctionsview(qcls)
%LIBFUNCTIONSVIEW View the functions in a shared library.
%   LIBFUNCTIONSVIEW(LIBNAME) displays the names of the functions 
%   in the external shared library, LIBNAME, that has been loaded 
%   into MATLAB with the LOADLIBRARY function.
%
%   MATLAB creates a new window in response to the LIBFUNCTIONSVIEW
%   command. This window displays all of the functions defined in 
%   the specified library. For each of these functions, the following 
%   information is supplied:
%
%     - Type returned by the function
%     - Name of the function
%     - Arguments passed to the function
%
%   See also LOADLIBRARY, LIBFUNCTIONS, CALLLIB, UNLOADLIBRARY, METHODSVIEW

%   Copyright 2003-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $  $Date: 2008/09/15 20:39:16 $

if (nargin < 1)
  error('MATLAB:LIBFUNCTIONSVIEW:NumberOfInputArguments','Not enough input arguments.');
end
notChar = ~ischar(qcls);

% Make sure input is a string or object (MATLAB or opaque).
if notChar  && ~isa(qcls,'opaque') || (size(qcls,1) > 1)
  error('MATLAB:LIBFUNCTIONSVIEW:InputType','Input must be a string or object.');
end

% If input is an object, then get the class.
if notChar
  qcls = class(qcls);
else  
  qcls = ['lib.' qcls];
end

% methodsview is now able to properly display library methods
methodsview(qcls, 'libfunctionsview');

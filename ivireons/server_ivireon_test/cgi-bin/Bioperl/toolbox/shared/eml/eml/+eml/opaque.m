function x = opaque(~, value)
%EML.OPAQUE Declare a variable in the generated C code.
% 
%  Usage:
%
%  X = EML.OPAQUE('TYPE' ,'VALUE') 
%    Declares variable X of type TYPE initialized to VALUE in the generated code. 
%    X cannot be set or accessed from your MATLAB code, but it can be 
%    passed to external C functions, which can read or write the value.
%
%    X can be a variable or a structure field.
%
%    TYPE must be a string constant that represents a C type that supports 
%    copying by assignment, such as 'FILE*'.  TYPE will appear in the generated 
%    code verbatim and must be a legal prefix in a C declaration.
% 
%    VALUE must be a constant string, such as 'NULL'. 
%
%  X = EML.OPAQUE('TYPE')
%    Declares variable X of type TYPE with no initial value in the generated 
%    C code. The variable must be initialized on all paths prior to its use,
%    using one of the following methods:
%
%    - Assigning a value from other opaque variables.
%    - Assigning a value from external C functions.
%    - Passing its address to an external function via eml.wref.
%  
%  Example 1:
%    fh = eml.opaque('FILE*', 'NULL');
%    if (condition)
%      fh = eml.ceval('fopen', ['file.txt', int8(0)], ['r', int8(0)]);
%    else
%      eml.ceval('myfun', eml.wref(fh));
%    end;
%
%  Example 2:
%    x = eml.opaque('int');
%    y = repmat(x, 3, 3); % creates a 3-by-3 array of int in the generated code
%        
%  See also eml.wref
%
%  In MATLAB, this function returns VALUE; if VALUE is not provided, 
%  the empty matrix is returned.

%   Copyright 2007-2010 The MathWorks, Inc.
if nargin == 2
  x = value;
else
  x = '';
end;

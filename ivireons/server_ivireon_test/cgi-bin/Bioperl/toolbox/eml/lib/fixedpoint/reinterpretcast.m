function y = reinterpretcast(u,T)
%REINTERPRETCAST Convert fixed-point data types without changing underlying data
%
%    Embedded MATLAB Library function.
%
%    See also embedded.fi/reinterpretcast

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2009/08/23 18:50:47 $
%#eml

% This is a helper function for Embedded MATLAB to know how to propagate
% sizes before it has resolved that the input is a fi object and should
% call fi's method in toolbox/eml/lib/fixedpoint/@embedded/@fi.
if eml_ambiguous_types
    y = eml_not_const(zeros(size(u)));
elseif isinteger(u)
    switch class(u)
      case 'int8'
        temp = fi(u,1,8,0);
      case 'int16'
        temp = fi(u,1,16,0);
      case 'int32'
        temp = fi(u,1,32,0);
      case 'int64'
        temp = fi(u,1,64,0);
      case 'uint8'
        temp = fi(u,0,8,0);
      case 'uint16'
        temp = fi(u,0,16,0);
      case 'uint32'
        temp = fi(u,0,32,0);
      case 'uint64'
        temp = fi(u,0,64,0);
      otherwise
        eml_lib_assert(0,'fi:eml:reinterpretcast:UnrecognizedInteger','Unrecognized integer type.');
    end
    y = reinterpretcast(temp, T);
else
    eml_assert(false, ['REINTERPRETCAST function not defined for inputs of type ',class(u),'.']);
end

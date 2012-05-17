function y = uint64(x)
% Embedded MATLAB Library function.

%   Copyright 2008 The MathWorks, Inc.
%#eml
%   $Revision: 1.1.6.1 $  $Date: 2008/05/19 22:52:39 $

if eml_ambiguous_types
    y = eml_not_const(zeros(size(x)));
    return;
end

eml_assert(false,'uint64 method on a fi object is not supported in Embedded MATLAB');

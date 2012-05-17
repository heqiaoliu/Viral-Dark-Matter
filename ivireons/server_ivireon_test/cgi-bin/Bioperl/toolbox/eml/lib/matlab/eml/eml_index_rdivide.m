function c = eml_index_rdivide(a,b)
%Embedded MATLAB Private Function

%   C-style integer division in eml_index_class. Rounding and overflow behavior are
%   target dependent and should not be relied upon.

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_must_inline;
c = eml_rdivide(a,b,eml_index_class,'spill','to zero');

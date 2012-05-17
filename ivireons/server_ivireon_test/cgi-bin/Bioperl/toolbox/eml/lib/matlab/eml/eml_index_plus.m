function c = eml_index_plus(a,b)
%Embedded MATLAB Private Function

%   C-style integer addition in eml_index_class.
%   Overflow behavior is target dependent.

%   Copyright 2006-2007 The MathWorks, Inc.
%#eml

eml_must_inline;
c = eml_plus(a,b,eml_index_class,'spill');

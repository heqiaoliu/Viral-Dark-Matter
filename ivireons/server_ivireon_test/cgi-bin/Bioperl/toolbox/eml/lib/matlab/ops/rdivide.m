function z = rdivide(x,y)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 1, 'Not enough input arguments.');
eml_assert(isa(x,'numeric'), ['Function ''rdivide'' is not defined for values of class ''' class(x) '''.']);
eml_assert(isa(y,'numeric'), ['Function ''rdivide'' is not defined for values of class ''' class(y) '''.']);
z = eml_div(x,y);

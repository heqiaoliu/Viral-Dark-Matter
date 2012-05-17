function y = fft(x,varargin)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
eml_assert(isa(x,'float'), ['Function ''fft'' is not defined for values of class ''' class(x) '''.']);
y = eml_fft('fft',x,varargin{:});

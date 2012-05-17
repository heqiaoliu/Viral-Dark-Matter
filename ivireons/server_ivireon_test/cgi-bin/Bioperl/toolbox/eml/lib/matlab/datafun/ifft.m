function y = ifft(x,varargin)
%Embedded MATLAB Library Function.

%   Limitations:
%     The 'symmetric' option is not supported.

%   Copyright 2002-2010 The MathWorks, Inc.
%#eml

eml_assert(nargin >= 1, 'Not enough input arguments.');
eml_assert(nargin <= 4, 'Too many input arguments.');
eml_assert(isa(x,'float'), ['Function ''ifft'' is not defined for values of class ''' class(x) '''.']);
eml_prefer_const(varargin);
nv = nargin - 1;
if nv > 0 && ischar(varargin{nv})
    eml_assert(strcmp(varargin{nv},'nonsymmetric'), ...
        'Only the ''nonsymmetric'' option is supported in Embedded MATLAB.');
    nv = nv - 1;
end
y = eml_fft('ifft',x,varargin{1:nv});

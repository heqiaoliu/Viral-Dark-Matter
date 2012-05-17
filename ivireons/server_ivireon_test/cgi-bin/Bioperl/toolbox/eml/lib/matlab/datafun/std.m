function y = std(varargin)
%Embedded MATLAB Library Function

%   Copyright 2002-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
y = sqrt(var(varargin{:}));

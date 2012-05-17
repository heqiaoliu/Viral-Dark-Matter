function [maxval,indx] = max(varargin)
%Embedded MATLAB Library Function

%   Copyright 2003-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
if nargout <= 1
    maxval = eml_min_or_max('max',varargin{:});
else
    [maxval,indx] = eml_min_or_max('max',varargin{:});
end

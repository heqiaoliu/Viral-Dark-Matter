function [minval,indx] = min(varargin)
%Embedded MATLAB Library Function

%   Copyright 2003-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin <= 3, 'Too many input arguments.');
if nargout <= 1
    minval = eml_min_or_max('min',varargin{:});
else
    [minval,indx] = eml_min_or_max('min',varargin{:});
end

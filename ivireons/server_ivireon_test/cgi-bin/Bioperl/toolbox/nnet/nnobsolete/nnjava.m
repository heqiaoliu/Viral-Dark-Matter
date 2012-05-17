function result = nnjava(varargin)
%NNJAVA
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
% Replace calls to NNJAVA with calls to NNJAVA.TOOLS.

% Copyright 2010 The MathWorks, Inc.

if nargout == 0
  nnjava.tools(varargin{:});
else
  result = nnjava.tools(varargin{:});
end

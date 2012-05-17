function varargout = nn_unflatten_time(ts,varargin)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

numData = length(varargin);
varargout = cell(1,numData);
for i=1:numData
  varargout{i} = con2seq(varargin{i},ts);
end

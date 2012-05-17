function varargout = isdfgate(varargin)
%ISDFGATE
%   This is an undocumented function and may be removed in a future release.

%ISDFGATE Gateway routine to call private functions.
%   ISDFGATE is used to access private functions. Private functions 
%   may change in any future release. 
%
%   [OUT1, OUT2,...] = ISDFGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/images/images/private with input arguments VAR1,
%   VAR2,... and returns the output, OUT1, OUT2, etc. FCN is a string.
 
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/09/18 02:16:10 $

if nargin == 0
    error('IMAGESCI:isdfgate:invalidNumberOfInputs', ...
	      'There must be a function name as the first input'); 
end

fcnHandle = str2func(varargin{1});
nout = nargout;
if nout == 0
    fcnHandle(varargin{2:end});
else
    [varargout{1:nout}] = fcnHandle(varargin{2:end});
end

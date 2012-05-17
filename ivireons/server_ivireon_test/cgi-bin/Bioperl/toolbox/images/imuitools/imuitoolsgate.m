function varargout = imuitoolsgate(varargin)
%IMUITOOLSGATE
%   This is an undocumented function and may be removed in a future release.

%IMUITOOLSGATE Gateway routine to call private functions.
%   IMUITOOLSGATE is used to access private functions. Private functions
%   may change in any future release.
%
%   [OUT1, OUT2,...] = IMUITOOLSGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/images/imuitools/private with input arguments
%   VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%
%   FUNCTION_HANDLE = IMUITOOLSGATE('FunctionHandle', FCN) returns a handle
%   FUNCTION_HANDLE to the function FCN in
%   MATLABROOT/toolbox/images/imuitools/private. FCN is a string.
 
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision $  $Date: 2006/10/14 12:23:03 $

wid = sprintf('Images:%s:undocumentedFunction',mfilename);
warning(wid,'IMUITOOLSGATE is an undocumented function and may be removed in a future release.')

if nargin == 0
    errID = sprintf('Images:%s:invalidNumberOfInputs', mfilename);
    msg = sprintf('There must be a function name as the first input'); 
    error(errID,'%s',msg);
end

match = strncmp(varargin{1}, 'FunctionHandle', length(varargin{1}));
if match
    fcnHandle = str2func(varargin{2});
    varargout{1} = fcnHandle;

else
    fcnHandle = str2func(varargin{1});

    nout = nargout;
    if nout == 0
        fcnHandle(varargin{2:end});
    else
        [varargout{1:nout}] = fcnHandle(varargin{2:end});
    end
end

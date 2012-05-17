function varargout = iptgate(varargin)
%IPTGATE
%   This is an undocumented function and may be removed in a future release.

%IPTGATE Gateway routine to call private functions.
%   IPTGATE is used to access private functions. Private functions 
%   may change in any future release. 
%
%   [OUT1, OUT2,...] = IPTGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/images/images/private with input arguments VAR1,
%   VAR2,... and returns the output, OUT1, OUT2, etc. FCN is a string.
 
%   Copyright 1993-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2006/10/14 12:22:53 $

if nargin == 0
    errID = sprintf('Images:%s:invalidNumberOfInputs', mfilename);
    msg = sprintf('There must be a function name as the first input'); 
    error(errID,'%s',msg);
end

fcnHandle = str2func(varargin{1});
nout = nargout;
if nout == 0
    fcnHandle(varargin{2:end});
else
    [varargout{1:nout}] = fcnHandle(varargin{2:end});
end

% This pragma fixes g280781, which enables deployment of IPT fcns calling
% ind2rgb8. 
%#function ind2rgb8

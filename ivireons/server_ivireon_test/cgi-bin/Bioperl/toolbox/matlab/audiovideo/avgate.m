function varargout = avgate(varargin)
%AVGATE Gateway routine to call MATLAB audio/video private functions.
%
%    [OUT1, OUT2,...] = AVGATE(FCN, VAR1, VAR2,...) calls FCN in 
%    the MATLAB audio/video private directory with input arguments
%    VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%

%    Copyright 2007 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:55:09 $

if nargin == 0
    error('MATLAB:avgate:invalidSyntax', ...
        ['AVGATE is a gateway routine to MATLAB''s audio/video private functions\n' ...
        'and should not be directly called by users']);
end

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end

function varargout = codetoolsswitchyard(action,varargin)
% CODETOOLSSWITCHYARD  This function will be removed in a future release.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2005/06/21 19:21:06 $

if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end

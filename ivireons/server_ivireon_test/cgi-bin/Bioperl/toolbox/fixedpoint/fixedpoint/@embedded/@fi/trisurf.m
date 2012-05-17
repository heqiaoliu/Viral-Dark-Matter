function varargout =trisurf(varargin)
%TRISURF Create triangular surface plot
%   Refer to the MATLAB TRISURF reference page for more information.
%
%   See also TRISURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:20:00 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

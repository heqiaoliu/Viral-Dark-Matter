function varargout =quiver(varargin)
%QUIVER Create quiver or velocity plot
%   Refer to the MATLAB QUIVER reference page for more information.
%
%   See also QUIVER

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:22 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

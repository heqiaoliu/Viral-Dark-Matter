function varargout =triplot(varargin)
%TRIPLOT Create 2-D triangular plot
%   Refer to the MATLAB TRIPLOT reference page for more information.
%
%   See also TRIPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:59 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

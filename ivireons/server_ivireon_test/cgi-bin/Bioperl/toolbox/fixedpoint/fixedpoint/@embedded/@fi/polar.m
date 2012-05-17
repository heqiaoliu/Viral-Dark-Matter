function varargout =polar(varargin)
%POLAR  Plot polar coordinates
%   Refer to the MATLAB POLAR reference page for more information.
%
%   See also POLAR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:20 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

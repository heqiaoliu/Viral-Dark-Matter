function varargout =clabel(varargin)
%CLABEL Create contour plot elevation labels
%   Refer to the MATLAB CLABEL reference page for more information.
%
%   See also CLABEL

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:14 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

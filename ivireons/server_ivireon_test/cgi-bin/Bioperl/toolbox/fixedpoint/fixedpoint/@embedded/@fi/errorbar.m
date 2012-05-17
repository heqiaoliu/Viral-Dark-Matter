function varargout =errorbar(varargin)
%ERRORBAR Plot error bars along curve
%   Refer to the MATLAB ERRORBAR reference page for more information.
%
%   See also ERRORBAR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:29 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});
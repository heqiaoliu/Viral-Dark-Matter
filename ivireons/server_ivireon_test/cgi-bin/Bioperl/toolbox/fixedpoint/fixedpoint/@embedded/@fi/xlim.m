function varargout =xlim(varargin)
%XLIM   Set or query x-axis limits
%   Refer to the MATLAB XLIM reference page for more information.
%
%   See also XLIM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:20:07 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

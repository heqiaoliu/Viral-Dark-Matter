function varargout =ylim(varargin)
%YLIM   Set or query y-axis limits
%   Refer to the MATLAB YLIM reference page for more information.
%
%   See also YLIM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:20:08 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

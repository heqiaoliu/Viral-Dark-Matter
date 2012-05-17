function varargout =pcolor(varargin)
%PCOLOR Create pseudocolor plot
%   Refer to the MATLAB PCOLOR reference page for more information.
%
%   See also PCOLOR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:14 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

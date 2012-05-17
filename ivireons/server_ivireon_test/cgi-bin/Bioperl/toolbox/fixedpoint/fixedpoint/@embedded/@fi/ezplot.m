function varargout =ezplot(varargin)
%EZPLOT Easy-to-use function plotter
%   Refer to the MATLAB EZPLOT reference page for more information.
%
%   See also EZPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:34 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

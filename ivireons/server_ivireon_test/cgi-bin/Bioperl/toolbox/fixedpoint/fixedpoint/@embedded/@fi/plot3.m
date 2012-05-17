function varargout =plot3(varargin)
%PLOT3  Create 3-D line plot
%   Refer to the MATLAB PLOT3 reference page for more information.
%
%   See also PLOT3

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:15 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

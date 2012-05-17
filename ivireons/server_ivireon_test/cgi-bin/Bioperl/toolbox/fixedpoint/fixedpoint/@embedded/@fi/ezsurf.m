function varargout =ezsurf(varargin)
%EZSURF Easy-to-use 3-D colored surface plotter
%   Refer to the MATLAB EZSURF reference page for more information.
%
%   See also EZSURF

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:37 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

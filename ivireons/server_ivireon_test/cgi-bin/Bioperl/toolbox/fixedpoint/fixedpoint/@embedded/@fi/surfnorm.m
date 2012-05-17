function varargout =surfnorm(varargin)
%SURFNORM Compute and display 3-D surface normals
%   Refer to the MATLAB SURFNORM reference page for more information.
%
%   See also SURFNORM

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:51 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

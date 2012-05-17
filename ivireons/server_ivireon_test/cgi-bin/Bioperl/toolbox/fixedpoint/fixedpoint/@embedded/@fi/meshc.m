function varargout =meshc(varargin)
%MESHC  Create mesh plot with contour plot
%   Refer to the MATLAB MESHC reference page for more information.
%
%   See also MESHC

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:04 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

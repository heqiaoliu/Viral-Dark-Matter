function varargout =contour(varargin)
%CONTOUR Create contour graph of matrix
%   Refer to the MATLAB CONTOUR reference page for more information.
%
%   See also CONTOUR

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:20 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

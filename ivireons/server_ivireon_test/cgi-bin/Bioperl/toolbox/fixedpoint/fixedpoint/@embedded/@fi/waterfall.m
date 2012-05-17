function varargout =waterfall(varargin)
%WATERFALL Create waterfall plot
%   Refer to the MATLAB WATERFALL reference page for more information.
%
%   See also WATERFALL

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:20:06 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

function varargout =rgbplot(varargin)
%RGBPLOT Plot colormap
%   Refer to the MATLAB RGBPLOT reference page for more information.
%
%   See also RGBPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:19:24 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

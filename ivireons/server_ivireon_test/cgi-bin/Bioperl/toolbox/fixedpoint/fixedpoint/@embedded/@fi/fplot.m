function varargout =fplot(varargin)
%FPLOT  Plot function between specified limits
%   Refer to the MATLAB FPLOT reference page for more information.
%
%   See also FPLOT

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:41 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

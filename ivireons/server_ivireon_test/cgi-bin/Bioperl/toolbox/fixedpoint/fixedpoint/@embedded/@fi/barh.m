function varargout =barh(varargin)
%BARH   Create horizontal bar graph
%   Refer to the MATLAB BARH reference page for more information.
%
%   See also BARH

%   Thomas A. Bryan, 2 November 2004
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/11/19 21:18:06 $

c = todoublecell(varargin{:});
[varargout{1:nargout}] = feval(mfilename,c{:});

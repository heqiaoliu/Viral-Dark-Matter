function hh = loglog(varargin)
%LOGLOG Create log-log scale plot
%   Refer to the MATLAB LOGLOG reference page for more details.
%
%   See also PLOT

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:31 $

c = todoublecell(varargin{:});
h = loglog(c{:});
if nargout>0
  hh = h;
end

function hh = plot(varargin)
%PLOT   Create linear 2-D plot
%   Refer to the MATLAB PLOT reference page for more information.
%  
%   See also PLOT 

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:42 $

c = todoublecell(varargin{:});
h = plot(c{:});
if nargout>0
  hh = h;
end

function hh = semilogx(varargin)
%SEMILOGX Create semilogarithmic plot with logarithmic x-axis 
%   Refer to the MATLAB SEMILOGX reference page for more information 
%
%   See also SEMILOGX

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:50 $

c = todoublecell(varargin{:});
h = semilogx(c{:});
if nargout>0
  hh = h;
end

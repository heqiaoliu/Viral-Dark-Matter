function hh = semilogy(varargin)
%SEMILOGY Create semilogarithmic plot with logarithmic y-axis 
%   Refer to the MATLAB SEMILOGY reference page for more information. 
%
%   See also SEMILOGY

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/20 07:12:51 $

c = todoublecell(varargin{:});
h = semilogy(c{:});
if nargout>0
  hh = h;
end

function str = getStr(this)
% return a string to print in edit box for poly1d editor

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/05/19 23:05:03 $

str = sprintf(' [ %s ]',num2str(this.Parameters.Coefficients));

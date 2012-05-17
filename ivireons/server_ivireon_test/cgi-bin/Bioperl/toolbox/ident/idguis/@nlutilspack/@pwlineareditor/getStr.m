function str = getStr(this,Type)
% return a string to print in edit boxes
% Type: 'x' or 'y'

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:33:17 $

if strcmpi(Type,'x')
    str = sprintf(' [ %s ]',num2str(this.Parameters.x));
else
    str = sprintf(' [ %s ]',num2str(this.Parameters.y));
end


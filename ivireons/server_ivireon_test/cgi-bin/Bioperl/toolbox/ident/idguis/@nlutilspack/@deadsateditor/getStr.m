function str = getStr(this,Type)
% return a string to print in edit boxes
% Type: 'low' or 'up'

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:52 $

if strcmpi(Type,'up')
    val = this.Parameters.up;
else
    val = this.Parameters.low;
end

if isnan(val), 
    val = [];
end

str = sprintf('%s',num2str(val));

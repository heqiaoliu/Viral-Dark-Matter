function disp(this)
%DISP Display extension property (Property)

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2009/10/29 16:08:10 $

% Describe value:
%  "  (Default) "propName": type, [classOfValue, sizeOfValue]: <value>"
%
%  Ex: "  (Default) "myProp": string [char 100x50] 'my string'"
%  (since declared type string may differ from type of value)
%
% Value is only displayed for strings and scalars
%
sizStr = sprintf('%dx',size(this.Value));
sizStr(end)=''; % remove trailing 'x'
theType = get(findprop(this,'Value'), 'DataType');

% If value is a scalar or a string, we display the value
if ishandle(this.Value)
    valStr = [': ' class(this.Value)];
elseif isnumeric(this.Value) || islogical(this.Value) || ischar(this.Value)
    valStr = [': ' mat2str(this.Value)];
else
    valStr = '';
end

% Display to the command window:
%    "PropName": PropValue (PropClass|PropStatus)
%
% Note: uses 4 leading spaces, so that display works
%       well with Config display method.
%
% Example:
%     (Default) "P1": bool [logical 1x1]
%
fprintf('     "%s" %s (%s|%s)\n',this.Name,valStr,theType, this.Status);

% [EOF]

function checkOnOff(h, prop, value)
%CHECKONOFF Check if value is either 'on' or 'off'
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/03/31 17:11:01 $

m = size(value, 1);
if (m~=1) || ~ischar(value) || ...
        (isempty(regexp(value, '^on$', 'once')) ...
        && isempty(regexp(value, '^off$', 'once')))
    if ischar(h)
        msg = sprintf(['The %s input argument of %s must be ''on'' ', ...
            'or ''off''.'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' must be ''on'' ', ...
            'or ''off''.'], prop, class(h));
    end
    throwAsCaller(MException('MATLAB:datatypes:InvalidOnOff', msg));
end
%---------------------------------------------------------------------------
% [EOF]
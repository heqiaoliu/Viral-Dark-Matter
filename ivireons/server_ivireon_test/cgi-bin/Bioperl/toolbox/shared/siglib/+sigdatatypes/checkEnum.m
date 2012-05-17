function varargout = checkEnum(h, prop, value, enumstr)
%CHECKENUM Check the validity of the enumerated value
%   If H is a class handle, then a message that includes property name PROP and
%   class name of H is issued.  If H is a string, then a message that assumes
%   PROP is an input argument to a function or method is issued.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/07/09 18:12:58 $

m = size(value, 1);
if ~ischar(value)
    indx = [];
else
    indx = strncmpi(value, enumstr, length(value));
end
if (m~=1) || (sum(indx)~=1)
    if ischar(h)
        msg = sprintf(['The %s input argument of %s is an enumerated value '...
            'and must be one of the following:'], prop, h);
    else
        msg = sprintf(['The ''%s'' property of ''%s'' is a scalar '...
            'enumerated value and must be one of the following:'], ...
            prop, class(h));
    end
    for p=1:length(enumstr)
        msg = sprintf('%s\n\t''%s''', msg, enumstr{p});
    end
    throwAsCaller(MException('MATLAB:datatypes:InvalidEnum', msg));
elseif nargout > 0
    
    % Return the completed string for partial string completion.
    varargout = {enumstr{indx}};
end

% [EOF]

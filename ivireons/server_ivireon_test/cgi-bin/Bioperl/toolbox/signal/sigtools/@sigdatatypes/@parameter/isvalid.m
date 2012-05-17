function b = isvalid(this, value)
%ISVALID   Returns true if the value is valid.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:21:21 $

vv = get(this, 'ValidValues');

if iscell(vv),
    b = ~isempty(strmatch(lower(value), lower(vv)));
elseif isnumeric(vv),
    b = true;
    
    % Check the limits of valid values
    if value > vv(end),
        b = false;
    elseif value < vvv(1),
        b = false;
    % If there is a 3rd element, check the spacing of value.
    elseif length(vv) == 3 & ...
            sqrt(eps) < rem(value-valid(1), valid(2))
        b = false;
    end
elseif isa(vv, 'function_handle'),
    try
        b = true;
        feval(vv, value);
    catch
        b = false;
    end
elseif ischar(vv) & strcmpi(vv, 'on/off')
    if isempty(strcmpi(value, {'on', 'of', 'off'})),
        b = false;
    else
        b = true;
    end
else
    % This should never happen.
end

% [EOF]

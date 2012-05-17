function [value, msg] = trueorfalse(value, property)
%TRUEORFALSE checks logic value while tolerating numerical values.
%
% [value, msg] = trueorfalse(value, property) checks if value is a scalar logical
% value True or False. If value contains a numerical value 1 or 0, it is
% converted to True or False. Otherwise an non empty error string is
% retured in msg using the property name.

% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2010/04/21 21:26:12 $

% Author(s): Qinghua Zhang

error(nargchk(1,2, nargin,'struct'))
msg = struct([]);

if ~isscalar(value)
    msg = struct('identifier','Ident:utility:logicalScalarPropVal',...
        'message',sprintf('The value of the "%s" property must be a logical scalar.',property));
    return
end

if islogical(value)
    return
end

if isnumeric(value)
    value = logical(value);
else
    msg = struct('identifier','Ident:utility:logicalScalarPropVal',...
        'message',sprintf('The value of the "%s" property must be a logical scalar.',property));
end

% FILE END
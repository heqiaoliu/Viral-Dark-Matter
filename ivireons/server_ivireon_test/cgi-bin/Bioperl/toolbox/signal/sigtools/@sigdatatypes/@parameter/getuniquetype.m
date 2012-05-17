function typename = getuniquetype(hPrm, check)
%GETUNIQUETYPE Get a unique type name

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.7.4.4 $  $Date: 2005/06/16 08:45:23 $

tag = get(hPrm, 'Tag');

% Assume that anything with this typename must be our type.
typename = ['signal_parameter_' tag];
type     = findtype(typename);

% Because the strings can change dynamically, we need to make sure that
% they match what is stored in the enumerated type.
i = 0;

while typedoesntmatch(type, check),
    typename = sprintf('signal_parameter_%s%d', tag,i);
    type     = findtype(typename);
    i = i+1;
end

if isempty(type),
    if iscellstr(check),
        schema.EnumType(typename, check);
    else
        schema.UserType(typename, 'MATLAB array', check);
    end
end

% ------------------------------------------------------------------------
function boolflag = typedoesntmatch(type, check)

if isempty(type),
    boolflag = false;
elseif isa(check, 'function_handle') && ~isa(type, 'schema.UserType'),
    boolflag = true;
elseif isa(type, 'schema.UserType') && ~isa(check, 'function_handle'),
    boolflag = true;
elseif isa(check, 'function_handle'),
    if isequal(type.Check, check),
        boolflag = false;
    else
        boolflag = true;
    end
elseif length(type.Strings) ~= length(check)
    boolflag = true;
elseif all(strcmpi(type.Strings, check)),
    boolflag = false;
else
    boolflag = true;
end

% [EOF]

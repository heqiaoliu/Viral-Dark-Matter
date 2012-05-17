function Value = get(reg, Property)
%GET  Access/query CUSTOMREG property values.
%
%   VALUE = GET(REG, 'PropertyName') returns the value of the
%   specified property. An equivalent syntax is
%       VALUE = REG.PropertyName
%
%   GET(REG) displays all public properties of REG and their values.
%
%   See also CUSTOMREG/SET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:52:41 $


% Check that the function is called with one argument.
ni = nargin;
error(nargchk(1, 2, ni, 'struct'));

if ~isa(reg, 'customreg')
    ctrlMsgUtils.error('Ident:idnlmodel:objectTypeMismatch')
end

% Return the specified property/properties.
if (ni == 2)
    % GET(REG, 'Property') or GET(REG, {'Prop1', 'Prop2', ..., 'PropN'});
    CharProp = ischar(Property);
    if CharProp
        Property = {Property};
    elseif ~iscellstr(Property)
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Get all PUBLIC properties.
    AllProps = pnames(reg);
    
    % Loop over each queried property.
    Nq = numel(Property);
    Value = cell(1, Nq);
    for i = 1:Nq
        % Find match for i-th property name and get corresponding value:
        % RE: a) Must include all properties to detect multiple hits;
        %     b) Limit comparison to first 18 chars.
        try
            Value{i} = reg.(pnmatchd(Property{i}, AllProps, 18));
        catch E
            throw(E)
        end
    end
    
    % Strip cell header if PROPERTY was a string.
    if CharProp
        Value = Value{1};
    end
else
    % GET(SYS).
    PropStr = pnames(reg);
    np = length(PropStr);
    ValStr = cell(1,np);
    for kp=1:np
        ValStr{kp} = reg.(PropStr{kp});
    end
    Value = cell2struct(ValStr(:),PropStr(:),1);
    if nargout==0
        disp(Value)
        clear Value
    end
end

% FILE END

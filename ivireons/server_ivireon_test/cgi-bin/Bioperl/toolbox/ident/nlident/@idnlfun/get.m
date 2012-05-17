function Value = get(nlobj, Property)
%GET  Access/query IDNLFUN property values.
%
%   VALUE = GET(NLOBJ, 'PropertyName') returns the value of the
%   specified property. An equivalent syntax is
%       VALUE = NLOBJ.PropertyName
%
%   GET(NLOBJ) displays all public properties of NLOBJ and their values.
%
%   See also IDNLFUN/SET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:53:29 $


% Check that the function is called with one argument.
ni = nargin;
error(nargchk(1, 2, ni, 'struct'));

if ~isa(nlobj, 'idnlfun')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','get','IDNLFUN');
end

% Return the specified property/properties.
if (ni == 2)
    % GET(NLOBJ, 'Property') or GET(NLOBJ, {'Prop1', 'Prop2', ..., 'PropN'});
    CharProp = ischar(Property);
    if CharProp
        Property = {Property};
    elseif ~iscellstr(Property)
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end

    % Get all PUBLIC properties.
    AllProps = pnames(nlobj);

    % Loop over each queried property.
    Nq = numel(Property);
    Value = cell(1, Nq);
    for i = 1:Nq
        % Find match for i-th property name and get corresponding value:
        % RE: a) Must include all properties to detect multiple hits;
        %     b) Limit comparison to first 18 chars.
        try
            Value{i} = nlobj.(pnmatchd(Property{i}, AllProps, 22));
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
    PropStr = pnames(nlobj);
    np = length(PropStr);
    ValStr = cell(1,np);
    for kp=1:np
        ValStr{kp} = nlobj.(PropStr{kp});
    end
    Value = cell2struct(ValStr(:),PropStr(:),1);
    if nargout==0
        disp(Value)
        clear Value
    end
end

% FILE END




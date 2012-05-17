function Value = get(nlsys, Property)
%GET  Access/query IDNLMODEL property values.
%
%   VALUE = GET(NLSYS, 'PropertyName') returns the value of the
%   specified property of the IDNLMODEL model NLSYS. An equivalent
%   syntax is
%       VALUE = NLSYS.PropertyName
%
%   GET(NLSYS) displays all public properties of SYS and their values.
%
%   See also IDNLMODEL/SET.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $ $Date: 2008/10/02 18:54:31 $

% Generic GET method for all IDNLMODEL children. Uses the object-specific
% methods PNAMES and PVALUES to get the list of all public properties and
% their values (PNAMES and PVALUES must be defined for each particular
% child object).

% Check that the function is called with one argument.
ni = nargin;
error(nargchk(1, 2, ni, 'struct'));

% Check that NLSYS is an IDNLMODEL object.
if ~isa(nlsys, 'idnlmodel')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','get','IDNLMODEL')
end

% Return the specified property/properties.
if (ni == 2)
    % GET(NLSYS, 'Property') or GET(NLSYS, {'Prop1', 'Prop2', ..., 'PropN'});
    CharProp = ischar(Property);
    if CharProp
        Property = {Property};
    elseif ~iscellstr(Property)
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Get all PUBLIC properties.
    AllProps = pnames(nlsys);
    
    % Loop over each queried property.
    Nq = numel(Property);
    Value = cell(1, Nq);
    for i = 1:Nq
        % Find match for k-th property name and get corresponding value:
        % RE: a) Must include all properties to detect multiple hits;
        %     b) Limit comparison to first 18 chars.
        try
            Value{i} = pvget(nlsys, nlpnmatchd(Property{i}, AllProps, 18));
        catch E
            throw(E)
        end
    end
    
    % Strip cell header if PROPERTY was a string.
    if CharProp
        Value = Value{1};
    end
elseif nargout
    % STRUCT = GET(NLSYS).
    Value = cell2struct(pvget(nlsys), pnames(nlsys), 1);
else
    % GET(SYS).
    PropStr = pnames(nlsys);
    [junk, ValStr] = pvget(nlsys);
    disp(idpvformat(PropStr, ValStr));
end

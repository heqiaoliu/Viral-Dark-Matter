function [varargout] = getproperty(a,name)
%GETPROPERTY Get a dataset array property.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/05/07 18:27:32 $

% We may be given a name, or a subscript expression that starts with a '.name'
% subscript.  Get the name and validate it in any case.
if isstruct(name)
    s = name;
    if s(1).type == '.'
        name = s(1).subs;
    else
        error('stats:dataset:getproperty:InvalidSubscript', ...
              'Invalid structure for subscript.');
    end
    haveSubscript = true;
else
    haveSubscript = false;
end
% Allow partial match for property names if this is via the get method;
% require exact match if it is via subsref
name = matchpropertyname(a,name,haveSubscript);

% Get the property out of the dataset.  Some properties "should be" 0x0 cell
% arrays if they're not present, but can become 1x0 or 0x1 through
% subscripting.  Make those cosmetically nice.
switch name
case 'ObsNames'
    p = a.obsnames;
    if isempty(p), p = {}; end % force 0x0
case 'VarNames'
    p = a.varnames;
    % varnames are "always there", so leave them 1x0 when empty
case 'DimNames'
    p = a.props.DimNames;
    if isempty(p), p = {}; end % force 0x0
case {'VarDescription' 'Units'}
    p = a.props.(name);
    if isempty(p), p = {}; end % force 0x0
case 'Description'
    p = a.props.Description;
case 'UserData'
    p = a.props.UserData;
end

if haveSubscript && ~isscalar(s)
    % If there's cascaded subscripting into the property, let the property's
    % subsasgn handle the reference.  This may return a comma-separated list,
    % so ask for and assign to as many outputs as we're given.  If there's no
    % LHS to the original expression (nargout==0), this only assigns one
    % output and drops everything else in the CSL.
    [varargout{1:nargout}] = subsref(p,s(2:end));
else
    % If there's no cascaded subscripting, only ever assign the property itself.
    varargout{1} = p;
end

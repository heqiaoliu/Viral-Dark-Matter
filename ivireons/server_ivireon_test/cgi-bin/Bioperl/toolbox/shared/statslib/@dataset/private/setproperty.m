function a = setproperty(a,name,p)
%SETPROPERTY Set a dataset array property.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/05/07 18:27:37 $

% We may be given a name, or a subscript expression that starts with a '.name'
% subscript.  Get the name and validate it in any case.
if isstruct(name)
    s = name;
    if s(1).type == '.'
        name = s(1).subs;
    else
        error('stats:dataset:setproperty:InvalidSubscript', ...
              'Invalid structure for subscript.');
    end
    haveSubscript = true;
else
    haveSubscript = false;
end
% Allow partial match for property names if this is via the set method;
% require exact match if it is direct assignment via subsasgn
name = matchpropertyname(a,name,haveSubscript);

if haveSubscript && ~isscalar(s)
    % If there's cascaded subscripting into the property, get the existing
    % property value and let the property's subsasgn handle the assignment.
    % This may change its shape or size or otherwise make it invalid; that
    % gets checked by the individual setproperty methods called below.  It may
    % also be an assignment to only some elements, which is not allowed when
    % the property is initially empty; that is checked in the switch below.
    oldp = getproperty(a,name);
    needPartialCheck = isempty(oldp);
    p = subsasgn(oldp,s(2:end),p);
else
    % If there's no cascaded subscripting (or if we were just given a name),
    % we don't need to worry about partial assignment into an empty property. 
    needPartialCheck = false;
end

% Assign the new property value into the dataset.
switch name
case 'ObsNames'
    if needPartialCheck, checkPartialAssign(p,s,a.nobs,'ObsNames'); end
    a = setobsnames(a,p);
case 'VarNames'
    if needPartialCheck, checkPartialAssign(p,s,a.nvars,'VarNames'); end
    % Allow modification (with warning) of names to make them valid if this
    % is via the set method; do not if it is direct assignment via subsasgn
    a = setvarnames(a,p,[],~haveSubscript);
case 'DimNames'
    if needPartialCheck, checkPartialAssign(p,s,a.ndims,'DimNames'); end
    a = setdimnames(a,p);
case 'VarDescription'
    if needPartialCheck, checkPartialAssign(p,s,a.nvars,'VarDescription'); end
    a = setvardescription(a,p);
case 'Units'
    if needPartialCheck, checkPartialAssign(p,s,a.nvars,'Units'); end
    a = setunits(a,p);
case 'Description'
    a = setdescription(a,p);
case 'UserData'
    a = setuserdata(a,p);
end

function checkPartialAssign(p,s,n,name)
% Check to make sure we had a property assignment of the form
% ds.Properties.PropertyName(:) = value.  p is the result of that assignment,
% s(2).subs is ..., and n is the property length.  The property was initially
% empty, so if p has the same number of elements as s(2) has unique
% subscripts, the assignment must have been to every element in p.  Have to
% look out for repeated indices so that numel gets the right size.
subs = cellfun(@unique,s(2).subs,'UniformOutput',false);
if ~(length(s) == 2 && isequal(s(2).type,'()') && numel(p,subs{:}) == n)
    error('stats:dataset:setproperty:InvalidPartialAssignment', ...
          'Must assign all elements of the ''%s'' property when it is empty.',name);
end

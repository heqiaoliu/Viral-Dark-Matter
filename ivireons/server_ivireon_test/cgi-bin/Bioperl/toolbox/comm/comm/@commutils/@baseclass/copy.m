function h = copy(this)
%COPY    Make a copy of THIS and return in H.
%   If a property is a handle, instead of using '=', this method uses copy.

%   @commsutils/@baseclass
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/10 21:20:12 $

% Get the class name
className = class(this);

% Create a new object
h = eval(className);

% Get the property names
[packageName className] = strread(className, '%s%s', 'delimiter', '.');
thisClass = findclass(findpackage(packageName{1}), className{1});
props = thisClass.prop;

% Get the properties of the object
for p=1:length(props)
    name = props(p).Name;
    if strcmp(props(p).AccessFlags.Copy, 'on')
        refValue = getPrivProp(this, name);
        if isa(refValue, 'handle')
            % This is a handle.  We need to assign the copy of the object 
            % pointed by the handle
            h.setPrivProp(name, copy(refValue));
        else
            % This is not a handle.  We can assign directly
            h.setPrivProp(name, refValue);
        end
    end
end

%-------------------------------------------------------------------------------
% [EOF]

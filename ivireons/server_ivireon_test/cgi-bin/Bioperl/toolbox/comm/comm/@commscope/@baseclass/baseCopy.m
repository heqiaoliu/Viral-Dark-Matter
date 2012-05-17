function h = baseCopy(this, excludedProps)
%BASECOPY    Make a copy of THIS and return in H.
%   Do not copy EXCLUDEDPROPS.

%   @commscope/@baseclass
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/11/07 18:18:02 $

% Get the class name
className = class(this);

% Create a new object
h = eval(className);

% Get the property names
className = className(regexp(className, '\.')+1:end);
thisClass = findclass(findpackage('commscope'), className);
props = thisClass.prop;

% Get the properties of the eye diagram object
for p=1:length(props)
    name = props(p).Name;
    if ( isempty(strmatch(name, excludedProps)) )
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

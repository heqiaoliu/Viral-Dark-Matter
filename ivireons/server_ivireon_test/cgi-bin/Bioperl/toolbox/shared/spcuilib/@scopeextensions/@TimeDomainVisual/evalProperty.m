function evalProperty(this, propName, objectPropName)
%EVALPROPERTY Evaluate the property into a numeric value and assign.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/16 22:34:22 $

if nargin < 3
    objectPropName = propName;
end

% Evaluate the string, converting variables into their values.
[value, errid, errmsg] = evalPropValue(this, propName);

if ~isempty(errid)
    uiscopes.errorHandler(sprintf('Error evaluating %s:\n\n\t%s\n\nUsing the old value of %g.', ...
            objectPropName, errmsg, this.(objectPropName)));
else
    
    % Assign that value back into the objects real properties.
    this.(objectPropName) = value;
end

% [EOF]

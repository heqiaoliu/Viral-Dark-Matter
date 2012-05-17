function child = set_child(this, child, field)
%SET_CHILD   PreSet function for the 'child' property.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 18:01:31 $

if all(length(child) ~= [0 1])
    error(generatemsgid('InvalidDimensions'),'Child cannot be a vector.');
end

if ~ishghandle(child)
    error(generatemsgid('InvalidParam'),'Child must be a valid handle.');
end

if ~isempty(child)
    
    % Add a listener to the 'ObjectBeingDestroyed' event so that the handle
    % is removed from the object.
    this.ChildrenListeners.(field) = uiservices.addlistener(child, ...
        'ObjectBeingDestroyed', @(h, ev) remove(this, field));
end

% [EOF]

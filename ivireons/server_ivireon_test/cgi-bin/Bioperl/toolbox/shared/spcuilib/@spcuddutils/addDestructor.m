function varargout = addDestructor(hObj, fcn)
%ADDDESTRUCTOR Add a destructor to an object.
%   spcuddutils.addDestructor(H) adds a destructor to the object specified
%   by H.  This destructor will delete all of the children of the object
%   that were attached to H using the connect method.
%
%   addDestructor(H, FCN) adds a destructor specified by the function
%   handle FCN.  This function is passed the H and the event data from the
%   'ObjectBeingDestroyed' event.  If a function is passed, children
%   connected to the object H will not be automatically deleted.
%
%   l = addDestructor(H, ...) returns the destructor listener as an output
%   instead of saving it into a dynamic private property.

%   Author(s): J. Schickler
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:58:48 $

if nargin < 2 || isempty(fcn)
    
    % If we are not passed a destructor function handle, use a default one
    % that deletes all of the children objects.
    fcn = @(hSrc, ed) iterator.visitImmediateChildrenBkwd(hSrc, @(hChild) delete(hChild));
end

% If we are passed an HG double handle, convert it to an object so that we
% can add a listener to it.
if isnumeric(hObj)
    error(generatemsgid('HGNotSupported'), 'addDestructor does not support HG handles.');
end

% Create a listener to the objects 'ObjectBeingDestroyed' event.  Pass the
% fcn directly to the listener object.  This allows us to support, function
% handles, cell arrays and strings "for free".
l = handle.listener(hObj, 'ObjectBeingDestroyed', fcn);

if nargout > 0
    
    % If an output is requested, return the listener handle.
    varargout = {l};
else
    
    % If no outputs are requested, save the listener in the passed object.
    pName = 'spcuddutils_addDestructorObjectBeingDestroyedListener';
    p = findprop(hObj, pName);
    if isempty(p)

        % Create a private dynamic property.
        p = schema.prop(hObj, pName, 'handle.listener vector');
    else
        
        % If we are adding an additional listener to an object, make the
        % dynamic property accessible then add the listener to the list.
        set(p, 'AccessFlags.PublicSet', 'On', 'AccessFlags.PublicGet', 'On');
        l = [get(hObj, pName); l];
    end
    set(hObj, pName, l);
    
    % Make the dynamic property inaccessible to avoid effects on the
    % specified object.
    set(p, 'AccessFlags.PublicSet', 'Off', 'AccessFlags.PublicGet', 'Off');
end

% [EOF]

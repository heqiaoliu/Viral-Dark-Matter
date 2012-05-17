function listener = bfitAddPropListener(obj, property, callback)
%BFITADDPROPLISTENER  Listener object for property PropertyPostSet events 
%
%   L = BFITADDPROPLISTENER(LISTENEROBJ, FINDPROPOBJ, PROPNAME, CALLBACK)
%
%   Note:
%   This function creates listeners only for property post-set events.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2009/01/29 17:16:17 $ 

% HG1/HG2 Safe way to make a property listener
if feature( 'HGUsingMATLABClasses' )
    listener = event.proplistener( obj, property, 'PostSet', callback );
else
    % Convert double to handle is allowed because this branch is under HG1
    ws = warning( 'off', 'MATLAB:handle:hg2' );
    obj = handle( obj );
    warning( ws );
    % Make listener
    listener = handle.listener( obj, property, 'PropertyPostSet', callback );
end

end

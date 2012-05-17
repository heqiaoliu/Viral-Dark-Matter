function listener = bfitAddListener(obj, eventname, callback)
%BFITADDLISTENER    Listener object
%
%   L = BFITADDLISTENER(OBJ, EVENTNAME, CALLBACK)

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2009/01/29 17:16:15 $ 

% HG1/HG2 Safe way to make a listener
if feature( 'HGUsingMATLABClasses' )
    listener = event.listener( obj, eventname, callback );
else
    listener = handle.listener( obj, eventname, callback );
end
end
function property = bfitFindProp(obj, propname)
%BFITFINDPROP  Find a property 
%
%   L = BFITFINDPROP(LISTENEROBJ, FINDPROPOBJ, PROPNAME, CALLBACK)

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $    $Date: 2009/01/29 17:16:19 $ 

% HG1/HG2 Safe way find a property
if feature( 'HGUsingMATLABClasses' )
    property = findprop(obj, propname);
else
    % Convert double to handle is allowed because this branch is under HG1
    ws = warning( 'off', 'MATLAB:handle:hg2' );
    obj = handle( obj );
    warning( ws );
    % Make listener
    property = findprop(obj, propname);
end

end

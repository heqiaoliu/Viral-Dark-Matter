function obj = loadobj(obj)
%LOADOBJ Load filter for VideoReader objects.
%
%    OBJ = LOADOBJ(OBJ) is called by LOAD when an VideoReader object is 
%    loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.
%

%    NH DT DL
%    Copyright 2010 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2010/05/10 17:23:07 $

% Object is already created, just properly initialize it.
% We do this to take advantage of all the load functionality provided
% by MATLAB (e.g. object recursion detection).
obj.init(obj.ConstructorArgs);

end


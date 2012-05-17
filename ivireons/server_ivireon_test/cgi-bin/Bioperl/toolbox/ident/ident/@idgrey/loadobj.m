function sys = loadobj(sys)
%LOADOBJ  Load filter for IDGREY objects. Covers IDPROC.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 04:55:05 $

v = getVersion(sys);
if v<4
    idupdatewarn(sys)
    
    % Update version
    % revising version is important because idmodel could have changed (if
    % original ver < 3), but it did not update the version number
    sys = setVersion(sys,idutils.ver);    
end


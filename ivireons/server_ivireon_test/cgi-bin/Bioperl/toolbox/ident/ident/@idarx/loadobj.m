function sys = loadobj(sys)
%LOADOBJ  Load filter for IDARXobjects.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 04:55:00 $

v = getVersion(sys);
if v<4
    idupdatewarn(sys)
    % Update version
    sys = setVersion(sys,idutils.ver);    
end


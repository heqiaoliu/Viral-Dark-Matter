function s = loadobj(s)
%LOADOBJ  Load filter for IDSS objects.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 04:55:57 $

v = getVersion(s);
if v<4
    idupdatewarn(s)
    % Update version
    s = setVersion(s,idutils.ver);    
end

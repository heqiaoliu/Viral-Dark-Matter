function sys = loadobj(s)
%LOADOBJ  Load filter for IDPOLY objects.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/12/05 02:03:33 $

if isa(s,'idpoly')
    sys = s;
    v = getVersion(s);
else
    sys = idpoly;
    v = getVersion(s.idmodel);    
end

if v<4
    % R2009b or older
    % new private property - BFFormat
    idupdatewarn(sys)
    
    sys = LocalUpdateV3Object(sys,s); 
    
    % No warning necessary during loading; warn only when B, F are
    % explicitly used (constructor, get)
    
    % Update version
    sys = setVersion(sys,idutils.ver);
end

%--------------------------------------------------------------------------
function sys = LocalUpdateV3Object(sys,s)

sys = pvset(sys,'na',s.na,'nb',s.nb,'nc',s.nc,'nd',s.nd,'nf',s.nf,...
    'nk',s.nk,'InitialState',s.InitialState);
sys = pvset(sys,'idmodel',s.idmodel);

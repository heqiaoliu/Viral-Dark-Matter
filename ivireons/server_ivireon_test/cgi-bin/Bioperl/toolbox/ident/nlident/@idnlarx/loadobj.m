function sys = loadobj(s)
%LOADOBJ  Load filter for IDNLARX objects.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/05/19 23:06:42 $

sys = s;
v = getVersion(s);
if v<3
    % R2008a version or older
    % Algorithm property Trace renamed to Display in R2008b
    idupdatewarn(s)
    alnew = idutils.utAlgoFieldsUpdate(s,v);
    
    % Update Algorithm struct
    sys.Algorithm = alnew;
    sys = pvset(sys,'Version',idutils.ver);
end

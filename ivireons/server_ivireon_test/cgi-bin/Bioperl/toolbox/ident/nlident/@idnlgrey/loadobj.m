function sys = loadobj(s)
%LOADOBJ  Load filter for IDNLGREY objects.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2008/05/19 23:07:24 $

sys = s;
v = getVersion(s);
if v<3
    % R2008a version or older
    % Algorithm property Trace renamed to Display in R2008b
    idupdatewarn(s)
    alnew = idutils.utAlgoFieldsUpdate(s,v);
    
    % Update Algorithm struct
    sys.Algorithm = alnew;
    
    % Add EstimationTime to EstimationInfo if it does not exist.
    if ~isfield(sys.EstimationInfo, 'EstimationTime')
        EstimationInfo = sys.EstimationInfo;
        EstimationInfo.EstimationTime = [];
        sys.EstimationInfo = EstimationInfo;
    end
    
    sys = pvset(sys,'Version',idutils.ver);
end

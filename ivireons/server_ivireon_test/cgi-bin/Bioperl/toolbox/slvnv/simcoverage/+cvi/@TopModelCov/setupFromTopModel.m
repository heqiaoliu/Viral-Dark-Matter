function setupFromTopModel(topModelH, varargin)

%   Copyright 2008 The MathWorks, Inc.

try
[coveng topModelcovId]= cvi.TopModelCov.setup(topModelH);    
if isempty(varargin)
    coveng.covModelRefData = cv.ModelRefData;
    coveng.covModelRefData.init(topModelH);
else
    coveng.covModelRefData = varargin{1};
end

topModelName = get_param(topModelH, 'Name');
for rm = coveng.covModelRefData.recordingModels(:)'
    if ~strcmp(topModelName, rm{1})
            modelH = get_param(rm{1}, 'handle');
            cvi.TopModelCov.setup(modelH , topModelcovId );
    end
end
 
catch MEx 
    rethrow(MEx);
end



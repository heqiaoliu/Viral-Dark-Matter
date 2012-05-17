function FixPtSimRanges = retrievefixptsimranges(model, resultsRun)
%RETRIEVEFIXPTSIMRANGES show min/max/overflow logs from last simulation

% Copyright 1994-2008 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  
% $Date: 2008/06/26 20:27:08 $

appData = SimulinkFixedPoint.getApplicationData(model);

if nargin == 1 
    resultsRun = appData.ResultsLocation;
end

FixPtSimRangesOut = appData.getsimrangesdata(resultsRun);

FixPtSimRanges = cell(1,numel(FixPtSimRangesOut) );

% remove fields that were not shown but used in FPT
for i = 1:numel(FixPtSimRangesOut)
    FixPtSimRanges{i} = rmfield(FixPtSimRangesOut{i}, {'PathItem','ReplaceOutDataType','ReplacementOutDTName', 'RepresentableMinProposed', 'RepresentableMaxProposed', 'isVisible'});
end
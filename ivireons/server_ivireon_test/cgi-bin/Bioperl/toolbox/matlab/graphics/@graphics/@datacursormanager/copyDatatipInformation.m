function copyDatatipInformation(hThis,hTargetVector)
% Deserialized the information located in the application data of the
% targets and creates datatips corresponding to the information found there.

%   Copyright 2008 The MathWorks, Inc.

for i=1:numel(hTargetVector)
    currTarget = hTargetVector(i);
    if isappdata(double(currTarget),'DatatipInformation')
        dataStruct = getappdata(double(currTarget),'DatatipInformation');
        rmappdata(double(currTarget),'DatatipInformation');
        for j = 1:numel(dataStruct);
            hTip = hThis.createDatatip(currTarget,dataStruct(j));
            % When a datatip is created this way on a copied axes, its
            % "HandleVisiblity" property is incorrectly set to "on".
            set(hTip,'HandleVisibility','off');
        end
    end
end
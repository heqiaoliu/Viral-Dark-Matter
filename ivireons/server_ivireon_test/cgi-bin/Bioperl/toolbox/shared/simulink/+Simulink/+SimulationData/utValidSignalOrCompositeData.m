function isValid = utValidSignalOrCompositeData(obj)
% utValidCompositeData - validate a parameter to determine if it is a valid
% structure with timeseries data for storage of bus signal data.
%
% Copyright 2009 The MathWorks, Inc.

%% Timeseries is a valid leaf structure
if isa(obj, 'timeseries')
    isValid = true;
    return;
end

%% Empty is OK
if isempty(obj)
    isValid = true;
    return;
end
    
%% Otherwise, must be a structure
if ~isstruct(obj)
    isValid = false;
    return;
end

%% Go through all struct fields
isValid = true;
fields = fieldnames(obj);
for idx = 1 : length(fields)
    f = eval(['obj.' fields{idx}]);
    if(~Simulink.SimulationData.utValidSignalOrCompositeData(f))
        isValid = false;
        return;
    end
end


end
function d = getdata(h)
%GETDATA returns contents of qrdata
%   D = GETDATA(H) returns struct array containing
%   fields and data from FixPtSimRanges

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:22:16 $

n = length(h.Qreport);
qrIdx = 1;
for i = 1:n
    thisQreport = h.Qreport{i};
    
    d(qrIdx).Path = fxptds.getpath(thisQreport.Path); %#ok
    d(qrIdx).PathItem = fxptds.getpathitem(thisQreport); %#ok
    
    %assign the fields to the output array element. we have to do this for
    %each element because the fields differ from element to element.
    qrFields = fieldnames(thisQreport);
    for fieldIdx = 1:length(qrFields)
        fld = qrFields{fieldIdx};
        if ~(strcmpi(fld, 'SignalName') || strcmpi(fld, 'Path'))
            d(qrIdx).(fld) = thisQreport.(fld); %#ok
        end
    end
    [simdt, specdt, dt_max, dt_min, blkstatus] = h.getdatatype(thisQreport);
    d(qrIdx).SimDataType = simdt; %#ok
    d(qrIdx).SpecDataType = specdt; %#ok
    d(qrIdx).RangeMin	= dt_min; %#ok
    d(qrIdx).RangeMax	= dt_max; %#ok
    d(qrIdx).BlkExecStatus = blkstatus; %#ok
    qrIdx = qrIdx + 1;
end

% [EOF]

function cellargout = pGetDisplayItems(obj, inStruct)
; %#ok Undocumented
% gets the common display for worker objects

% Copyright 2006-2008 The MathWorks, Inc.

% $Revision: 1.1.6.2 $  $Date: 2008/03/31 17:08:01 $

cellargout = cell(3, 1); % initialise number of output arguments
mainStruct = inStruct;
workerJobsStruct = inStruct;
specificStruct = inStruct;

mainStruct.Type = 'worker';
mainStruct.Header = 'Jobmanager Worker'; 
mainStruct.Names = {'Name', 'State'};
mainStruct.Values = {obj.Name, obj.State};
% only get property if it is not empty
if ~isempty(obj.CurrentJob)
    currentJobName = obj.CurrentJob.Name;
else
    currentJobName = '';
end
% only get property if it is not empty
if ~isempty(obj.PreviousJob)
    prevJobName = obj.PreviousJob.Name;
else
    prevJobName = '';
end

workerJobsStruct.Header = 'Related Jobs';
workerJobsStruct.Names = {'CurrentJob', 'PreviousJob'};
workerJobsStruct.Values = {currentJobName, prevJobName};

haList = obj.HostAddress;
% preallocate cell structure store
specificN = cell(1+numel(haList),1);  
specificV = cell(1+numel(haList),1);
% Hostname property is generated slightly differently because of the variable number
% of hosts

specificN{1} = 'Hostname';
specificV{1} = obj.Hostname;
% get all the host addresses which can be 1 or more
specificN{2} = 'HostAddress(s)'; 
for na = 1:numel(haList)
    specificV{na+1} = haList{na};
end

specificStruct.Header = 'Worker Host';
specificStruct.Names = specificN;
specificStruct.Values = specificV;

% all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{1} = mainStruct;   
cellargout{2} = workerJobsStruct;
cellargout{3} = specificStruct;

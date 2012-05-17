function cellargout = pGetDisplayItems(obj, outputItemStruct )
; %#ok Undocumented
% gets the common display structure for Jobmanger objects

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.8 $  $Date: 2010/05/10 17:03:22 $

cellargout = cell(4, 1); % initialise number of output arguments
% Define the three output items this function is going to return
mainStruct = outputItemStruct; 
jobsStruct = outputItemStruct;
specificStruct = outputItemStruct;
securityStruct = outputItemStruct;

mainStruct.Header = 'Jobmanager'; 
mainStruct.Type = 'jobmanager'; 
mainStruct.Names = {'Type', 'ClusterOsType', 'DataLocation'};
mainStruct.Values = {mainStruct.Type, obj.ClusterOsType, ['database on ' obj.Name '@' obj.Hostname ]};
% the JObamanger object has no TYPE value. When jobmanagers get a type
% property this should be changed to obj.Type

jobsStruct.Header = 'Assigned Jobs';
jobsStruct.Names = {'Number Pending ', 'Number Queued  ', 'Number Running ', 'Number Finished'};
try
    [p, q, r, f] = obj.findJob;
    jobsStruct.Values = {length(p), length(q), length(r), length(f)};
catch err %#ok<NASGU>
    % just display '[]' when the job objects are invalid
    jobsStruct.Values = { [], [], [], [] };
end

haList = obj.HostAddress;
% Let's not deal with an empty host address list - instead we will have a
% non-empty list with a empty string which is easier to deal with below
if isempty(haList) 
    haList = {''};
end

% preallocate cell array depending on number of hosts
% There are five other properties that need to be displayed (other than
% Host Addresses(s) 
specificN = cell(5+numel(haList), 1);  
specificV = cell(5+numel(haList), 1);

index = 1;
specificN{index} = 'Name';
specificV{index} = obj.Name;
index = index + 1;
specificN{index} = 'Hostname';
specificV{index} = obj.Hostname;
index = index + 1;

% The HostAddress property is generated slightly differently because of the
% variable number of hosts
% Please note: The rest of the specificN values are empty as they are
% initialised by cell
specificN{index} = 'HostAddress(s)'; 
% vector copy
specificV(index:index+numel(haList)-1) = haList;
index = index + numel(haList);

specificN{index} = 'State';
specificV{index} = obj.State;
index = index + 1;

% get the jobmanager service info directly in one call
% for NumberOfIdleWorkers and NumberOfBusyWorkers to ensure consistency
% we now do the try and catch here to imitate what happened previously
% with pGetNumberOfIdleWorkers

try
    proxyObj = obj.ProxyObject;
    sInfo = proxyObj.getServiceInfo;
    numIdle = double(sInfo.getNumIdleWorkers());
    numBusy = double(sInfo.getNumBusyWorkers());
catch err %#ok<NASGU>
    % do same as jobmanager.pGetNumberOfIdleWorkers()
    % not ClusterSize which errors error(distcomp.handleJavaException(obj));
    numIdle = 0;
    numBusy = 0;
end
% identical to pGetClusterSize
specificN{index} = 'ClusterSize';
specificV{index} = numIdle + numBusy;
index = index + 1;
specificN{index} = 'NumberOfIdleWorkers';
specificV{index} = numIdle;
index = index + 1;
specificN{index} = 'NumberOfBusyWorkers';
specificV{index} = numBusy;

specificStruct.Header = 'Jobmanager Specific Properties';
specificStruct.Names = specificN;
specificStruct.Values = specificV;


% Preallocate cell array for security related properties
securityN = cell(2, 1);  
securityV = cell(2, 1);

index = 1;
securityN{index} = 'UserName';
securityV{index} = obj.UserName;
index = index + 1;

securityLevel = obj.ProxyObject.getSecurityLevel;
switch securityLevel
    case 0
        securityStr = '0  (No security on job manager)';
    case 1
        securityStr = {'1  (Jobs are identified with submitting user;' ...
                       '    access by other users generates warning)'};
    case 2
        securityStr = '2  (Jobs are password protected on job manager)';
    case 3
        securityStr = {'3  (Jobs are password protected on job manager;' ...
                       '    passwords must match credentials on worker' ...
                       '    machines because tasks are executed as user' ...
                       '    on the worker)'};
    otherwise
        securityStr = [];
end
securityN{index} = 'SecurityLevel';
securityV{index} = securityStr;

% Security and authentication related properties
securityStruct.Header = 'Authentication and Security';
securityStruct.Names  = securityN;
securityStruct.Values = securityV;

cellargout{1} = mainStruct;   % all three categories are sent to top level pDefaultSingleObjDisplay
cellargout{2} = jobsStruct;
cellargout{3} = securityStruct;
cellargout{4} = specificStruct;

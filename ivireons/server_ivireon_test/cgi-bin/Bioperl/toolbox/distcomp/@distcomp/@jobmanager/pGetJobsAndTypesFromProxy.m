function [uuids, types] = pGetJobsAndTypesFromProxy(jm, states)
; %#ok Undocumented
%pGetJobsAndTypesFromProxy 
%
%  [UUIDS, TYPES] = pGetJobsAndTypesFromProxy(JM)

%  Copyright 2005-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.5 $    $Date: 2008/02/02 13:00:23 $ 

ALL_STATES = nargin == 1;

proxyManager = jm.ProxyObject;

if ALL_STATES
    typeAndIdArray = proxyManager.getJobs();
    [uuids, types] = iGetIdAndType(typeAndIdArray);    
else
    typeAndIdArrays = proxyManager.getJobs(states);
    uuids = cell(numel(states), 1);
    types = uuids;
    for i = 1:numel(uuids)
        [uuids{i}, types{i}] = iGetIdAndType(typeAndIdArrays(i));    
    end
end

% -------------------------------------------------------------------------
% Internal function to convert an array of id and type to 2 separate arrays
% -------------------------------------------------------------------------
function [uuids, types] = iGetIdAndType(typeAndIdArray)
numJobs = numel(typeAndIdArray);
if numJobs > 0
    % Create the UUID array to be of the correct type
    uuids = javaArray('net.jini.id.Uuid', numJobs);
else
    % Return a java null which is the empty array
    uuids = [];
end
types = zeros(size(uuids));
for i = 1:numJobs
    uuids(i) = typeAndIdArray(i).getJobID;
    types(i) = typeAndIdArray(i).getJobType;
end

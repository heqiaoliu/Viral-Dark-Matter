function fai = failedattemptinformation(taskInfo)
; %#ok Undocumented
% Constructor for failedattemptinformation

% Copyright 2008 The MathWorks, Inc.

% $Revision: 1.1.6.4 $  $Date: 2008/11/24 14:56:47 $

fai = distcomp.failedattemptinformation;

fai.StartTime = char(taskInfo.getStartTime());
fai.ErrorIdentifier = char(taskInfo.getErrorIdentifier());
fai.ErrorMessage = char(taskInfo.getErrorMessage());

% getData returns a byte[] and not a ByteBuffer as in
% @task.pGetCommandWindowOutput.
data = taskInfo.getCommandWindowOutput().getData();
if ~isempty(data)
    fai.CommandWindowOutput = distcompdeserialize(data);
else
    fai.CommandWindowOutput = '';
end

worker = taskInfo.getWorker();
if (~isempty(worker))
    fai.Worker = char(worker.getName());
else
    fai.Worker = '';
end
end

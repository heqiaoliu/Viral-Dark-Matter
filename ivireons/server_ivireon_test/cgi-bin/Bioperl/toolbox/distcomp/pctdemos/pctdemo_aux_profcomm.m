function pctdemo_aux_profcomm
%PCTDEMO_AUX_PROFCOMM Demonstrates good communication patterns.
%   This function demonstrates how multiple send and receive operations can be
%   performed simultaneously using the labSendReceive function.  You can view
%   the resulting communication pattern using the parallel profiler.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:14 $

mydata = rand(iGetComplexityByNumLabs);

otherLabData = iSendToNextReceiveLabFromPrevLab(mydata); %#ok Don't need return data.
% use the data received
% e.g. myresult = otherLabData*mydata;





%--------------------------------------------------------------------------
function recData = iSendToNextReceiveLabFromPrevLab(mydata)
nextlab = mod(labindex,  numlabs) + 1;
prevlab = mod(labindex - 2,  numlabs) + 1;
fprintf('sending to %d receiving from %d', nextlab, prevlab);
recData = labSendReceive(nextlab, prevlab, mydata);

%--------------------------------------------------------------------------
function result = iGetComplexityByNumLabs()
if numlabs < 10
    result = 2048;
elseif numlabs < 24
    result = 1536;
elseif numlabs < 32
    result = 1024;
elseif numlabs < 64
    result = 512;
else
    result = 256;
end

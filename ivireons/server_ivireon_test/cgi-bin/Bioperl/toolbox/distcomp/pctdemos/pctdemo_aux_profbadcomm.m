function pctdemo_aux_profbadcomm
%PCTDEMO_AUX_PROFBADCOMM Demonstrate poor communication patterns.
%   This is a sample parallel program where the communication pattern causes
%   the program actually runs in serial. You can see the problem using the
%   parallel profiler.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/09 20:05:13 $

N = iGetComplexityByNumLabs();
mydata = rand(N);

if labindex == 1
    iSendDataToNextLab(mydata);
end
otherLabData = iRecFromPrevLab(); %#ok Don't need return data.
% use the data received
% e.g. myresult = otherLabData*mydata;
if labindex~=1
    iSendDataToNextLab(mydata);
end



%--------------------------------------------------------------------------
function iSendDataToNextLab(mydata)
nextlab = mod(labindex,  numlabs) + 1;
fprintf('sending to %d\n', nextlab);
labSend(mydata, nextlab);

%--------------------------------------------------------------------------
function result = iRecFromPrevLab()
prevlab = mod(labindex - 2,  numlabs) + 1;
fprintf('receive from %d\n', prevlab);
result = labReceive(prevlab);

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


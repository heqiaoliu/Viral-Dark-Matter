function X = hGatherImpl(codistr, LP, destLab)
; %#ok<NOSEM> % Undocumented
% Implementation of hGatherImpl for codistributor2dbc.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:12 $

% Have one lab receive the local parts from all the other labs and combine them
% into a single array.
if destLab ~= 0
    collectLab = destLab;
else
    collectLab = 1;
end

% Note that the implementation below conserves memory, but it does so at the
% cost of using lots of sends/receives to a single lab.
mwTag = 31634;
if labindex == collectLab
    % Allocate space for the final array and put the first local part into it.
    sz = codistr.Cached.GlobalSize;
    % Let X be of the correct size and have the same attributes as the 
    % local part.
    X = distributedutil.Allocator.create(sz, LP);
    % Put our local part into X.
    rows = codistr.globalIndices(1, labindex);
    cols = codistr.globalIndices(2, labindex);
    X(rows, cols) = LP;
    % Receive the local parts from all the other labs and put them into X.
    for srcLab = [1:collectLab-1, collectLab+1:numlabs]
        LP = labReceive(srcLab, mwTag);
        rows = codistr.globalIndices(1, srcLab);
        cols = codistr.globalIndices(2, srcLab);
        X(rows, cols) = LP; 
    end
else
    % Send our local part to the collecting lab.
    X = [];
    labSend(LP, collectLab, mwTag);
end

if destLab == 0
    % All labs want the gathered matrix.
    X = labBroadcast(collectLab, X);
end


function multidataHandler(this, numComps, compIdx, adaptorFcn, rto, rtoIdx)
%MULTIDATAHANDLER multi component data handler
%   MULTIDATAHANDLER(ARGS)
%   Called numComps time for each frame
%   Once all numComps are accumulated in UserData, pass them to target
%   object

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/03/08 21:44:05 $


% Execute adaptor-specific callback with proper args:
% Only use last 3 varargin's for this
frameData = feval(adaptorFcn, rto, rtoIdx);
this.time = rto.CurrentTime;
% Accumulate data components into UserData
this.UserData = cat(3,this.UserData,frameData);

dims = size(this.UserData);

% for a multiple data of more than one frame, length(dims) should be > 2;
updateReady = (length(dims) == 3) && (dims(end) >= numComps) || numComps == 1;

if updateReady && ~isempty(this.TargetObject)
%     disp(rto.CurrentTime);    
    this.TargetObject.runtimeData(this);
    % Empty the accumulator for next frame
    this.UserData = [];    
end

% [EOF]

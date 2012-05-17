function utSyncCompList(this)
%SYNCCOMPLIST  synchronize tunable compensator/loop in the compensator
%selection panel. It listens to the 'ConfigChange' event from LoopData.

%   Author(s): R. Chen
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:24:40 $

% get original compensator list form loopdata.c
OriginalCompensators = this.LoopData.C;
% exclude pure gain blocks
bool = isGainBlock(OriginalCompensators);
% exclude blocks without feedback loop associated
Loop = cell(1,length(OriginalCompensators));
for ct=1:length(OriginalCompensators)
    Loop(ct) = {utFindTunedLoop(this,ct)};
end
% generate compensator list
IdxTuned = ~(bool|cellfun('isempty',Loop));
this.TunedCompList = this.LoopData.C(IdxTuned);
this.TunedLoopList = [Loop{IdxTuned}];
% set dirty flag
this.IsConfigChanged = true;

function Loop = utFindTunedLoop(this,idx)
% get compensator handle
C = this.LoopData.C(idx);
% get all the associated open loops
L = this.LoopData.L;
% branch on the config type
if isequal(this.LoopData.getconfig,0)
    % use name
    CompensatorName = C.Name;
    % find the open loop at the output of the compensator, otherwise return
    % empty
    Loop = [];
    for ct = 1:length(L)
        if L(ct).Feedback
            if strcmp(CompensatorName,L(ct).LoopConfig.OpenLoop.BlockName)
                Loop = L(ct);
                return
            end
        end
    end
else
    % use ID
    CompensatorID = C.Identifier;
    % find the open loop at the output of the compensator, otherwise return
    % empty
    Loop = [];
    for ct = 1:length(L)
        if L(ct).Feedback
            if strcmp(CompensatorID,L(ct).LoopConfig.OpenLoop.BlockName)
                Loop = L(ct);
                return
            end
        end
    end
end
    
    
        


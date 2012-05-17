function utRestoreTunedLoop(this,TunedLoop,LoopData);
% Restores TunedLoop from a TunedLoopSnapshot

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2008/05/19 22:43:31 $


TunedLoop.Name = this.Name;
TunedLoop.Description = this.Description;
TunedLoop.Feedback = this.FeedBack;

if this.Feedback
    TunedLoop.LoopConfig = this.LoopConfig;
    if isequal(getconfig(LoopData),0)
        C = LoopData.C;
        CompIDs = get(C,{'Identifier'});
        
        TunedFactors = handle(zeros(0,1));
        for ct = 1:length(this.TunedFactors)
            TunedFactors(ct) =  C(find(strcmp(this.TunedFactors{ct},CompIDs)));
        end
        TunedLoop.TunedFactors = TunedFactors;
        
        Blocks = handle(zeros(0,1));
        for ct = 1:length(this.TunedLFTBlocks)
            Blocks(ct) =  C(find(strcmp(this.TunedLFTBlocks{ct},CompIDs)));
        end
        TunedLoop.setTunedLFT(this.TunedLFTSSData, Blocks);
        TunedLoop.LoopConfig = this.LoopConfig;
    else
        TunedLoop.computeTunedLoop(LoopData)       
    end
else
    C = LoopData.C;
    CompIDs = get(C,{'Identifier'});

    for ct = 1:length(this.TunedFactors)
        TunedFactors(ct) =  C(find(strcmp(this.TunedFactors{ct},CompIDs)));
    end
    TunedLoop.TunedFactors = TunedFactors;
    % Revisit
    TunedLoop.setTunedLFT(ltipack.ssdata([],zeros(0,1),zeros(1,0),1,[],LoopData.Ts),[]);
    TunedLoop.LoopConfig = this.LoopConfig;

    TunedLoop.ClosedLoopIO = this.ClosedLoopIO;
end


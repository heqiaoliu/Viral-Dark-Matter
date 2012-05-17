function this = utStoreTunedLoop(this,TunedLoop);
% stores TunedLoop into a TunedLoopSnapshot

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2005/12/22 17:39:37 $

this.Name = TunedLoop.Name;
this.FeedBack = TunedLoop.Feedback;
this.Description = TunedLoop.Description;

this.TunedFactors = get(TunedLoop.TunedFactors,{'Identifier'});
this.TunedLFTBlocks = get(TunedLoop.TunedLFT.Blocks,{'Identifier'});
this.TunedLFTSSData = TunedLoop.TunedLFT.IC;
this.LoopConfig = TunedLoop.LoopConfig;

this.ClosedLoopIO = TunedLoop.ClosedLoopIO;





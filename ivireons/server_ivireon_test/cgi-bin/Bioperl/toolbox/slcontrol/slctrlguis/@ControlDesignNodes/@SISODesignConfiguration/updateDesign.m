function updateDesign(this,opnew)
% UPDATEDESIGN  Update the design given a change in the operating point
%
 
% Author(s): John W. Glass 26-Oct-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/11/09 16:35:46 $

%% Get the options for this case
opt = linoptions;
SCDTaskOptions = getSCDTaskOptions(this);
opt.SampleTime = this.sisodb.LoopData.Ts;
opt.RateConversionMethod = SCDTaskOptions.RateConversionMethod;
opt.PreWarpFreq = SCDTaskOptions.PreWarpFreq;

%% Get the model
mdl = getModel(this);

%% Get the closed loop ios
ClosedLoopIO = this.ClosedLoopIO;

%% Get the TunedBlocks
TunedBlocks = this.sisodb.LoopData.C;

%% Loop over the loops to create the io needed for linearization
loopios = struct('FeedbackLoop',{},'LoopOpenings',{},'Name',{},'Description',{});
Loops = this.sisodb.LoopData.L;
for ct = 1:numel(Loops);
    Loop = Loops(ct);
    if Loop.Feedback
        LoopConfig = Loop.LoopConfig;
%         LoopOpenings = handle(NaN(0,1));
        for ct2 = numel(LoopConfig.LoopOpenings):-1:1
            LoopOpenings(ct2) = linio(LoopConfig.LoopOpenings(ct2).BlockName,...
                LoopConfig.LoopOpenings(ct2).PortNumber,...
                'outin');
            if LoopConfig.LoopOpenings(ct2).Status
                LoopOpenings(ct2).Active = 'on';
            else
                LoopOpenings(ct2).Active = 'off';
            end
        end
        loopios(end+1,1) = struct('FeedbackLoop',linio(LoopConfig.OpenLoop.BlockName,...
                            LoopConfig.OpenLoop.PortNumber,'outin','on'),...
            'LoopOpenings',LoopOpenings,...
            'Name',Loop.Name,...
            'Description',Loop.Description);
    end
end

loopdata = computeloopdata(linutil,mdl,ClosedLoopIO,TunedBlocks,opnew,opt,loopios);
newdesign = loopdata.exportdesign;

%% Get a design snapshot
olddesign = this.sisodb.LoopData.exportdesign;

%% Copy the current compensator data to the design.  Skip over closed loops
for ct = 1:numel(olddesign.Loops)
    if olddesign.(olddesign.Loops{ct}).getProperty('Feedback')
        olddesign.(olddesign.Loops{ct}) = newdesign.(olddesign.Loops{ct});
    end
end

%% Copy the plant data
olddesign.P = newdesign.P;

%% Import the data
this.sisodb.LoopData.importdesign(olddesign)
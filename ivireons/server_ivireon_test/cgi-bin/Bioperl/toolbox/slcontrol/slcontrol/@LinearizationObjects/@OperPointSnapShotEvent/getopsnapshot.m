function Data = getopsnapshot(this,t)
% GETOPSNAPSHOT  Method to gather snapshots

% Author(s): John Glass
% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/04/30 00:43:45 $

model = this.ModelParameterMgr.Model;
if strcmp(get_param(model,'SimulationStatus'),'stopped')
   Data = opcond.OperatingPoint(model);
   Data.update;
else
    if isempty(this.EmptyOpCond)
        this.EmptyOpCond = opcond.OperatingPoint(model);
        sync(this.EmptyOpCond,false);
    end
    % Get the operating conditions information
    op = this.EmptyOpCond;
    X = getStateStruct(slcontrol.Utilities,model);
    % Find the inports to the sys
    Inports = find_system(model,'SearchDepth',1,'BlockType','Inport');
    % Get the input levels
    U = [];
    for ct = 1:length(Inports)
        bh = get_param(Inports{ct},'Object');
        InputLevel = bh.getOutput;
        U = [U;InputLevel.Values];
    end

    % Create the new lightwieght operating condition object
    Data = copy(op);
    Data = Data.setxu(X,U);
    Data.Time = t;
end

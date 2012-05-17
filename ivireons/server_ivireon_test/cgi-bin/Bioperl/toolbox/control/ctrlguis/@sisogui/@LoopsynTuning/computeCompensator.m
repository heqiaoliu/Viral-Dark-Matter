function C = computeCompensator(this)
% computeCompensator Compute the compensator using loopysyn

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.8 $  $Date: 2009/11/09 16:22:26 $

% Disable all warnings
sw = warning('off'); [lw,lwid] = lastwarn; lastwarn(''); %#ok<*WNOFF>
idxC = this.idxC;
try
    % check if plant exists
    if isempty(this.OpenLoopPlant)
        ctrlMsgUtils.error('Control:compDesignTask:AutomatedTuningUndefinedPlant')
    else
        G = this.utApproxDelay(-this.OpenLoopPlant);
        GTs = G.Ts;
        if strcmp(this.TuningPreference{idxC},'TargetLoopShape')
            % Target Loop Shape
            Gd = this.getGd;
            FreqRange=evalin('base',this.TargetLoopShapeData(idxC).SpecifiedFreqRange);
            if isequal(FreqRange, [0,inf])     
                C = loopsyn(G,Gd);
            else
                C = loopsyn(G,Gd,FreqRange);
            end
            DesiredOrder = this.TargetLoopShapeData(idxC).TargetOrder;
        else
            % Target bandwidth
            Gd = this.getGd;
            if isdt(G)
                Gmod = d2c(G,'Tustin');
                C = loopsyn(Gmod,Gd);
                C = c2d(C,GTs,'Tustin');
            else
                C = loopsyn(G,Gd);
            end
            DesiredOrder = this.TargetBandwidthData(idxC).TargetOrder;
        end
    end
    % carry out order reduction for C when applicable
    % when desired order is lower than full order, reduce the order
    FullOrder = order(C);
    % when desired order is lower than full order, reduce the order
    if DesiredOrder<FullOrder
        % reduce controller order
        [C, ReducedMSG] = this.utModelOrderReduction(G,C,DesiredOrder);
        % obtain warning message from reduction
        if ~isempty(ReducedMSG)
            this.utDisplayMessage('warning',ReducedMSG);
        end
    end
catch ME
    this.utDisplayMessage('error',ltipack.utStripErrorHeader(ME.message));
    C = [];
end
% Reset warnings
warning(sw); lastwarn(lw,lwid);


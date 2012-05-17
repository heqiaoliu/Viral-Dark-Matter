function C = computeCompensator(this)

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2009/05/23 07:53:02 $

% Disable all warnings
sw = warning('off'); [lw,lwid] = lastwarn; lastwarn(''); %#ok<*WNOFF>
% check if plant exists
if isempty(this.OpenLoopPlant)
    C = [];
else
    % get plant model (always assuming negative feedback) and approximate
    % time delays
    Model = this.utApproxDelay(-this.OpenLoopPlant);
    % calculate C
    try
        % obtain tau from gui
        tau = awtinvoke(this.SpecPanelHandles.Edit_DominantTimeConstant,'getText()');
        if isempty(tau)
            tau = [];
        else
            errorTauMsg = 'Dominant closed-loop time constant has to be a positive real number.';
            try 
                tau = eval(tau);
                if ~isreal(tau) || ~isfinite(tau) || tau<=0
                    this.utDisplayMessage('error',xlate(errorTauMsg));
                    C = [];
                    return
                end
            catch ME %#ok<NASGU>
                this.utDisplayMessage('error',xlate(errorTauMsg));
                C = [];
                return
            end
        end
        % compute full order feedback controller and IMC controller 
        [C, q] = utTuningIMC(Model,tau);
        % obtain selected last warning message
        WarningList = {'control:autotuning:unstablec','control:autotuning:pzcancel'};
        [warnmsg,warnid] = lastwarn;
        if ~isscalar(strmatch(warnid,WarningList,'exact'))
            warnmsg = '';
        end
        % deal with configuration 5: IMC structure
        if this.LoopData.getconfig == 5
            C = q;
        else
            % carry out order reduction for C when applicable
            DesiredOrder = awtinvoke(this.SpecPanelHandles.Edit_CompensatorOrder,'getValue()');
            FullOrder = order(C);
            % when desired order is lower than full order, reduce the order
            if DesiredOrder<FullOrder
                % reduce controller order
                [C, ReducedMSG] = this.utModelOrderReduction(Model,C,DesiredOrder);
                % obtain warning message from reduction
                if ~isempty(ReducedMSG)
                    if isempty(warnmsg)
                        warnmsg = sprintf('%s',ReducedMSG);                        
                    else
                        warnmsg = sprintf('%s\n\n%s',warnmsg,ReducedMSG);
                    end
                end
            end
        end
        % obtain last warning message
        this.utDisplayMessage('warning',warnmsg);                                    
    catch ME
        this.utDisplayMessage('error',ltipack.utStripErrorHeader(ME.message));
        C = [];
    end
end
% Reset warnings
warning(sw); lastwarn(lw,lwid);


        
        
        
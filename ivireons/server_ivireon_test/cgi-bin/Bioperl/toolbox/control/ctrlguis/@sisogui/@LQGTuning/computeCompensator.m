function C = computeCompensator(this)
%COMPUTECOMPENSATOR for LQG automated tuning

%   Author(s): R. Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2009/05/23 07:53:04 $

% Disable all warnings
sw = warning('off'); [lw,lwid] = lastwarn; lastwarn(''); %#ok<*WNOFF>
% check if plant exists
if isempty(this.OpenLoopPlant)
    C = [];
else
    % get plant model (always assuming negative feedback)
    % and convert model into SS format for LQG design
    % model has to be (bi)proper
    Model = this.utApproxDelay(-this.OpenLoopPlant);
    [AA,BB,CC,DD] = ssdata(Model);
    % nu ny represents the order of the plant model, number of u and y
    [ny,nu] = size(DD);
    % prepare model with input disturbance for Kalman estimator: assume d = u
    KalmanModel = subsref(Model,struct('type','()','subs',{{':'  [1:nu 1:nu]}}));
    % calculate all the weights based on two sliders
    WQXU = awtinvoke(this.SpecPanelHandles.Slider_ControllerResponse,'getValue()')/100; % from 0 to 1
    WQWV = awtinvoke(this.SpecPanelHandles.Slider_MeasurementNoiseLevel,'getValue()')/100; % from 0 to 1
    wy = 10^(-12*WQXU+6);
    WeightY = wy*eye(ny);
    WeightU = 10^(12*WQXU-6)*eye(nu);
    WeightYN = 10^(8*WQWV-6)*eye(ny);
    WeightUN = 10^(-8*WQWV+4)*eye(nu);
    % calculate C
    try
        % compute full order feedback controller 
        K = lqi(Model,blkdiag(CC'*WeightY*CC,wy),WeightU);
        Kest = kalman(KalmanModel,WeightUN,WeightYN);        
        C = lqgtrack(Kest,K,'1dof');
        % obtain selected last warning message            
        WarningList = {'control:autotuning:lackofmv'};
        [warnmsg,warnid] = lastwarn;
        if ~isscalar(strmatch(warnid,WarningList,'exact'))
            warnmsg = '';
        end
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
        % obtain last warning message
        this.utDisplayMessage('warning',warnmsg);                                    
    catch ME
        this.utDisplayMessage('error',ltipack.utStripErrorHeader(ME.message));
        C = [];
    end
end
% Reset warnings
warning(sw); lastwarn(lw,lwid);


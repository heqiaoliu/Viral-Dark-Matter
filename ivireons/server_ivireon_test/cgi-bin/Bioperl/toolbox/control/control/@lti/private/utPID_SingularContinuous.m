function [C, Kp, Ki, Kd] = utPID_SingularContinuous(Model,Type,CPM,TAU,IsDebug,fHandle)
% Singular frequency based P/PI/PID Tuning sub-routine (Continuous).
%
% ----------------------------------------------------------------
%
%                   Parallel Form               
%       P           C = Kp                              
%       PI          C = Kp + Ki/s                       
%       PID         C = Kp + Ki/s + Kd*s/(TAU*s+1) where TAU is known     
%                   when TAU is 0, we have a PID without derivative filter
%
% ----------------------------------------------------------------
%
% Input arguments:
%       Model           a SISO LTI plant model in continuous time
%       Type            controller type: 'p'/'pi'/'pid'
%       CPM             performance criteria: 'IAE'/'ISE'/'ITAE'/'ITSE'
%       TAU             derivative filter time constant (defined as 1/N)
%       IsDebug:        stable polyhedra and step response are plotted
% Output arguments:
%       C               controller in zpk format
%       Kp,Ki,Kd        controller parameters

%   Author(s): Rong Chen
%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.5 $ $Date: 2009/07/09 20:50:39 $

% ----------------------------------------------------------------
%% initialize outputs
% ----------------------------------------------------------------
% controller is always returned in zpk format
C = []; Kp = []; Ki = []; Kd = [];

% ----------------------------------------------------------------
%% Key equations used in singular frequency computation
%
%   P:  (design with stability segments)
%       Kp + real(1/G(jw)) = 0
%       imag(1/G(jw)) = 0
%
%   PI: (design with stability boundary locus)  
%       Kp + real(1/G(jw)) = 0
%       Ki - imag(1/G(jw))*w = 0
%
%   PID: (design with stable polyhedra) 
%       (1) if TAU>0, add derivative filter into the plant model G = Model/(TAU*s+1)
%       (2) Obtain C from
%               Kp + real(1/G(jw)) = 0
%               Ki - w^2*Kd - imag(1/G(jw))*w = 0
%       (3) Return PID controller as C/(TAU*s+1)
% ----------------------------------------------------------------

%% Augment plant if TAU is nonzero for PID type
if strcmpi(Type,'pid') && TAU>0
    Model = Model * tf(1,[TAU 1]);
end

%% Determine all the critical frequencies that are min/max on Kp(w) curve 
[KpC, WpC, SignAtInfP, zpkKpFunc] = utPIDGetR1Continuous(Model,Type,IsDebug);

%% generate Kp intervals based on the critical Kp values and grid Kp axis
[KpInterval, KpGridPoints] = utPIDGetGrids(KpC);

% ----------------------------------------------------------------
%% find stabilizing controller for the selected control law
% ----------------------------------------------------------------
switch Type
% ----------------------------------------------------------------
%% the controller is Kp
% ----------------------------------------------------------------
    case 'p'
        % initialize best performance index to nan value
        ct = 1; BestKp = []; BestCPM = zeros(0,3);
        % brutal force search on all KpGridPoints
        for KpSegmentIndex = 1:length(KpGridPoints)
            % get Kp grid points (largest absolute value first)
            KpPoints = KpGridPoints{KpSegmentIndex};
            [dummy idx] = sort(abs(KpPoints));
            KpPoints = KpPoints(fliplr(idx));
            % for a P controller, if a Kp value in a Kp interval is
            % stable, all the Kp values in this interval is stable
            IsThisIntervalStable = false;
            for ctKp = 1:length(KpPoints)
                Kp = KpPoints(ctKp);
                % get closed loop system
                sys = feedback(Model*Kp,1);
                % check closed loop stability
                if IsThisIntervalStable || isstable(sys)
                    % mark this interval stable
                    IsThisIntervalStable = true;
                    % calculate control performance metric
                    BestKp(ct) = Kp;                             %#ok<*AGROW>
                    BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                    ct = ct+1;
                else
                    break;
                end
            end
            if ~isempty(fHandle)
                try
                    fHandle(KpSegmentIndex/length(KpGridPoints));
                end
            end
        end
        % obtain best controller
        if ~isempty(BestCPM)
            % adjust performance metric claculation
            OverallBestCPM = utPIDAdjustCPM(CPM,BestCPM);
            % return P controller parameter
            if ~all(isinf(OverallBestCPM))
                [junk ind] = min(OverallBestCPM);
                Kp = BestKp(ind);
                C = zpk(Kp);
                % plot for test only
                if IsDebug
                    figure; step(feedback(Model*C,1));
                end
            end
        end
% ----------------------------------------------------------------
%% the controller is KP + KI/s
% ----------------------------------------------------------------
    case 'pi'
        % grid Ki if controller type is 'pi'
        % determine all the critical frequencies that are corresponding to
        % local minimums or maximums on the r0(w) curve 
        [KiC, WiC, SignAtInfI, zpkKiFunc] = utPIDGetR0Continuous(Model,IsDebug);
        % generate Ki intervals based on the critical Ki values and grid Ki axis
        [KiInterval, KiGridPoints] = utPIDGetGrids(KiC);
        % initialize best performance index to nan values
        BestKpKi = []; BestCPM = zeros(0,3);
        % ----------------------------------------------------------------
        % get flow directions for each Kp interval that has at least one critical frequency
        [FlowDirectionsKp, NumOfIntersectionsKp] = utPIDGetFlowDirectionContinuous(KpInterval,KpC,SignAtInfP);
        % loop through each Kp interval
        for KpSegmentIndex = 1:length(KpGridPoints)
            % get Kp grid points
            KpPoints = KpGridPoints{KpSegmentIndex};
            FlowDirection = FlowDirectionsKp{KpSegmentIndex};
            NumOfIntersection = NumOfIntersectionsKp(KpSegmentIndex);
            % find all the stabilizing controllers in this Kp interval,
            % starting from the lower bound
            [NewBestCPM,NewBestKpKi] = ...
                utPIDTuning_PI_Continuous('Kp',Model,zpkKpFunc,KpPoints,KpC,WpC,...
                    FlowDirection,NumOfIntersection,SignAtInfP,CPM);        
            BestKpKi = [BestKpKi;NewBestKpKi];
            BestCPM = [BestCPM;NewBestCPM];
            if ~isempty(fHandle)
                try
                    fHandle(KpSegmentIndex/length(KpGridPoints)/2);
                end
            end
        end
        % get flow directions for each Ki interval that has at least one critical frequency
        [FlowDirectionsKi,NumOfIntersectionsKi] = utPIDGetFlowDirectionContinuous(KiInterval,KiC,SignAtInfI);
        % loop through each Kp interval
        for KiSegmentIndex = 1:length(KiGridPoints)
            % get Kp grid points
            KiPoints = KiGridPoints{KiSegmentIndex};
            FlowDirection = FlowDirectionsKi{KiSegmentIndex};
            NumOfIntersection = NumOfIntersectionsKi(KiSegmentIndex);
            % find all the stabilizing controllers in this Kp interval,
            % starting from the lower bound
            [NewBestCPM,NewBestKpKi] = ...
                utPIDTuning_PI_Continuous('Ki',Model,zpkKiFunc,KiPoints,KiC,WiC,...
                    FlowDirection,NumOfIntersection,SignAtInfI,CPM);        
            BestKpKi = [BestKpKi;NewBestKpKi];
            BestCPM = [BestCPM;NewBestCPM];
            if ~isempty(fHandle)
                try
                    fHandle(KiSegmentIndex/length(KiGridPoints)/2+0.5);
                end
            end
        end
        % obtain best controller
        if ~isempty(BestCPM)
            % adjust performance metric claculation
            OverallBestCPM = utPIDAdjustCPM(CPM,BestCPM);
            % return controller parameter
            if ~all(isinf(OverallBestCPM))
                % locate the best controller
                [junk ind] = min(OverallBestCPM);                    
                Kp = BestKpKi(ind,1); 
                Ki = BestKpKi(ind,2); 
                C = zpk(tf([Kp Ki],[1 0]));                                        
                % plot for test only
                if IsDebug
                    figure; step(feedback(Model*C,1));
                end
            end
        end
% ----------------------------------------------------------------
%% the controller is KP + KI/s + KD*s or KP + KI/s + KD*s/(1+TAU*S)
% ----------------------------------------------------------------
    case 'pid' 
        % prepare plot
        if IsDebug, figure; end
        % initialize best performance index to nan values
        BestKdKpKi = []; BestCPM = zeros(0,3);
        % get flow directions for each Kp interval that has at least one critical frequency
        [FlowDirections, NumOfIntersections] = utPIDGetFlowDirectionContinuous(KpInterval,KpC,SignAtInfP);
        % loop through each Kp interval
        for KpSegmentIndex = 1:length(KpGridPoints)
            % get Kp grid points
            KpPoints = KpGridPoints{KpSegmentIndex};
            FlowDirection = FlowDirections{KpSegmentIndex};
            NumOfIntersection = NumOfIntersections(KpSegmentIndex);
            % find all the stabilizing controllers in this Kp interval,
            % starting from the lower bound
            [NewBestCPM,NewBestKdKpKi] = ...
                utPIDTuning_PID_Continuous(Model,zpkKpFunc,KpPoints,KpC,WpC,...
                    FlowDirection,NumOfIntersection,SignAtInfP,CPM,IsDebug,...
                    fHandle,KpSegmentIndex,length(KpGridPoints));        
            % if failed, try again by starting from the upper bound
            BestKdKpKi = [BestKdKpKi;NewBestKdKpKi];
            BestCPM = [BestCPM;NewBestCPM];
        end
        if ~isempty(BestCPM)
            % adjust performance metric claculation
            OverallBestCPM = utPIDAdjustCPM(CPM,BestCPM);
            % return controller parameter
            if ~all(isinf(OverallBestCPM))
                % locate the best controller
                [junk ind] = min(OverallBestCPM);                    
                if TAU==0
                    Kd = BestKdKpKi(ind,1); Kp = BestKdKpKi(ind,2); Ki = BestKdKpKi(ind,3); 
                    C = zpk(tf([Kd Kp Ki],[1 0]));                                        
                else
                    % mapping Kp Ki and Kd into Kp+Ki/s+Kp*s/(TAU*s+1) format
                    C = zpk(tf(BestKdKpKi(ind,:),[TAU 1 0]));
                    val = [1 TAU 0;0 1 TAU;0 0 1]\BestKdKpKi(ind,:)';
                    Kd = val(1); 
                    Kp = val(2); 
                    Ki = val(3);
                end
                % plot for test only
                if IsDebug
                    % filter still a part of in Model
                    figure; step(feedback(Model*zpk(tf(BestKdKpKi(ind,:),[1 0])),1));
                end
            end
        end
end


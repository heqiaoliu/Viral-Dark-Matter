function [C, Kp, Ki, Kd] = utPID_SingularDiscrete(Model,Type,CPM,TAU,IsDebug,fHandle)
% Singular frequency based P/PI/PID Tuning sub-routine (Discrete).
%
% ----------------------------------------------------------------
% Based on backward differentiation on both integrator and differentiator,
% we have discrete PID in following expressions:
%
%                   Parallel Form               
%       P           c0                              
%       PI          (c1*z + c0)/(z-1)
%       PID         (c2*z^2 + c1*z + c0)/(z-1)/(z-z0) where z0=TAU/(TAU+Ts)
%                   when TAU is 0, we have a PID without derivative filter
%
% ----------------------------------------------------------------
%
% Input arguments:
%       Model:          a SISO LTI plant model in discrete time
%       Type:           controller type: 'p'/'pi'/'pid'
%       CPM             performance criteria: 'IAE'/'ISE'/'ITAE'/'ITSE'
%       TAU             derivative filter time constant in continuous time (defined as 1/N)
%       IsDebug:        stable polyhedra and step response are plotted
% Output arguments:
%       C:              controller in zpk format
%       Kp,Ki,Kd        controller parameters (in continuous time)
%                       [Kd;Kp;Ki]=Ts*inv([1 Ts Ts^2;-2 -Ts Ts^2;1 0 0])*[c2;c1;c0]
%
%   Author(s): Rong Chen
%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.6 $ $Date: 2009/07/09 20:50:40 $

% ----------------------------------------------------------------
%% initialize outputs
% ----------------------------------------------------------------
% controller is always returned in zpk format
C = []; Kp = []; Ki = []; Kd = [];

% ----------------------------------------------------------------
%% Key equations used in singular frequency computation
%
%   P:  (design with stability segments)
%       c0 + real(1/G(z)) = 0
%       imag(1/G(z)) = 0
%
%   PI: (design with stability boundary locus)  
%       c1*sin(a) + imag((z-1)/G(z)) = 0
%       c1*cos(a) + c0 + real((z-1)/G(z)) = 0
%
%   PID: (design with stable polyhedra) 
%       if z0=0
%           -r1*sin(a) + imag((z-1)/G(z)) = 0
%           r2 + r1*cos(a) + 2*r0*cos(a) + real((z-1)/G(z)) = 0
%       else
%           -r1*sin(a) + imag((z-z0)*(z-1)/G(z)/z) = 0
%           r2 + r1*cos(a) + 2*r0*cos(a) + real((z-z0)*(z-1)/G(z)/z) = 0
%       end
%       where [c2;c1;c0] = [0 0 1;1 0 0;0 1 1] * [r2;r1;r0]
% ----------------------------------------------------------------

%% Get sample time
Ts = abs(getTs(Model));

%% Determine all the critical frequencies that are min/max on r1(z) curve 
[r1C, alphaR1C, SignAtPIR1, R1Func, R0AuxFunc] = utPIDGetR1Discrete(Model,Type,TAU,IsDebug);

%% Determine r1 intervals and obtain r1 samples used in the design
[r1Interval, r1GridPoints] = utPIDGetGrids(r1C);

% ----------------------------------------------------------------
%% find stabilizing controller for the selected control law
switch Type
% ----------------------------------------------------------------
%% the controller is r1
% ----------------------------------------------------------------
    case 'p'
        % initialize best performance index to nan value
        ct = 1; BestKp = []; BestCPM = zeros(0,3);
        % loop through each Kp interval
        for r1SegmentIndex = 1:length(r1GridPoints)
            % get Kp grid points (largest absolute value first)
            r1Points = r1GridPoints{r1SegmentIndex};
            [dummy idx] = sort(abs(r1Points));
            r1Points = r1Points(fliplr(idx));
            % for a P controller, if a r1 value in a r1 interval is
            % stable, all the r1 values in this interval is stable
            IsThisIntervalStable = false;
            for ctR1 = 1:length(r1Points)
                r1 = r1Points(ctR1);
                % get closed loop system
                sys = feedback(Model*r1,1);
                % check closed loop stability
                if IsThisIntervalStable || isstable(sys)
                    % mark this interval stable
                    IsThisIntervalStable = true;
                    % calculate control performance metric
                    BestKp(ct) = r1;                             %#ok<*AGROW>
                    BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                    ct = ct+1;
                else
                    break;
                end
            end
            if ~isempty(fHandle)
                try
                    fHandle(ctR1/length(r1Points));
                end
            end
        end
        % obtain best controller
        if ~isempty(BestCPM)
            % adjust performance metric claculation
            BestCPM = utPIDAdjustCPM(CPM,BestCPM);
            % return P controller parameter
            if ~all(isinf(BestCPM))
                [junk ind] = min(BestCPM(:,1));
                Kp = BestKp(ind);  
                C = zpk([],[],Kp,Ts);
                % plot for test only
                if IsDebug
                    figure; step(feedback(Model*Kp,1));
                end
            end
        end
%% ----------------------------------------------------------------
%% the controller is (r1z+r0)/(z-1)
% ----------------------------------------------------------------
    case 'pi'
        % determine all the critical values and frequencies that are
        % corresponding to local minimums or maximums in Ki(w) curve
        [r0C, alphaR0C, SignAtPIR0, R0Func, R1AuxFunc] = utPIDGetR0Discrete(Model,IsDebug);
        % grid Ki segment based on critical Ki values
        [r0Interval, r0GridPoints] = utPIDGetGrids(r0C);
        % initialize best performance index to nan values
        BestKpKi = []; BestCPM = zeros(0,3);
        % ----------------------------------------------------------------
        % get flow directions for each Kp interval that has at least one critical frequency
        [FlowDirectionsR1, NumOfIntersectionsR1]= utPIDGetFlowDirectionDiscrete(r1Interval,r1C,SignAtPIR1);
        % loop through each Kp interval
        for r1SegmentIndex = 1:length(r1GridPoints)
            % get r1 grid points
            r1Points = r1GridPoints{r1SegmentIndex};
            FlowDirection = FlowDirectionsR1{r1SegmentIndex};
            NumOfIntersection = NumOfIntersectionsR1(r1SegmentIndex);
            % find all the stabilizing controllers in this r1 interval,
            % starting from the lower bound
            [NewBestCPM,NewBestKpKi] = ...
                utPIDTuning_PI_Discrete('r1',Model,R1Func,R0AuxFunc,r1Points,r1C,alphaR1C,...
                    FlowDirection,NumOfIntersection,SignAtPIR1,CPM);        
            BestKpKi = [BestKpKi;NewBestKpKi];
            BestCPM = [BestCPM;NewBestCPM];
            if ~isempty(fHandle)
                try
                    fHandle(r1SegmentIndex/length(r1GridPoints)/2);
                end
            end
        end
        % ----------------------------------------------------------------
        % get flow directions for each Ki interval that has at least one critical frequency
        [FlowDirectionsR0, NumOfIntersectionsR0]= utPIDGetFlowDirectionDiscrete(r0Interval,r0C,SignAtPIR0);
        % loop through each Kp interval
        for r0SegmentIndex = 1:length(r0GridPoints)
            % get r0 grid points
            r0Points = r0GridPoints{r0SegmentIndex};
            FlowDirection = FlowDirectionsR0{r0SegmentIndex};
            NumOfIntersection = NumOfIntersectionsR0(r0SegmentIndex);
            % find all the stabilizing controllers in this r0 interval,
            % starting from the lower bound
            [NewBestCPM,NewBestKpKi] = ...
                utPIDTuning_PI_Discrete('r0',Model,R0Func,R1AuxFunc,r0Points,r0C,alphaR0C,...
                    FlowDirection,NumOfIntersection,SignAtPIR0,CPM);        
            BestKpKi = [BestKpKi;NewBestKpKi];
            BestCPM = [BestCPM;NewBestCPM];
            if ~isempty(fHandle)
                try
                    fHandle(r0SegmentIndex/length(r0GridPoints)/2+0.5);
                end
            end
        end
        % ----------------------------------------------------------------
        if ~isempty(BestCPM)
            % adjust performance metric claculation
            OverallBestCPM = utPIDAdjustCPM(CPM,BestCPM);
            % return controller parameter
            if ~all(isinf(OverallBestCPM))
                % locate the best controller
                [junk ind] = min(OverallBestCPM);                    
                C = zpk(tf(BestKpKi(ind,:),[1 -1],Ts));
                % plot for test only
                if IsDebug
                    figure; step(feedback(Model*zpk(tf(BestKpKi(ind,:),[1 -1],Ts)),1));
                end
            end
        end
%% ---------------------------------------------------------------
% the controller is (c2*z^2 + c1*z + c0)/(z-1)/(z-z0)
% ----------------------------------------------------------------
    case 'pid'
        % define Transformation Matrix: C = [c2;c1;c0] = T * [r2;r1;r0]
        T = [0 0 1;1 0 0;0 1 1];
        % prepare plot
        if IsDebug, figure; end
        % initialize best performance index to nan values
        BestKdKpKi = []; BestCPM = zeros(0,3);
        % get flow directions for each Kp interval that has at least one critical frequency
        [FlowDirections, NumOfIntersections]= utPIDGetFlowDirectionDiscrete(r1Interval,r1C,SignAtPIR1);
        % loop through each Kp interval
        for r1SegmentIndex = 1:length(r1GridPoints)
            % get design parameters
            r1Points = r1GridPoints{r1SegmentIndex};
            FlowDirection = FlowDirections{r1SegmentIndex};
            NumOfIntersection = NumOfIntersections(r1SegmentIndex);
            % find all the stabilizing controllers in this Kp interval,
            % starting from the lower bound
            [NewBestCPM,NewBestKdKpKi] = ...
                utPIDTuning_PID_Discrete(Model,TAU,R1Func,R0AuxFunc,T,r1Points,r1C,alphaR1C,...
                    FlowDirection,NumOfIntersection,SignAtPIR1,CPM,IsDebug,...
                    fHandle,r1SegmentIndex,length(r1GridPoints));
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
                % pid
                if TAU==0
                    C = zpk(tf(BestKdKpKi(ind,:)*T',[1 -1 0],Ts));
                else
                    z0 = (2*TAU-Ts)/(2*TAU+Ts);
                    %z0 = TAU/(TAU+Ts);
                    C = zpk(tf(BestKdKpKi(ind,:)*T',[1 -(1+z0) z0],Ts));
                end
                % plot for test only
                if IsDebug
                    figure; step(feedback(Model*C,1));
                end
            end
        end
end


function  [BestCPM, BestKpKi] = ...
            utPIDTuning_PI_Continuous(Type,Model,KFunc,KPoints,KC,wC,...
                FlowDirection,NumOfIntersection,SignAtInf,CPM)
% Singular frequency based P/PI/PID Tuning sub-routine (Continuous).
%
% This function search for stable areas defined by stability boundary locus
% (PI only) 
%
% Input arguments
%   Type:               'kp' or 'ki'
%   Model:              plant model
%   KFunc:              r(s)
%   KPoints:            r grid values
%   KC:                 critical r values
%   wC:                 critical r frequencies
%   FlowDirection:      r flow direction 
%   NumOfIntersection:  number of intersections between line and curve
%   SignAtInf:          sign at r(inf)
%   CPM:                controller performance metric selection
%
% Output arguments
%   BestCPM:                best performance 
%   BestKdKpKi:             best controller
%

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:17 $

% reset Kp interval stability flag to false
BestKpKi = zeros(0,2); BestCPM = zeros(0,3);
% reset counter
ct = 1;
% check stability for each Kp sample
for ctK = 1:length(KPoints)
    % get grid point
    K = KPoints(ctK);
    % skip when K==0
    if K~=0
        % find singular frequencies
        W = utPIDGetSingularFreqsContinuous(Type,KFunc,KC,wC,FlowDirection,NumOfIntersection,SignAtInf,K);
        if any(W<0)
            continue
        end
        % find stability boundary lines from critical r0/r1 values, stored in LC
        if strcmp(Type,'Kp')
            % determine KiC
            % Ki = 0 is always a stability bound
            LC = 0;
            % others
            if ~isempty(W)
                val = freqresp(Model,W);     
                LC = [LC;imag(1./val(:)).*W]; %#ok<*AGROW>
            end
            % sort Ki
            [LC ind] = sort(LC);
            % set flow direction
            NewFlowDirection = FlowDirection(ind);    
            % set flag
            ExpectedSign = 1;        
        else
            % determine KpC
            % Kp = 0 is not necessarily a stability bound
            LC = [];
            % others
            if ~isempty(W)
                val = freqresp(Model,W);
                LC = -real(1./val(:));
                % sort Ki
                [LC ind] = sort(LC);
                % the first direction is useless for Kp because Kp = 0 is not
                % necessarily a stability bound 
                NewFlowDirection = FlowDirection(2:end);    
                % set flow direction
                NewFlowDirection = NewFlowDirection(ind);    
            end
            ExpectedSign = -1;                
        end
        % pick up a r0/r1 value inside the r0/r1 interval
        if ~isempty(LC)
            % find stable r1-r0 pair
            for ctF = 0:length(NewFlowDirection)
                % interval open to -inf and satisfies flow condition
                if ctF==0 && NewFlowDirection(1)== ExpectedSign
                    K2 = LC(1)-0.1*max((abs(LC(1))<1),abs(LC(1)));
                % interval open to +inf and satisfies flow condition
                elseif ctF==length(NewFlowDirection) && NewFlowDirection(ctF)==-ExpectedSign
                    K2 = LC(end)+0.1*max((abs(LC(end))<1),abs(LC(end)));
                % closed interval and satisfies flow condition
                elseif ctF~=0 && ctF~=length(NewFlowDirection) && ...
                        NewFlowDirection(ctF)==-ExpectedSign && NewFlowDirection(ctF+1)==ExpectedSign
                    % pick up the center point
                    K2 = (LC(ctF)+LC(ctF+1))/2;
                else
                    continue
                end
                if isfinite(K2) && (K2~=0)
                    % check the closed loop stability and generate controller
                    if strcmp(Type,'Kp')
                        sys = feedback(Model*zpk(tf([K K2],[1 0])),1);
                        if isstable(sys) && isproper(sys)
                            % calculate control performance metric
                            BestKpKi(ct,:) = [K K2];                            
                            BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                            ct = ct+1;
                        end
                    else
                        sys = feedback(Model*zpk(tf([K2 K],[1 0])),1);
                        if isstable(sys) && isproper(sys)
                            % calculate control performance metric
                            BestKpKi(ct,:) = [K2 K];                            
                            BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                            ct = ct+1;
                        end
                    end
                end
            end
        end
    end
end


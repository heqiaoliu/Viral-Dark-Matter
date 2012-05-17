function [BestCPM,BestKpKi] = ...
    utPIDTuning_PI_Discrete(Type,Model,RFunc,AuxFunc,rPoints,rC,alphaC,...
        FlowDirection,NumOfIntersection,SignAtPI,CPM)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine (Discrete).
%
% This function search for stable areas defined by stability boundary locus
% (PI only) 
%
% Input arguments
%   Type:               'r1' or 'r0'
%   Model:              plant model
%   RFunc:              r(z)
%   AuxFunc:            auxiliary function
%   rPoints:            r grid values
%   rC:                 critical r values
%   alphaC:             critical frequencies
%   FlowDirection:      flow direction 
%   FlowSign:           flow direction at alpha = 0
%   NumOfIntersection:  number of intersections between line and curve
%   SignAtPI:           sign at r(PI)
%   CPM:                controller performance metric selection
%
% Output arguments
%   BestCPM:                best performance 
%   BestKdKpKi:             best controller
%

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:18 $

% get sampling time
Ts = abs(getTs(Model));
% reset Kp interval stability flag to false
BestKpKi = zeros(0,2); BestCPM = zeros(0,3);
% reset counter
ct = 1;
% check stability for each Kp sample
for ctR = 1:length(rPoints)
    % get grid point
    r = rPoints(ctR);
    % skip when r==0
    if r~=0
        % find CRB lines based on singular frequencies
        Alpha = utPIDGetSingularFreqsDiscrete(Type,RFunc,rC,alphaC,FlowDirection,NumOfIntersection,SignAtPI,r);
        % find stability boundary lines
        if strcmpi(Type,'r1')
            % determine r0
            % r0 = -r1 is always a stability bound
            r2C = -r;
            % others
            if ~isempty(Alpha)
                val = freqresp(AuxFunc,exp(Alpha*1i));     
                r2C = [r2C;-(cos(Alpha)*r+real(val(:)))]; %#ok<*AGROW>
            end
            % set flag
            ExpectedSign = 1;        
        else
            % determine r1        
            % r1 = -r0 is always a stability bound
            r2C = -r;        
            % others
            if ~isempty(Alpha)
                val = freqresp(AuxFunc,exp(Alpha*1i));     
                r2C = -(cos(Alpha)*r+real(val(:)));
            end
            % set flag
            ExpectedSign = -1;        
        end
        % sort r
        [r2C ind] = sort(r2C);
        NewFlowDirection = FlowDirection(ind);    
        % pick up a r0/r1 value inside the r0/r1 interval
        % find polygons formed by those lines
        for ctF = 0:length(NewFlowDirection)
            if ctF==0 && NewFlowDirection(1)== ExpectedSign
                r2 = r2C(1)-max(1,0.1*abs(r2C(1)));
            elseif ctF==length(NewFlowDirection) && NewFlowDirection(ctF)==-ExpectedSign
                r2 = r2C(end)+max(1,0.1*abs(r2C(end)));
            elseif ctF~=0 && ctF~=length(NewFlowDirection) && NewFlowDirection(ctF)==-ExpectedSign && NewFlowDirection(ctF+1)==ExpectedSign
                r2 = (r2C(ctF)+r2C(ctF+1))/2;
            else
                continue
            end
            if isfinite(r2) && (r2~=0)
                if strcmpi(Type,'r1')
                    sys = feedback(Model*tf([r r2],[1 -1],Ts),1);
                     % if a stable polygon is found, record it                       
                    if isstable(sys) && isproper(sys)
                        % calculate control performance metric
                        BestKpKi(ct,:) = [r r2];                            
                        BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                        ct = ct+1;
                    end
                else
                    sys = feedback(Model*tf([r2 r],[1 -1],Ts),1);
                     % if a stable polygon is found, record it                       
                    if isstable(sys) && isproper(sys)
                        % calculate control performance metric
                        BestKpKi(ct,:) = [r2 r];                            
                        BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                        ct = ct+1;
                    end
                end
            end
        end
    end
end


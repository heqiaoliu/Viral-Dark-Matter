function [BestCPM,BestKdKpKi] = ...
    utPIDTuning_PID_Discrete(Model,TAU,R1Func,R02Func,T,r1Points,r1C,alphaC,...
        FlowDirection,NumOfIntersection,SignAtPI,CPM,PlotNeeded,fHandle,SegID,TotalSeg)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine (Discrete).
%
% This function search for stable polygons defined by singular lines (PID only)
%
% Input arguments
%   Model:              plant model
%   R1Func:             r1(z)
%   R02Func:            auxiliary function
%   r1Points:           r1 grid values
%   r1C:                critical r1 values
%   alphaC:             critical frequencies
%   FlowDirection:      flow direction
%   NumOfIntersection:  number of intersections between line and curve
%   SignAtPI:           sign at r1(PI)
%   CPM:                controller performance metric selection
%
% Output arguments
%   BestCPM:                best performance 
%   BestKdKpKi:             best controller
%

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:21:16 $

% reset Kp interval stability flag to false
BestKdKpKi = zeros(0,3); BestCPM = zeros(0,3);
IsOptimized = false;
% PI
valuePI = 3.1415926359;
% get sampling time
Ts = abs(getTs(Model));
% deal with TAU
if TAU==0
    % no derivative filter pole
    z0 = 0;
else
    % one derivative filter pole from tustin/bilinear transformation
    % s= 2*(z-1)/Ts/(z+1)
    z0 = (2*TAU-Ts)/(2*TAU+Ts);
    %z0 = TAU/(TAU+Ts);
end
% reset counter
ct = 1;
% check stability for each Kp sample
for ctR1 = 1:length(r1Points)
    % get a r1 value
    r1 = r1Points(ctR1);
    % find CRB lines based on singular frequencies
    Alpha = utPIDGetSingularFreqsDiscrete('r1',R1Func,r1C,alphaC,FlowDirection,NumOfIntersection,SignAtPI,r1);
    % add RRB bounds at z=+/-1
    Alpha = [0;Alpha]; %#ok<*AGROW>
    if SignAtPI == 0
        Alpha = [Alpha;valuePI]; 
    end
    % generate line parameter: from y=kx+b format to ax+by+c=0 format
    if isempty(Alpha)
        continue;
    else
        lineParameter = [2*cos(Alpha) ones(size(Alpha)) cos(Alpha)*r1+...
            squeeze(real(freqresp(R02Func,exp(Alpha*1i))))];
    end
    % find polygons formed by those lines
    try
        [DCEL, Vertices, PolygonE, PolygonV] = utPIDGetPolygon(lineParameter,[],[],false);
    catch ME %#ok<*NASGU>
        continue
    end
    % loop through each polygon
    for ctE = 1:length(PolygonE)
        % check if the polygon satisfies the flow condition
        if utPIDCheckPolygon(DCEL, Vertices, PolygonE{ctE}, lineParameter, FlowDirection)
            % locate the test point as the center of the polygon 
            [r0 r2] = utPIDGetCentroid(Vertices(PolygonV{ctE},:));
            % check its stability and generate controller
            sys = feedback(Model*zpk(tf([r2 r1 r0]*T',[1 -(1+z0) z0],Ts)),1);
            % if a stable polygon is found, record it                       
            if isstable(sys) && isproper(sys)
                % step response
                if IsOptimized
                    [y,t] = step(sys); %#ok<*UNRCH>
                    % optimization within the polygon using center as start
                    options = optimset('Display','off');
                    MinVal = min(Vertices(PolygonV{ctE},:));
                    MaxVal = max(Vertices(PolygonV{ctE},:));
                    OptimalController = fminsearchbnd(@(x) localPIDCalculateCPM(x,z0,T,Ts,Model,r1,CPM,t),[r0 r2],MinVal,MaxVal,options); %#ok<NASGU>
                    r0 = OptimalController(1);
                    r2 = OptimalController(2);
                    sys = feedback(Model*zpk(tf([r2 r1 r0]*T',[1 -(1+z0) z0],Ts)),1);
                end
                % plot region
                if PlotNeeded
                    utPIDPlotPolygon(gcf,Vertices,PolygonV,ctE,r1,eye(size(T)));
                end
                % calculate control performance metric
                BestKdKpKi(ct,:) = [r2 r1 r0];                          
                BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                ct = ct+1;
            end
        end
    end
    if ~isempty(fHandle)
        fHandle((SegID-1)/TotalSeg+ctR1/length(r1Points)/TotalSeg);
    end
end

%% ----------------------------------------------------------------
function PI = localPIDCalculateCPM(x,z0,T,Ts,Model,r1,CPM,Tstop)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine
% calculate performance index based on selected metric
% compute step response using settling time
r0 = x(1);
r2 = x(2);
sys = feedback(Model*zpk(tf([r2 r1 r0]*T',[1 -(1+z0) z0],Ts)),1);
if isstable(sys) && isproper(sys)
    % compute step response
    [y,t] = step(sys,Tstop);
    % get error 
    Error = 1 - y;
    % compute performance index
    switch CPM
        case 'IAE'
            PI = sum(abs(Error(1:end-1)).*diff(t));
        case 'ISE'
            PI = sum(Error(1:end-1).^2.*diff(t));
        case 'ITAE'
            PI = sum(abs(Error(1:end-1)).*t(1:end-1).*diff(t));
        case 'ITSE'
            PI = sum(Error(1:end-1).^2.*t(1:end-1).*diff(t));
    end
else
    PI = inf;
end

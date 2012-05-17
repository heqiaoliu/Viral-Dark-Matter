function [BestCPM,BestKdKpKi] = ...
    utPIDTuning_PID_Continuous(Model,KpFunc,KpPoints,KpC,wC,...
    FlowDirection,NumOfIntersection,SignAtInf,CPM,PlotNeeded,fHandle,SegID,TotalSeg)
% Singular frequency based P/PI/PID Tuning sub-routine (Continuous).
%
% This function search for stable polygons defined by singular lines (PID only)
%
% Input arguments
%   Model:              plant model
%   KpFunc:             r1(s)
%   KpPoints:           r1 grid values
%   KpC:                critical r1 values
%   wC:                 critical frequencies
%   FlowDirection:      flow direction
%   NumOfIntersection:  number of intersections between line and curve
%   SignAtInf:          sign at r1(inf)
%   CPM:                controller performance metric selection
%
% Output arguments
%   BestCPM:                best performance 
%   BestKdKpKi:             best controller
%

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:15 $

% reset Kp interval stability flag to false
BestKdKpKi = zeros(0,3); BestCPM = zeros(0,3);
IsOptimized = false;
% reset counter
ct = 1;
% prepare RRB and IRB lines
[RRBlineParameter, IRBlineParameter] = localGetRRBandIRBLines(Model,SignAtInf);
% check stability for each Kp sample
for ctKp = 1:length(KpPoints)
    % get a Kp value
    Kp = KpPoints(ctKp);
    % find CRB lines based on singular frequencies
    W = utPIDGetSingularFreqsContinuous('Kp',KpFunc,KpC,wC,FlowDirection,NumOfIntersection,SignAtInf,Kp);
    % generate CRB line parameter: from y=kx+b format to ax+by+c=0 format
    % sin(theta)*x+(-cos(theta))*y+Ki*cos(theta)=0 where theta = atan(slope)
    if isempty(W)
        CRBlineParameter = [];
    elseif any(W<0)
        if ~isempty(fHandle)
            fHandle((SegID-1)/TotalSeg+ctKp/length(KpPoints)/TotalSeg);
        end
        continue
    else
        val = freqresp(Model,W);
        Ki = imag(1./val(:)).*W;
        theta = atan(W.^2);
        CRBlineParameter = [sin(theta) -cos(theta) Ki.*cos(theta)];
    end
    % build the line set with lines from RRB IRB and CRB
    lineParameter = [RRBlineParameter;CRBlineParameter;IRBlineParameter];
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
            [Kd Ki] = utPIDGetCentroid(Vertices(PolygonV{ctE},:));
            % check its stability and generate controller
            sys = feedback(Model*tf([Kd Kp Ki],[1 0]),1);
            % if a stable polygon is found, record it                       
            if isstable(sys) && isproper(sys)
                % optimization within the polygon using center as start
                if IsOptimized
                    % step response
                    [y,t] = step(sys); %#ok<UNRCH>
                    options = optimset('Display','off'); 
                    MinVal = min(Vertices(PolygonV{ctE},:));
                    MaxVal = max(Vertices(PolygonV{ctE},:));
                    OptimalController = fminsearchbnd(@(x) localPIDCalculateCPM(x,Model,Kp,CPM,t(end)),[Kd Ki],MinVal,MaxVal,options); %#ok<NASGU>
                    Kd = OptimalController(1);
                    Ki = OptimalController(2);
                    sys = feedback(Model*tf([Kd Kp Ki],[1 0]),1);
                end
                % plot region
                if PlotNeeded
                    utPIDPlotPolygon(gcf,Vertices,PolygonV,ctE,Kp,eye(3));
                end
                % calculate control performance metric
                BestKdKpKi(ct,:) = [Kd Kp Ki];                            
                BestCPM(ct,:) = utPIDCalculateCPM(CPM,sys);
                ct = ct+1;
            end
        end
    end
    if ~isempty(fHandle)
        fHandle((SegID-1)/TotalSeg+ctKp/length(KpPoints)/TotalSeg);
    end
end

%% ----------------------------------------------------------------
function [RRBlineParameter IRBlineParameter] = localGetRRBandIRBLines(Model,SignAtInf)
% prepare RRB line for PID/PIDF tuning
RRBlineParameter = [0 -1 0];            
% prepare IRB line for PID/PIDF tuning
% Note: IRB exists iff SignAtInf is 0
if SignAtInf == 0
    IRBlineParameter = [1 0 1/evalfr(Model*tf('s'),inf)];
else
    IRBlineParameter = [];
end

%% ----------------------------------------------------------------
function PI = localPIDCalculateCPM(x,Model,Kp,CPM,Tstop)
% Singular frequency based P/PI/PID/PIDF Tuning sub-routine
% calculate performance index based on selected metric
% compute step response using settling time
Kd = x(1);
Ki = x(2);
sys = feedback(Model*tf([Kd Kp Ki],[1 0]),1);
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
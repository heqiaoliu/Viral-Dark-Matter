function varargout = autofixexp(varargin)
%AUTOFIXEXP  Automatically scales the fixed point blocks in a model.
%
%This script automatically changes the scaling of fixed-point 
%data types associated with Simulink blocks and Stateflow data objects 
%that do not have their fixed-point scaling locked. 
%
%The script executes the following autoscaling procedure:  
%
%  1. The script collects range data from model objects that specify 
%     design minimum and maximum values, e.g., by means of the 
%     "Output minimum" or "Output maximum" parameters.  If an 
%     object's design minimum and maximum values are unspecified, 
%     the script collects the logged minimum and maximum values that 
%     the object output during the previous simulation. 
%
%  2. The script uses the collected range data to calculate fraction 
%     lengths that maximize precision and cover the range. 
%
%  3. The script applies its fixed-point scaling recommendations to 
%     the objects in a model. 
 
% Copyright 1994-2009 The MathWorks, Inc.
% $Revision: 1.22.4.28 $  
% $Date: 2009/02/18 02:07:06 $
try
    curBlockDiagram = get_param(gcs, 'Object');
catch e %#ok
    DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
end

if nargin < 1 || ~ischar(varargin{1})

    iStart = 1;
    feval('autoscaler_legacy',varargin{iStart:end})
else
    action = varargin{1};
    SimulinkFixedPoint.Autoscaler.scale(curBlockDiagram, action);
end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end main
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RangeFactor vs SafetyMargin
%
% RangeFactor and SafetyMargin are alternate ways to specify how much extra 
% range the user wants beyond the maximum and minimum values identified
% in curFixPtSimRanges.
%
% The relationship between RangeFactor and SafetyMargin are given in
% the two helper functions below.
%
% Here is a RangeFactor based example:
%    A value of 1.55 specifies that a range AT LEAST 55 percent'
% larger is desired.  A value of 0.85 specifies that a range
% up to 15 percent smaller would be acceptable.
%    Note: the scaling is not exact for the radix point only 
% case, because the range is (approximately) a power of two.
% For a signed number, the range can be (approximately) plus or
% minus ... 1/8, 1/4, 1/2, 1, 2, 4, 8, ...
%    The lower limit is exact, and only the upper limit is 
% approximate.  As is well known, the upper limit is always one
% BIT below a power of two.  For example, a signed four bit integer
% has range -4 to (+4-1).  If the number is a signed four bit fixed
% point with scaling 2^-1, then each bit is worth 0.5 and the range is
% -2 to (+2-0.5).
%    As an example, if the max were 5, and the min was -0.5, then any
% RangeFactor from 4/5 to slightly under 8/5 would produce the
% same radix point.  This would be the radix point that gave a
% range of -8 to +8 (minus a bit).
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RangeFactor = SafetyMargin2RangeFactor(SafetyMargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RangeFactor = 1 + (SafetyMargin/100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SafetyMargin = RangeFactor2SafetyMargin(RangeFactor)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SafetyMargin = 100 * (RangeFactor - 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function autoscaler_legacy(FixPtVerbose,RangeFactor,curFixPtSimRanges,topSubSystemToScale) %#ok
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% The legacy mode DETERMINES and SETS the scaling in one shot using new autoscaler.
%

% ignore the first arg 
if nargin < 1
    % do nothing
end

if nargin < 2
    RangeFactor = [];
end

if nargin < 3
    curFixPtSimRanges = [];
end

if nargin < 4
   topSubSystemToScale = gcs;
end

% SafetyMargin = RangeFactor2SafetyMargin(RangeFactor);

curBlkDiagramToScale = get_param(topSubSystemToScale, 'Object');
if isa(curBlkDiagramToScale, 'Simulink.SubSystem')
    mdlName = bdroot(curBlkDiagramToScale.getFullName);
else
    mdlName = curBlkDiagramToScale.getFullName;
end
try 
    appData = SimulinkFixedPoint.getApplicationData(mdlName);
catch e %#ok
    DAStudio.error('SimulinkFixedPoint:autoscaling:engineInterfaceFail');
end

if ~isempty(RangeFactor)
    appData.SafetyMarginForSimMinMax = RangeFactor2SafetyMargin(RangeFactor);
end

if ~isempty(curFixPtSimRanges)
    appData.dataset.clearresults(appData.ScaleUsing);
    for idx = 1:length(curFixPtSimRanges)
        appData.dataset.adddata(appData.ResultsLocation, fxptds.qrdata({curFixPtSimRanges{idx}}));
    end
end

SimulinkFixedPoint.Autoscaler.scale(curBlkDiagramToScale, 'Propose'); 
setAcceptAll(appData)
SimulinkFixedPoint.Autoscaler.scale(curBlkDiagramToScale, 'Apply'); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setAcceptAll(appData)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

result = appData.dataset.getresults(appData.ScaleUsing);

for i = 1:length(result)
    result(i).Accept = true;
end

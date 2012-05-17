function h = stepresponse(varargin)
%STEPRESPONSE Constructor for step response constraint object

%   Authors: A. Stothert
%   Copyright 2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:06 $

% Create class instance
h = plotconstr.stepresponse;
hParent = [];
if nargin > 0
   %Check to see if we've an explicit parent setting
   idx = find(strcmpi(varargin,'Parent'));
   if ~isempty(idx)
      hParent = varargin{idx+1};
      varargin = {varargin{1:idx-1}, varargin{idx+2:end}};
   end
end

%Create an hggroup property and link the hggroup to this instance
h.initElements(hParent)

%Set event manager
h.EventManager = ctrluis.eventmgr;

%Set the data property
h.Data = srorequirement.steprespdata;


%Set unique ID for the constraint
h.setUID;

% Initialize properties 
nEdge   = 5;   %Two upper, three lower edges
xCoords = [...
   0 3; ...
   3 10;...
   0 1; ...
   1 3; ...
   3 10];
yCoords = [...
   1.2 1.2; ...
   1.01 1.01; ...
   -0.01 -0.01; ...
   0.9 0.9; ...
   0.99 0.99];
h.Orientation    = 'both';
h.xCoords        = xCoords;
h.xUnits         = 'sec';
h.yCoords        = yCoords;
h.Weight         = ones(nEdge,1);
h.yUnits         = 'abs';
h.Linked         = false(nEdge-1,2);      %No linked edges
h.Data.OpenEnd   = [false, true];   %By default right extends to inf
h.xDisplayUnits  = h.TimeUnits;
h.yDisplayUnits  = h.MagnitudeUnits;

% Set step characteristics
h.StepChar.InitialValue      = 0;
h.StepChar.FinalValue        = 1;
h.StepChar.StepTime          = 0;
h.StepChar.RiseTime          = 5;
h.StepChar.SettlingTime      = 10;
h.StepChar.PercentRise       = 80;
h.StepChar.PercentSettling   = 1;
h.StepChar.PercentOvershoot  = 10;
h.StepChar.PercentUndershoot = 1;
%Push characteristics to data
%h.setStepCharacteristics;

% Set CSHTopic
h.HelpData.CSHTopic = 'stepresponseconstraint';

% Install default BDF
h.defaultbdf;

if ~isempty(varargin)
   %Set any constructor called properties
   set(h,varargin{:})
end


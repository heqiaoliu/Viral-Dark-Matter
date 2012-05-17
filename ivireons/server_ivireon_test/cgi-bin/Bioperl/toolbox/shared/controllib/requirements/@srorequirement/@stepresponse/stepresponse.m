function this = stepresponse(varargin) 
% STEPRESPONSE  Constructor for step response constraint
%
 
% Author(s): A. Stothert 07-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:17 $

this = srorequirement.stepresponse;

%Set object defaults
this.Name              = 'Step response bound';
this.Description       = {'Step response characteristc bound.'};
this.Orientation       = 'horizontal';
this.Data              = srorequirement.steprespdata;
this.Source            = [];
this.isFrequencyDomain = false;
this.NormalizeValue    = 1;
this.UID               = srorequirement.utGetUID;

%Set data properties
this.Data.Requirement = this;
this.setData('xUnits','sec');
this.setData('yUnits','abs')
this.setData('type', 'step');

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
this.setData(...
    'xData', xCoords, ...
    'yData', yCoords, ...
    'Weight', ones(nEdge,1), ...
    'Linked', false(nEdge-1,2), ...      %No linked edges
    'OpenEnd', [false, true]);   %By default right extends to inf
% Set step characteristics
this.InitialValue      = 0;
this.FinalValue        = 1;
this.StepTime          = 0;
this.RiseTime          = 5;
this.SettlingTime      = 10;
this.PercentRise       = 80;
this.PercentSettling   = 1;
this.PercentOvershoot  = 10;
this.PercentUndershoot = 1;
%Push characteristics to data
this.setStepCharacteristics;

if ~isempty(varargin)
   %Set any properties passed to constructor
   this.set(varargin{:})
end

%Create listener for when data object is deleted
L = [...
    handle.listener(this.Data,'ObjectBeingDestroyed',{@localDataDestroyed this});...
    handle.listener(this,'ObjectBeingDestroyed',{@localObjDestroyed this.Data})];
this.Listeners = L;
end

function localDataDestroyed(hSrc,hData,this)
delete(this)
end

function localObjDestroyed(hSrc,hData,Data)
delete(Data)
end
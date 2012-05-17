function h = bodegpm(varargin)
%BODEPM  Constructor for the Bode Phase Margin Constraint objects.

%   Author(s): A. Stothert
%   Revised: 
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:27 $

% Create class instance
h = plotconstr.bodegpm;
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
h.initElements(hParent);

%Set event manager
h.EventManager = ctrluis.eventmgr;

%Set the data property
h.Data = srorequirement.requirementdata;
% Initialize data properties 
h.Data.xCoords = 30;   % x=phase, y=gain as on Nichols plot
h.Data.xUnits  = 'deg';
h.Data.yCoords = 20;
h.Data.yUnits  = 'dB';
h.Data.Type    = 'both'; %Both gain and phase enabled

%Set unique ID for the constraint
h.setUID;

% Initialize display properties
h.xDisplayUnits  = 'deg';
h.yDisplayUnits  = 'dB';

% Set CSHTopic
h.HelpData.CSHTopic = 'bodegpconstraint';

% Install default BDF
h.defaultbdf;

if ~isempty(varargin)
   %Set any constructor called properties
   set(h,varargin{:})
end

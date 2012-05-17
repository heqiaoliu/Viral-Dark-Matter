function h = bodegain(varargin)
%BODEGAIN  Constructor for the Bode Gain Constraint objects.

%   Authors: N. Hickey, A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:19 $

% Create class instance
h = plotconstr.bodegain;
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
h.Data         = srorequirement.piecewisedata;

%Set unique ID for the constraint
h.setUID;

% Initialize properties
h.Orientation    = 'horizontal';
h.xCoords        = [1 10];
h.xUnits         = 'rad/sec';
h.yCoords        = [0 0];
h.yUnits         = 'dB';
h.Ts             = 0;
h.xDisplayUnits  = h.FrequencyUnits;
h.yDisplayUnits  = h.MagnitudeUnits;

% Set CSHTopic
h.HelpData.CSHTopic = 'bodegainconstraint';

% Install default BDF
h.defaultbdf;

if ~isempty(varargin)
   %Set any constructor called properties
   set(h,varargin{:})
end

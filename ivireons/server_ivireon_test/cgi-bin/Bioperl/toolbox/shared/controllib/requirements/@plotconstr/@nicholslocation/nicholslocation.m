function h = nicholslocation(varargin)
%NICHOLSLOCATION  Constructor for the Nichols location Constraint objects.

%   Authors: A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:32:17 $

% Create class instance
h = plotconstr.nicholslocation;
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
h.Orientation    = 'both';
h.xCoords        = [-180 -90];    %Default phase limits
h.xUnits         = 'deg';
h.yCoords        = [-10 -10];     %Default magnitude limits
h.yUnits         = 'dB';
h.Linked         = [];
h.xDisplayUnits  = h.PhaseUnits;
h.yDisplayUnits  = h.MagnitudeUnits;

% Set CSHTopic
h.HelpData.CSHTopic = 'nicholslocationconstraint';

% Install default BDF
h.defaultbdf;

if ~isempty(varargin)
   %Set any constructor called properties
   set(h,varargin{:})
end


function this = signaltracking(varargin) 
% SIGNALTRACKING  constructor for signal tracking object.
%
 
% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:04 $

this = srorequirement.signaltracking;

%Set object defaults
this.Name              = 'Signaltracking';
this.Description       = {'Track a user defined signal, '...
   'will attempt to minimise the sum squared error between source and '...
   'specified signal'};
this.isMinimized       = true;
this.Data              = srorequirement.requirementdata;
this.Source            = [];
this.isFrequencyDomain = false;
this.UID               = srorequirement.utGetUID;

if ~isempty(varargin)
   %Set any properties passed to constructor
   this.set(varargin{:})
end

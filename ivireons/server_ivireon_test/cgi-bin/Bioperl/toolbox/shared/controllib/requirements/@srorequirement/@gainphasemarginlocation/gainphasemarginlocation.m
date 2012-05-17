function this = gainphasemarginlocation(varargin)
% GAINPHASEMARGINLOCATION  gainphasemarginlocation constructor.
%
 
% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:56 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.gainphasemarginlocation;

%Set object defaults
this.Name              = 'Gainphasemargin';
this.Description       = {'Generic piecewise linear bound on the gain-phase point(s)',...
   'of a linear system.'};
this.Orientation       = 'both';
this.Data              = srorequirement.piecewisedata;
this.setData('xUnits','deg');
this.setData('yUnits','db');
this.Source            = [];
this.isFrequencyDomain = true;
this.UID               = srorequirement.utGetUID;

if ~isempty(varargin)
   %Set any properties passed to constructor
   this.set(varargin{:})
end

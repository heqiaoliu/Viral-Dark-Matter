function this = nicholslocation(varargin)
% NICHOLSLOCATION  Constructor for nicholslocation object
%
 
% Author(s): A. Stothert 31-May-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:21 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.nicholslocation;

%Set object defaults
this.Name              = 'Nichols location bound';
this.Description       = {'Generic piecewise linear bound on the nichols plot of a ',...
   'linear system.'};
this.Orientation       = 'both';
this.Data              = srorequirement.piecewisedata;
this.Source            = [];
this.isFrequencyDomain = true;
this.UID               = srorequirement.utGetUID;

%Set data properties
this.Data.setData('xUnits','deg');
this.Data.setData('yUnits','db')
this.Data.setData('xData',[-180 -90],'yData',[-10 -10],'weight',1)
this.Data.setData('type','lower')

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
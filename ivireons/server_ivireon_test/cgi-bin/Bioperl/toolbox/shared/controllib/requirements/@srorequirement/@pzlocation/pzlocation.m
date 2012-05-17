function this = pzlocation(varargin)
% PZLOCATION  Constructor for pzlocation object
%
 
% Author(s): A. Stothert 11-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:08 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.pzlocation;

%Set object defaults
this.Name              = 'Pole/zero location bound';
this.Description       = {'Generic piecewise linear bound on the poles/zeros of a ',...
   'linear system.'};
this.Orientation       = 'both';
this.Data              = srorequirement.piecewisedata;
this.Source            = [];
this.isFrequencyDomain = true;
this.UID               = srorequirement.utGetUID;

%Set data properties
this.setData('xUnits','abs','yUnits','abs');
this.setData('xData',[-1 -1],'yData',[-1 1],'weight',1);
this.setData('type', 'upper');

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
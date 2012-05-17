function this = bodegain(varargin)
% BODEGAIN  Constructor for bodegain object
%
 
% Author(s): A. Stothert 06-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:25 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.bodegain;

%Set object defaults
this.Name              = 'Bode magnitude bound';
this.Description       = {'Generic piecewise linear bound on the magnitude of a linear system.'};
this.Orientation       = 'horizontal';
this.Data              = srorequirement.piecewisedata;
this.Source            = [];
this.isFrequencyDomain = true;
this.NormalizeValue    = 1;
this.UID               = srorequirement.utGetUID;

%Set data properties
this.setData('xUnits','rad/sec');
this.setData('yUnits','db')
this.setData('xData',[1 10],'yData',[0 0],'weight',1);
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
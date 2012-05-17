function this = gainphasemargin(varargin) 
% GAINPHASEMARGIN  constructor for gainphasemargin object.
%
% Inputs:
%    varargin - property value pairs

% Author(s): A. Stothert 04-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:47 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.gainphasemargin;

%Set object defaults
this.Name              = 'Gain & phase margin bound';
this.Description       = {'Requirement on the gain or phase margin of a linear system.'};
this.Data              = srorequirement.requirementdata;
this.Source            = [];
this.isFrequencyDomain = true;
this.NormalizeValue    = 1;
this.UID               = srorequirement.utGetUID;

%Set Data properties
this.setData('type','both')
this.setData('xdata',30,'ydata',20,'weight',1);  %x=phase, y=gain, as on Nichols plot
this.setData('xUnits','deg')
this.setData('yUnits','dB')

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
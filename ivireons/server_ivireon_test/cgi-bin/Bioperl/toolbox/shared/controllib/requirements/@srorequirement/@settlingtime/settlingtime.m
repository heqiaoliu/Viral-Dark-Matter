function this = settlingtime(varargin)
% SETTLINGTIME  constructor for settling time object.
%
% Inputs:
%    varargin - property value pairs

% Author(s): A. Stothert 04-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:56 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.settlingtime;

%Set object defaults
this.Name              = 'Settling time bound';
this.Description       = {'Requirement on the approximate settling time of a linear system, '...
   'calculated by max(Re{poles(sys)} < sigma/T. Where T is the required ', ...
   'settling time and sigma the settling time threshold defined in cstprefs.tbxprefs .'};
this.Data              = srorequirement.requirementdata;
this.Source            = [];
this.isFrequencyDomain = true;
this.UID               = srorequirement.utGetUID;
this.FeedbackSign      = 1;
this.NormalizeValue    = 1;

%Set data properties
this.Data.setData('xUnits','sec');    %x=settling time, y = unused;
this.Data.setData('xdata',1,'ydata',0,'weight',1);
this.Data.setData('Type','upper');

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


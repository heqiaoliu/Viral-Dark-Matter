function this = dampingratio(varargin)
% NATURALFREQUENCY  Constructor for dampingratio object
%
% Inputs:
%    varargin - property value pairs
 
% Author(s): A. Stothert 31-May-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:35 $

srorequirement.utFreqLicenseCheck;

this = srorequirement.dampingratio;

%Set object defaults
this.Name              = 'Damping ratio bound';
this.Description       = {'Requirement on the damping ratio of a linear system.'};
this.Data              = srorequirement.requirementdata;
this.Source            = [];
this.isFrequencyDomain = true;
this.UID               = srorequirement.utGetUID;
this.NormalizeValue    = 1;

%Set data properties
this.Data.setData('xUnits','abs');     
this.Data.setData('xdata',1/sqrt(2),'ydata',0,'weight',1); %x=damping ratio, y = unused
this.Data.setData('Type','lower');

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
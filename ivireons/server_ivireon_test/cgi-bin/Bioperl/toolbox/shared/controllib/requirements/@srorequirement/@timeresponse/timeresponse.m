function this = timeresponse(varargin)
% TIMERESPONSE constructor for time response object.
%
 
% Author(s): A. Stothert 04-Apr-2005
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:27 $

this = srorequirement.timeresponse;

%Set object defaults
this.Name              = 'Time response bound';
this.Description       = {'Generic piecewise linear bound on a signal.'};
this.Orientation       = 'horizontal';
this.Data              = srorequirement.piecewisedata;
this.Source            = [];
this.isFrequencyDomain = false;
this.UID               = srorequirement.utGetUID;

%Set data properties
this.setData('xUnits','sec');
this.setData('yUnits','abs');
this.setData('xData', [0 10], 'yData', [1 1], 'weight', 1);
this.setData('type', 'lower');

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

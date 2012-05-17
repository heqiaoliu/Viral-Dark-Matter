function this=timestability(varargin)
% TIMESTABILITY  constructor for timestability object.
%
% Inputs:
%    varargin - property value pairs

% Author(s): A. Stothert 06-July-2006
% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:33 $

this = srorequirement.timestability;

%Set object defaults
this.Name              = 'Timestability';
this.Description       = {'Requirement on an estimation of the stability of a time domain signal.'};
this.Data              = srorequirement.requirementdata;
this.Data.setData('xUnits','abs');
this.Source            = [];
this.isFrequencyDomain = false;

%Presize x and y data
this.Data.setData('xdata',0,'ydata',0,'weight',1);

if ~isempty(varargin)
   %Set any properties passed to constructor
   this.set(varargin{:})
end
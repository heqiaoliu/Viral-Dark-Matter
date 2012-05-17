function this=maximumvalue(varargin)
% MAXIMUMVALUE  constructor for average value object.
%
% Inputs:
%    varargin - property value pairs

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:04 $

this = srorequirement.maximumvalue;

%Set object defaults
this.Name              = 'Maximumvalue';
this.Description       = {'Requirement on the maximum value of a signal.'};
this.Data              = srorequirement.requirementdata;
this.Data.setData('xUnits','abs');
this.Source            = [];
this.isFrequencyDomain = false;
this.UID               = srorequirement.utGetUID;

%Presize x and y data
this.Data.setData('xdata',0,'ydata',0,'weight',0);

if ~isempty(varargin)
   %Set any properties passed to constructor
   this.set(varargin{:})
end

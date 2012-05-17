function getmargin(this, MarginType, cd, ArrayIndex, w)
%  GETMARGIN  Update all data (@chardata) of the datavie (h = @dataview)
%  using the response source (this = @respsource).

%  Author(s): John Glass
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:21:22 $
if nargin<4
    ArrayIndex = 1;
end

% Get stability margin data
s = this.Cache(ArrayIndex).Margins;
if isempty(s)
   % Recompute margins
   D = getModelData(this,ArrayIndex);
   % NOTE: May error out for complex models
   s = allmargin(D,w);
   this.Cache(ArrayIndex).Margins = s;
end
    
% Update the data.
if strcmp(MarginType,'min')
   % Get min (worst-case) stability margins
   [cd.GainMargin,cd.PhaseMargin,cd.DelayMargin,...
      cd.GMFrequency,cd.PMFrequency] = utGetMinMargins(s);
   cd.DMFrequency = cd.PMFrequency;
else
   cd.GMFrequency = s.GMFrequency;
   cd.GainMargin  = s.GainMargin;
   cd.PMFrequency = s.PMFrequency;
   cd.PhaseMargin = s.PhaseMargin;
   cd.DMFrequency = s.DMFrequency;
   cd.DelayMargin = s.DelayMargin;
end

cd.Stable = s.Stable;      
% Store the sample rate in the characteristic data object so that the
% proper units will be displayed in the tip function for the
% phase margin characteristic points.
cd.Ts = getTs(this.Model);

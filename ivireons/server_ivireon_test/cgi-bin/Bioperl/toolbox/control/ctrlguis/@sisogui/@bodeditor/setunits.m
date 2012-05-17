function setunits(this,Type,NewValue)
% Sets editor units.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:42:23 $
Axes = this.Axes;
switch Type
   case 'FrequencyUnits'
      Axes.XUnit = NewValue;
   case 'MagnitudeUnits'
      % RE: Not affecting Nichols editor
      % When going to dB with yscale = log, set Yscale='linear' to prevent
      % Negative Data Ignored warnings
      % REVISIT: condense lines below
      YScale = Axes.YScale;
      YUnits = Axes.YUnits;
      if strcmpi(NewValue, 'dB')
         YScale{1} = 'linear';
         Axes.YScale = YScale;
      end
      YUnits{1} = NewValue;
      Axes.YUnits = YUnits;
   case 'PhaseUnits'
      YUnits = Axes.YUnits;
      YUnits{2} = NewValue;
      Axes.YUnits = YUnits;
end
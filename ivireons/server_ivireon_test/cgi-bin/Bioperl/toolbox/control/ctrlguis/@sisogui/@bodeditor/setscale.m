function setunits(this,Type,NewValue)
% Sets editor scale

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:42:22 $
Axes = this.Axes;
switch Type
   case 'FrequencyScale'
      Axes.XScale = NewValue;
   case 'MagnitudeScale'
      YScale = Axes.YScale;
      YScale{1} = NewValue;
      Axes.YScale = YScale;
end

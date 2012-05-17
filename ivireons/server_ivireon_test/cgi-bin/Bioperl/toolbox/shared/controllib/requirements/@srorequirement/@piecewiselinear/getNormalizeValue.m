function nVal = getNormalizeValue(this)
% GETNORMALIZEVALUE  Method to compute a normalization value for a
% requirement.
%
 
% Author(s): A. Stothert 06-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:53 $

%Make sure we have a good value for normalization
nScale = this.NormalizeValue;
if ~isfinite(nScale) || (nScale == 0)
   [xExtent,yExtent] = this.Data.getExtent;
   nScale = sqrt( (xExtent(2)-xExtent(1))^2 + ...
      (yExtent(2)-yExtent(1))^2); 
end

%Compute normalization based on requirement coordinates
Y = this.Data.getData('yData');
if strcmpi(this.Data.getData('yUnits'),'db')
   Y = unitconv(Y,'db','abs');
end
X = this.Data.getData('xData');
if strcmpi(this.Data.getData('xUnits'),'db')   
   X = unitconv(X,'db','abs');   
end
%Based on orientation use either xdata or ydata or both
switch this.Orientation
   case 'horizontal'
      OpenEnd = this.Data.getData('OpenEnd');
      nVal = abs(mean(Y,2));
      nVal = abs(unitconv(nVal,'abs',this.Data.getData('yUnits')));
      if OpenEnd(1), nVal = [nVal(1); nVal]; end
      if OpenEnd(2), nVal = [nVal; nVal(end)]; end
   case 'vertical'
      OpenEnd = this.Data.getData('OpenEnd');
      nVal = abs(mean(X,2));
      nVal = abs(unitconv(nVal,'abs',this.Data.getData('xUnits')));
      if OpenEnd(1), nVal = [nVal(1); nVal]; end
      if OpenEnd(2), nVal = [nVal; nVal(end)]; end
   case 'both'
      nVal = abs(mean(Y,2))+abs(mean(X,2));
      nVal = [nVal(1); nVal; nVal(end)];
end
nVal = nVal + 0.01*nScale;

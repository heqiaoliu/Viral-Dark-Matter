function nVal = getNormalizeValue(this)
% GETNORMALIZEVALUE  Method to compute a normalization value for a
% requirement.
%

% Author(s): A. Stothert 16-Jan-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:37:11 $

%Make sure we have a good value for normalization
nScale = this.NormalizeValue;
if ~isfinite(nScale) || (nScale == 0)
   [xExtent,yExtent] = this.Data.getExtent;
   nScale = sqrt( (xExtent(2)-xExtent(1))^2 + ...
      (yExtent(2)-yExtent(1))^2); 
end

%Compute normalization based on requirement coordinates
YAll = this.Data.getData('yData');
OpenEnd = this.Data.getData('OpenEnd');
Y{1} = YAll(1:2,:);  %Upper bound
Y{2} = YAll(3:5,:);  %Lower bound

nVal = [];
for ct=1:2
    nV = abs(mean(Y{ct},2));
    nV = abs(unitconv(nV,'abs',this.Data.getData('yUnits')));
    if OpenEnd(1), nV = [nV(1); nV]; end
    if OpenEnd(2), nV = [nV; nV(end)]; end
    nVal = [nVal; nV];
end

nVal = nVal + 0.01*nScale;

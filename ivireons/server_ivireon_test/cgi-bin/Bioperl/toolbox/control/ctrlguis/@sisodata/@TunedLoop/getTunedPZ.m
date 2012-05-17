function [TunedZeros,TunedPoles] = getTunedPZ(this)
% Get tunable open-loop poles and zeros (dynamics of the 
% tuned factors)

%   Copyright 1986-2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2006/11/17 13:24:24 $
TunedZeros = zeros(0,1);
TunedPoles = zeros(0,1);
TunedFactors = this.TunedFactors;
for ct = 1:length(TunedFactors)
   [Z,P] = getPZ(TunedFactors(ct),'Tuned');
   TunedZeros = [TunedZeros ; Z];
   TunedPoles = [TunedPoles ; P];
end

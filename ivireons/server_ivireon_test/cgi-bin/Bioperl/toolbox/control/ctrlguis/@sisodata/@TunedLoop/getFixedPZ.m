function [FixedZeros,FixedPoles] = getFixedPZ(this,idx)
%getFixedPZ  Get poles and zeros from the calculated open-loop that are not
% graphically tunable. These are the poles of the TunedLFT of the
% TunedLoop which can be computed and the fixed poles of the TunedFactors.

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2010/03/26 17:22:01 $


if nargin == 1
    % Return Nominal value if no idx is specified
    idx = this.Nominal;
end

FixedZeros = zeros(0,1);
FixedPoles = zeros(0,1);

% Append poles and zeros for the fixed part of TunedFactors (series blocks)
TunedFactors = this.TunedFactors;
for ct = 1:length(TunedFactors)
    FixedDynamics = TunedFactors(ct).FixedDynamics;
    if ~isempty(FixedDynamics)
        FixedZeros = [FixedZeros; FixedDynamics.z{1}]; %#ok<AGROW>
        FixedPoles = [FixedPoles; FixedDynamics.p{1}]; %#ok<AGROW>
    end
end

if ~hasDelay(this) && ~hasFRD(this)
    % Only get TunedLFT poles/zeros if they can be computed
    % Append poles and zeros for the TunedLFT
    G = this.getTunedLFT('zpk',idx);
    
    FixedZeros = [FixedZeros; G.z{1}];
    FixedPoles = [FixedPoles; G.p{1}];
end

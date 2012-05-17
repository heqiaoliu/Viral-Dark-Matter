function initialize(eqObj)
%INITIALIZE  Initialize equalizer object

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/06/10 14:24:08 $

N = eqObj.nWeights;
Lw = sum(N); % Weights vector length
Ls = Lw;  % WeightInputs vector length
eqObj.WeightInputsPrivate = zeros(1, Ls);
if length(eqObj.WeightsPrivate)~=Lw || ~eqObj.AdaptAlg.BlindMode
    eqObj.WeightsPrivate = zeros(1, Lw);
end

% Initialize reference sample.
[~, idx] = min(real(abs(eqObj.sigConst).^2));
eqObj.dref = eqObj.sigConst(idx);

eqObj.NumSamplesProcessed = 0;

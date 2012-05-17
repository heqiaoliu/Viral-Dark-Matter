function D = ss(this,idxM)
% SS Computes ss of tuned loop

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/03/26 17:22:12 $

if nargin == 1
    idxM = this.Nominal;
end

if hasFRD(this)
    ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
        'The state-space model can not be computed for FRD systems.')
else
    if isempty(this.ModelData{idxM})
        % Recompute
        % Series portion of TunedLoop
        TunedFactors = this.TunedFactors;
        
        % LFT portion of TunedLoop
        D = getTunedLFT(this,[],idxM);
        
        for ct = 1:length(TunedFactors)
            D = D * ss(TunedFactors(ct));
        end
        this.ModelData{idxM} = D;
    else
        D = this.ModelData{idxM};
    end
end
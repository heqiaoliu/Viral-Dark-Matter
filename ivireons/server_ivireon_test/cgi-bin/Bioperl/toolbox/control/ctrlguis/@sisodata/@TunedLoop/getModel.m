function D = getModel(this,idx)
% getModel Computes ssdata or frddata of tuned loop

%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2.2.1 $  $Date: 2010/07/01 20:42:23 $

if nargin == 1;
    if this.Feedback
    idx = this.Nominal;
    else
        % Tuned loop is a compensator for closed loop editor.
        idx = 1;
    end
end

if isempty(this.ModelData{idx})
    % Recompute
    % Series portion of TunedLoop
    TunedFactors = this.TunedFactors;
    
    % LFT portion of TunedLoop
    D = getTunedLFT(this,[],idx);
    
    isFRD =  isa(D,'ltipack.frddata');
    
    for ct = 1:length(TunedFactors)
        if isFRD
            D = D * frd(zpk(TunedFactors(ct)),D.Frequency,D.FreqUnits);
        else
            D = D * ss(TunedFactors(ct));
        end
    end
    this.ModelData{idx} = D;
else
    D = this.ModelData{idx};
end



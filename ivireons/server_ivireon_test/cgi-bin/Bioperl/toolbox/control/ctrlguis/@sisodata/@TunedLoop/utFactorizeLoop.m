function P = utFactorizeLoop(this,C,idxM)
% P = utFactorizeLoop(L,C) computes the "plant" model P for the Open-Loop 
% such that L = P*C. This is used in automated tuning algorithms for
% designing the compensator C for the open-loop. 
%
% For example consider the open loop defined by
% L = C1*C2*C3*TunedLFT where TunedLFT defines the compensators that do no
% appear in series with the loop.
% P = utFactorizeLoop(this,C2) returns P such that
% L = C2*P where P = C1*C3*TunedLFT
%
%
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2010/03/26 17:22:13 $

if nargin < 3
    idxM = this.Nominal;
end

if this.Feedback
    % LFT portion of TunedLoop includes compensators
    % that do not appear in series in the loop
    P = getTunedLFT(this,[],idxM);
    
    % Compensators that appear in series with the open-loop
    TunedFactors = this.TunedFactors;
    
    isFRD =  isa(P,'ltipack.frddata');
    
    % Incorporate compensators that appear in series in the loop
    % except that specified by C
    for ct = 1:length(TunedFactors)
        if ~isequal(C,TunedFactors(ct))
            if isFRD
                P = P * frd(zpk(TunedFactors(ct)),P.Frequency,P.FreqUnits);
            else
                P = P * ss(TunedFactors(ct));
            end
        end
    end

else 
    ctrlMsgUtils.error('Control:compDesignTask:utFactorizeLoop')
end
function D = getOpenLoop(this,TunedZPK,idxM)
%getOpenLoop Computes normalized open-loop @zpkdata, @ssdata, or @frdmodel model
% This function is used by the graphical editors to compute the open loop
% displayed.
% Note: The Open-Loop is defined as positive feedback because the loop is
% defined by cutting a signal(i.e. all signs are lumped in the effective
% plant). However because most users are used to designing with negative
% feedback on such plots as root locus this function pulls out a negative
% sign so that plots are presented as negative feedback.

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2010/03/26 17:22:03 $

if nargin < 3
    idxM = this.Nominal;
end

% Series portion of TunedLoop
TunedFactors = this.TunedFactors;

if nargin > 1 && ~isempty(TunedZPK)
    idx = find(TunedZPK == TunedFactors);
else
    idx = 0;
end

% LFT portion of TunedLoop
if hasDelay(this) || hasFRD(this)
    D = getTunedLFT(this,[],idxM);
else
    % REVISIT
    %     D = getTunedLFT(this,'zpk');
    D = getTunedLFT(this,[],idxM);
end
if hasFRD(this)
    for ct = 1:length(TunedFactors)
        if ct == idx
            D = D * frd(zpk(TunedFactors(ct),'normalized'),D.Frequency,D.FreqUnits);
        else
            D = D * frd(zpk(TunedFactors(ct)),D.Frequency,D.FreqUnits);
        end
    end
else
    for ct = 1:length(TunedFactors)
        if ct == idx
            % REVISIT (cast to SS and ZPK)
            D = D * ss(TunedFactors(ct),'normalized');
        else
            D = D * ss(TunedFactors(ct));
        end
    end
end

% Treat loop as negative feedback for presentation purposes
D = -D;
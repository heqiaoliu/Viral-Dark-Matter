function D = getTunedLFT(this,flag,idx)
%getTunedLFT Used to update the cache of the TunedLFT
% 
% D = getTunedLFT(this) returns the ssdata of the TunedLFT
% D = getTunedLFT(this,'zpk') returns the zpkdata of the TunedLoop

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.1.8.6 $ $Date: 2010/03/26 17:22:04 $

if nargin < 3
    idx = this.Nominal;
end

if (nargin == 2) && (hasDelay(this) || hasFRD(this))
    ctrlMsgUtils.error('Controllib:general:UnexpectedError', ...
        'The Poles and Zeros can not be computed for time-delay or frequency response data systems.')
end

if hasFRD(this)
    % Compute FRD Data
    if isempty(this.TunedLFT.FRDData{idx})
        % Need to recompute
        this.TunedLFT.FRDData{idx} = LocalRecomputeFRD(this,idx);
    end
    D = this.TunedLFT.FRDData{idx};
else
    SSData = this.TunedLFTSSData{idx};
    if isempty(SSData)
        % Need to recompute
        SSData = LocalRecompute(this,idx);
        this.TunedLFTSSData{idx}=SSData;
    end
    
    % If flag is zpk return zpkdata otherwise ssdata
    if (nargin >= 2) && strcmp(flag,'zpk')
        if isempty(this.TunedLFT.ZPKData{idx})
            sw = warning('off','Control:transformation:StateSpaceScaling'); [lw,lwid] = lastwarn;
            this.TunedLFT.ZPKData{idx} = zpk(SSData);
            warning(sw); lastwarn(lw,lwid);
        end
        D = this.TunedLFT.ZPKData{idx};
    else
        D = SSData;
    
    end
end
end


function D = LocalRecomputeFRD(this,idx)
Blocks = this.TunedLFT.Blocks;
if isempty(Blocks)
    D = this.TunedLFT.IC(idx);
else
    freqs = this.TunedLFT.IC(idx).Frequency;
    units = this.TunedLFT.IC(idx).FreqUnits;
    for ct=length(Blocks):-1:1
        C(ct,1) = frd(zpk(Blocks(ct)),freqs,units);
    end
    D = utSISOLFT(this.TunedLFT.IC(idx),C);
end
end

function D = LocalRecompute(this,idx)

TunedLFT = this.TunedLFT;
Blocks = TunedLFT.Blocks;
if isempty(Blocks)
    D = TunedLFT.IC(idx);
else
    for ct=length(Blocks):-1:1
        C(ct,1) = ss(Blocks(ct));
    end
    D = utSISOLFT(TunedLFT.IC(idx),C);
end


end

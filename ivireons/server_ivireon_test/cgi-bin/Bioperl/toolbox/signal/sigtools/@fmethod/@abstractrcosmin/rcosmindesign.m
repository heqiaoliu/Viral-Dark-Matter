function b = rcosmindesign(this, hspecs, shape, hd)
%RCOSMINDESIGN Design the filter

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:34 $

% Get design arguments
args = designargs(this, hspecs);
Astop = args{1};
beta = args{2};
sps = args{3};

% Design an raised cosine filter until the Astop requirement met
N = estimateOrd(beta,Astop,sps);
if N > 10000
    notConverging = true;
else
    hd.SamplesPerSymbol = sps;
    hd.RolloffFactor = beta;
    hd.FilterOrder = N;
    
    % Try design
    hf = window(hd);
    [hf,notConverging] = iterateOrd(hd,hf,Astop,sps);
end

if notConverging,
    error(generatemsgid('notConverging'), ['Design did not converge. '...
        'Consider reducing the stop band attenuation.']);
else
    b = {hf.Numerator};
end

%--------------------------------------------------------------------------
function [hf,notConverging] = iterateOrd(hd,hf,Astop,sps)

notConverging = false;
minfo = measureinfo(hd);
measuredAstop = getAstop(hd, hf, minfo.Fstop);
if measuredAstop < Astop,
    count = 0;
    maxCount = 100;
    Ast = measuredAstop;
    % First look for the minimum order by increasing the order in large steps
    largeStep = 6*sps;
    while Ast < Astop && count < maxCount,
        hd.FilterOrder = hd.FilterOrder + largeStep;
        hf = window(hd);
        measuredAstop = getAstop(hd, hf, minfo.Fstop);
        newAst = measuredAstop;
        Ast = newAst;
        count = count + 1;
    end
    if count == maxCount,
        % We reached the end of the search region and did not meat criteria
        notConverging = true;
        return
    end
    % Then look for the minimum order by decreasing the order in small steps
    while Ast > Astop,
        hfprev = copy(hf);
        hd.FilterOrder = hd.FilterOrder - 2*sps; % Decrease order to next 
                                                 % even multiple of sps
        hf = window(hd);
        measuredAstop = getAstop(hd, hf, minfo.Fstop);
        newAst = measuredAstop;
        Ast = newAst;
    end
    hf = hfprev;
end

%--------------------------------------------------------------------------
function Astop = getAstop(hd, hf, Fstop)
% Calculate Astop (stop band attenuation) given Fstop and Fs.  This code is
% copied/modified from measureattenuation in abstractmeas, which is called
% in measure method a feature of Filter Design Toolbox.

% calculate max of response from w_lo to w_hi
if hd.NormalizedFrequency
    Fs = 2;
else
    Fs = this.Fs;
end

N = 2^12;

% Calculate the frequency response in the stopband.
h = abs(freqz(hf, linspace(Fstop, Fs/2, N), Fs));

% The attenuation is defined as the distance between the nominal gain
% and the maximum rippple in the stopband.
ngain = nominalgain(hf);
if isempty(ngain)
    ngain = 1;
end
Astop = db(ngain)-db(max(h));

%--------------------------------------------------------------------------
function Nmin = estimateOrd(beta,Astop,sps)
% Estimate the minimum order needed 

if beta < 0.1
    a = 24.37;
    b = 0.05482;
elseif beta < 0.25
    a = 9.683;
    b = 0.05534;
elseif beta < 0.5
    a = 4.597;
    b = 0.05607;
elseif beta < 0.75
    a = 2.883;
    b = 0.0567;
else
    a = 2.059;
    b = 0.05715;
end

% The filter order must be an even multiple of sps
Nmin = floor(a*exp(b*Astop));
Nmin = Nmin + (sps-mod(Nmin,sps));
if mod(Nmin/sps,2)
    Nmin = Nmin + sps;
end

% [EOF]

function [filter, mcode] = defaultfilter(this)
%DEFAULTFILTER  Designs a default filter and then converts to a
%               filter object.

%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:23:03 $

% % Extract specs from the input data structure.
% Wp = evaluatevars(design.freq.lp.passStop{1});
% Ws = evaluatevars(design.freq.lp.passStop{2});
% Fs = evaluatevars(design.freq.lp.fs);
% Rp = evaluatevars(design.mag.lp.passStop{1});
% Rs = evaluatevars(design.mag.lp.passStop{2});
%
% % Default designed filter coeffs.
% [n,fo,mo,w]=remezord([Wp Ws],[1 0],...
%     [(10^(0.05.*Rp)-1)/(10^(0.05.*Rp)+1) 10^(-0.05*Rs)],44100);
% b = remez(n,fo,mo,w);

b = [        -0.000919098208468256
    -0.0027176960265955
    -0.00248695275983231
    0.00366143838350709
    0.0136509252306624
    0.0173511659010933
    0.00766530619042168
    -0.0065547188696424
    -0.00769678403706536
    0.00610545942139436
    0.0138739157486354
    0.00035086172829091
    -0.0169089254366905
    -0.00890564274915868
    0.0174411295008549
    0.0207450445276099
    -0.0122964942519403
    -0.0342408659095784
    -0.0010345296055724
    0.0477903055208015
    0.027363037914848
    -0.0593795188310466
    -0.0823070259292291
    0.0671869094328705
    0.310015177090251
    0.430047880343517
    0.310015177090251
    0.0671869094328705
    -0.0823070259292291
    -0.0593795188310466
    0.027363037914848
    0.0477903055208015
    -0.0010345296055724
    -0.0342408659095784
    -0.0122964942519403
    0.0207450445276099
    0.0174411295008549
    -0.00890564274915868
    -0.0169089254366905
    0.00035086172829091
    0.0138739157486354
    0.00610545942139436
    -0.00769678403706536
    -0.0065547188696424
    0.00766530619042168
    0.0173511659010933
    0.0136509252306624
    0.00366143838350709
    -0.00248695275983231
    -0.0027176960265955
    -0.000919098208468256].';

filter = dfilt.dffir(b);

% Add the maskinfo to the filter
m.fs = 48000;
m.frequnits = 'Hz';
m.response = 'magresp';
m.magunits = 'db';
m.bands{1}.frequency  = [0 9600];
m.bands{1}.filtertype = 'lowpass';
m.bands{1}.magfcn     = 'pass';
m.bands{1}.amplitude  = 1;
m.bands{1}.magunits   = 'dB';
m.bands{1}.astop      = -130;

m.bands{2}.frequency  = [12000 24000];
m.bands{2}.filtertype = 'lowpass';
m.bands{2}.freqfcn    = 'wstop';
m.bands{2}.magfcn     = 'stop';
m.bands{2}.amplitude  = 80;
m.bands{2}.magunits   = 'dB';

p = schema.prop(filter, 'MaskInfo', 'MATLAB array');
set(p, 'Visible', 'Off');
set(filter, 'MaskInfo', m);

if nargout > 1,
    mcode = { ...
        '% Equiripple FIR Lowpass filter designed using the FIRPM function.', ...
        '', ...
        '% All frequency values are in Hz.', ...
        'Fs = 48000;  % Sampling Frequency', ...
        '', ...
        'Fpass = 9600;            % Passband Frequency', ...
        'Fstop = 12000;           % Stopband Frequency', ...
        'Dpass = 0.057501127785;  % Passband Ripple', ...
        'Dstop = 0.0001;          % Stopband Attenuation', ...
        'dens  = 16;              % Density Factor', ...
        '', ...
        '% Calculate the order from the parameters using FIRPMORD.', ...
        '[N, Fo, Ao, W] = firpmord([Fpass, Fstop]/(Fs/2), [1 0], [Dpass, Dstop]);', ...
        '', ...
        '% Calculate the coefficients using the FIRPM function.', ...
        'b  = firpm(N, Fo, Ao, W, {dens});', ...
        'Hd = dfilt.dffir(b);'};
end
% [EOF]

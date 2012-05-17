function status = iskaisereqripminspecmet(this,hfilter,hspecs)
%ISKAISEREQRIPMINSPECMET Test that the spec is met in Kaiser and
%equirriple min order designs.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/04 23:24:16 $

status = false;

[stopbands, passbands, Astop, Apass] = getfbandstomeas(this,hspecs);


%Measure attenuation at the stopbands
N = 2^12;
for idx = 1:size(stopbands,1)
    Fstart = stopbands(idx,1);
    Fend = stopbands(idx,2);
    %Get fft at desired bands, we always get normalized frequency values in
    %hspecs so set Fs parameter to 2
    h = abs(freqz(hfilter, linspace(Fstart, Fend, N), 2));
    
    % Measure attenuation defined as the distance between the nominal
    % gain(0 dB in our case) and the maximum rippple in the stopband.
    ngain = 1;
    measAstop = db(ngain)-db(max(h));
    if (measAstop <= Astop(idx))
        return %return with status = false
    end
end

%Measure ripple at the passbands
N = 2^10;
for idx = 1:size(passbands,1)
    Fstart = passbands(idx,1);
    Fend = passbands(idx,2);
    %Get fft at desired bands, we always get normalized frequency values in
    %hspecs so set Fs parameter to 2    
    h = abs(freqz(hfilter, linspace(Fstart, Fend, N), 2));

    % The ripple is defined as the amplitude (dB) variation between the two
    % specified frequency points.
    measApass = db(max(h))-db(min(h));
    if (measApass >= Apass(idx))
        return %return with status = false
    end
end

%If we made it up to here then it means SPECS are met
status = true;
    

% [EOF]
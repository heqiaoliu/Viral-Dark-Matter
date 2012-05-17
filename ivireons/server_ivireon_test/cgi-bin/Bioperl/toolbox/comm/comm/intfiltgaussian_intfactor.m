function [KI, N] = intfiltgaussian_intfactor(Ts, fc, N, fcStr)
% INTFILTGAUSSIAN_INTFACTOR  Support function used by @channel package for
% computing interpolation factors.

%   Copyright 1996-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/27 22:16:55 $

% Ts: Sampling period
% fc: Cutoff frequency
% N:  Oversampling factor (recomputed for output)
% fcStr: Name (string) of cutoff frequency
% KI: 3-element vector, [Ks Ks1 Ks2]
%     Ks: Overall interpolation factor
%     Ks1: Polyphase filter interpolation factor
%     Ks2: Linear interpolation factor

if fc>0
    % Ensures that polyphase filter interpolation factor is in range 10-20.
    Ks1min = 10;
    Ks1max = 20;
    d = N*Ts*fc;
    if d<=1
        Ks = floor(1/d);
        if Ks<=Ks1max
            Ks1 = Ks;
            Ks2 = 1;
        else
            Ks1 = Ks1min;
            Ks2 = round(Ks/Ks1);
            Ks = Ks1 * Ks2;
        end
        KI = [Ks Ks1 Ks2];
        N = 1/(KI(1)*Ts*fc);
    else
        error('comm:intfiltgaussian_intfactor:InterpolationFactor', ...
        [fcStr ' must be less than 1/(' ...
            num2str(N) '*Ts), where Ts is the input sample period.'])
    end
else % fc==0
    KI = [1 1 1];
    N = NaN;
end

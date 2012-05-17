function filt = designFIRFilter(tssig,N)
% Design filter to filter a frequency in sinestream in FRESTIMATE with
% sample time tssig and samples per period N.
%

%  Author(s): Erman Korkut
%  Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2009/05/23 08:19:44 $

% Design a derivative x bandpass x low pass filter
%-------------------------------------------------
% ratio of the bandwidth of bandpass filter against
% cutoff (cutoff)
BWforbp = 0.2;
normf = 2/N; % Normalized frequency in terms of x pi radians per sample
bwbp = normf*BWforbp/2;
% Find the extends of the sinc for each filter:
% These extend will determine the filter orders,
% (2*Nextend_lp+1)+1 +(2*Nextend_bp+1)+1 + 1(deriv) should add up to N.
Nextend = floor((N-3)/2);
Nextend_lp = floor(Nextend/4); % save 1/4th available for low pass
Nextend_bp = Nextend-Nextend_lp;
% First order derivative filter
derivfilt = [1 -1];
% Low pass with cutoff at 2*w_input
lpfilt = 2*normf*LocalSinc(2*normf*(-Nextend_lp:Nextend_lp));
% Band pass with center w_input extending +- 10 percent wide pass range
bpfilt = 2*cos((-Nextend_bp:Nextend_bp).*pi*normf).*(bwbp*LocalSinc(bwbp*(-Nextend_bp:Nextend_bp)));
% Multiply bandpass, lowpass and derivative
combinedfilt = conv(derivfilt,conv(bpfilt,lpfilt));
% Scale the gain to 1 at normf
filt = combinedfilt./abs(freqresp(tf(combinedfilt,1,tssig),2*pi/tssig/N));

function y = LocalSinc(x)
i=find(x==0);                                                              
x(i)= 1;
y = sin(pi*x)./(pi*x);                                                     
y(i) = 1;   
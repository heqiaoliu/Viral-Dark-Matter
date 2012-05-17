function [xhat, yhat] = rceps(x)
%RCEPS Real cepstrum.
%   RCEPS(X) returns the real cepstrum of the real sequence X.
%
%   [XHAT, YHAT] = RCEPS(X) returns both the real cepstrum XHAT and 
%   YHAT which is a unique minimum-phase sequence that has the same real 
%   cepstrum as X.
%
%   EXAMPLE: Show that YHAT is a unique minimum-phase sequence that has the
%            % same real cepstrum as X.
%            y = [4 1 5]; % Non-minimum phase sequence
%            [xhat,yhat] = rceps(y);
%            xhat2= rceps(yhat);
%            [xhat' xhat2']
%
%   See also CCEPS, ICCEPS, HILBERT, FFT.

%   Author(s): L. Shure, 6-9-88
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.4 $  $Date: 2008/12/04 23:20:48 $

%   References: 
%     [1] A.V. Oppenheim and R.W. Schafer, Digital Signal 
%         Processing, Prentice-Hall, 1975.
%     [2] Programs for Digital Signal Processing, IEEE Press,
%         John Wiley & Sons, 1979, algorithm 7.2.

error(nargchk(1,1,nargin,'struct'));

% Check for valid input signal
[errid,errmsg] = chkinput(x);
if ~isempty(errmsg), error(errid,errmsg); end

n = length(x);
fftxabs = abs(fft(x));
if any(fftxabs == 0)
    error(generatemsgid('ZeroInFFT'),...
        'The Fourier transform of X contains zeros. Therefore, the real cepstrum of X does not exist.');
end
xhat = real(ifft(log(fftxabs)));
if nargout > 1
   odd = fix(rem(n,2));
   wn = [1; 2*ones((n+odd)/2-1,1) ; ones(1-rem(n,2),1); zeros((n+odd)/2-1,1)];
   yhat = zeros(size(x));
   yhat(:) = real(ifft(exp(fft(wn.*xhat(:)))));
end


%--------------------------------------------------------------------------
function [errid,errmsg] = chkinput(x)
% Check for valid input signal

errid = '';
errmsg = '';

if isempty(x) || issparse(x) || ~isreal(x),
    errid = generatemsgid('invalidInput');
    errmsg = 'The input signal X must be real.';
    return;
end


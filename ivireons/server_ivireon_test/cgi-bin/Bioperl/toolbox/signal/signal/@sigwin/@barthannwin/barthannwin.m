function hWIN = barthannwin(n)
%BARTHANNWIN Modified Bartlett-Hanning window. 
%   H = SIGWIN.BARTHANNWIN(N) returns an N-point Modified Bartlett-Hanning
%   window object H.
%
%   EXAMPLE:
%      N = 64; 
%      h = sigwin.barthannwin(N);
%      w = generate(h);
%      stem(w); title('64-point Modified Bartlett-Hanning window');
%
%   See also SIGWIN.

%   Reference:
%     [1] Yeong Ho Ha and John A. Pearce, A New Window and Comparison
%         to Standard Windows, IEEE Transactions on Acoustics, Speech,
%         and Signal Processing, Vol. 37, No. 2, February 1999

%   Author(s): V.Pellissier
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2009/05/23 08:15:34 $

hWIN = sigwin.barthannwin;
hWIN.Name = 'Bartlett-Hanning';
if nargin>0,
    hWIN.length = n;
end

% [EOF]

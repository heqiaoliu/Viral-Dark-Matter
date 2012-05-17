function kmult = rlocmult(Zero,Pole,Gain,a,b,c,Ts)
%RLOCMULT  Finds gain values for which locus branches cross.
%
%   KMULT = RLOCMULT(Zero,Pole,Gain)
%   
%   KMULT = RLOCMULT(Zero,Pole,Gain,A,B,C,TS) uses the 
%   state-space data to compute the crossing points.
%
%   See also ROCUS, SISOTOOL.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2006/11/17 13:26:09 $

% Algorithm: Find positive gains that produce multiple roots by solving
% D'(s)*N(s)-D(s)*N'(s)=0 and looking for roots such that D(s)/N(s)<0.
% Note that D'(s)*N(s)-D(s)*N'(s)=0 is equivalent to 
%    dH/ds = c*(sI-A)^(-2)*b = 0   where H(s) = N(s)/D(s)

if nargin>3
    % State-space model supplied: use it to compute candidate crossings
    na = size(a,1);
    MultRoots = sszero(...
       [a eye(na);zeros(na) a],[zeros(na,1);b],[c zeros(1,na)],0,[],Ts);
else
    % Compute numerator and denominator
    Num = poly(Zero);  % leave gain out (normalization)
    Den = poly(Pole);
    % Find roots of D'(s)*N(s)-D(s)*N'(s)=0
    DpN = conv(polyder(Den),Num);
    DNp = conv(Den,polyder(Num));
    gap = length(DpN)-length(DNp);
    MultRoots = roots([zeros(1,-gap),DpN]-[zeros(1,gap),DNp]);
end
    
% Evaluate H(s) at sM = MULTROOTS
h = zpkfresp(Zero,Pole,Gain,MultRoots,false);

% Compute candidate gains k=-1/H(sM), discarding mult. poles at k=0 or k=Inf
kmult = -1./h(h~=0 & isfinite(h)).';

% Keep only real positive gains
kmult = abs(kmult(:,abs(imag(kmult))<=1e-1*abs(kmult) & real(kmult)>0));

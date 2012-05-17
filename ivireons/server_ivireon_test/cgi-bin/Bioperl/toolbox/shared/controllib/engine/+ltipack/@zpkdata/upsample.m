function D = upsample(D,L)
%Upsample a discrete ZPK model by a factor of L.

%   Author: Murad Abu-Khalaf, April 30, 2008
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:34:03 $


% Compute delays at new sampling time
D.Delay.Input = D.Delay.Input * L;
D.Delay.Output = D.Delay.Output * L;
D.Delay.IO = D.Delay.IO * L;

% Compute the Lth-roots of 1 and -1.
s     = exp((2i*pi/L)*(1:((L-1)/2))');
if mod(L,2)==0
    Lth_p = [1; -1; s; conj(s)];
    s = exp(pi/L*1i)*[1;  s];
    Lth_n = [s; conj(s)];
else
    Lth_p = [1; s; conj(s)];
    Lth_n = -Lth_p;
end
 
% Loop over I/O pairs
for ct=1:numel(D.k)
    % Resample
    D.z{ct} = localExpandRoots(D.z{ct},Lth_p,Lth_n);
    D.p{ct} = localExpandRoots(D.p{ct},Lth_p,Lth_n);
end

% Update the new sampling time.
D.Ts = D.Ts/L;


%----------------------- Local Functions ----------------------------

function vec_up = localExpandRoots(r,real_pos,real_neg)
% Compute new Poles/Zeros following zero padding such that H(z) --> H(z^L).
% Symmetry about the real axis is preserved.
L = length(real_pos);
n       = length(r);
vec_up  = zeros(n*L,1);

iup = 0;
for ct = 1:n
    if isreal(r(ct)) && r(ct)<0   % Compute symmetric roots of real numbers
        vec_up(iup+1:iup+L) = (-r(ct))^(1/L)*real_neg;
    else
        vec_up(iup+1:iup+L) =   r(ct)^(1/L)*real_pos;
    end
    iup = iup+L;
end

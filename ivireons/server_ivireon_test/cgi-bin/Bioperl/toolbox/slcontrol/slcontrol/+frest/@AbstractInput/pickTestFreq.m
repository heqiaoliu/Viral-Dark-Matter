function w = pickTestFreq(z,p,Ts,UserDefOptions)
% Pick grid of test frequencies for signal-based linearization.
%
%   W = PICKTESTFREQ(Z,P,TS) picks a grid of frequencies W based on
%   the system dynamics specified by Z (zeros), P (poles), and Ts 
%   (sampling time). Z and P must be cell arrays of column vectors
%   and have the same number of elements in the MIMO case (repeat
%   poles if common to all I/O pairs).
%
%   W = PICKTESTFREQ(Z,P,TS,OPTIONS) specifies additional options
%   controlling the grid density and focus. OPTIONS is a structure
%   with any subset of the following fields:
%      Nf    - Target number of frequency points per decade
%              (default = 5)
%      Nres  - Number of additional frequency points near resonant 
%              poles and zeros (default = 3)
%      Csep  - Threshold for clustering the system dynamics (in  
%              decades, default = 3). The grid W focuses on the  
%              cluster with the largest number of poles and zeros
%      Npad  - Number of decades added to the left/right of the 
%              slowest/fastest dynamics (default = 1).
%
%   LOW-LEVEL UTILITY.

%  Author(s): Pascal Gahinet
%  Revised:
% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/04/21 04:48:32 $

Options = struct('Nf',5,'Nres',3,'Csep',3,'NPad',1);
if nargin>3
   % Read user-specified options 
   OptNames = fieldnames(UserDefOptions);
   for ct=1:length(OptNames)
      Options.(OptNames{ct}) = UserDefOptions.(OptNames{ct});
   end
end
CSEP = 10^Options.Csep;
PAD = 10^Options.NPad;

% Frequencies of system dynamics 
% Note: Do not use scalar P when all I/O pairs have the same poles.
% This will bias the clustering toward the zero distribution.
zp = cat(1,z{:},p{:});
if Ts>0
   % Get equivalent continuous-time roots
   zp = localMap2S(zp,Ts);
end
fzp = sort(abs(zp));
fzp = fzp(fzp>0);

% Cluster dynamics and set focus on dominant cluster (cluster with most poles and zeros)
if isempty(fzp)
   % Pure integrator
   logFocus = [-1 1];
else
   is = 1 + [0 ; find(fzp(2:end)>CSEP*fzp(1:end-1)) ; length(fzp)];  % cluster starts
   [junk,imax] = max(diff(is));
   logFocus = log10([fzp(is(imax))/PAD , fzp(is(imax+1)-1)*PAD]);
end
if Ts>0
   logFocus = min(logFocus,log10(pi/Ts/2)+[-2,0]);
end

% Generate background grid
FDENSITY = Options.Nf;
ndec = diff(logFocus);
w = logspace(logFocus(1),logFocus(2),ceil(ndec*FDENSITY)).';

% Highlight resonant dynamics
DAMPFACT = 0.25;
fzp = abs(zp);
zp = zp(fzp>=w(1)/2 & fzp<=2*w(end) & abs(real(zp))<DAMPFACT*fzp,:);
wres = localResGrid(zp,Ts,Options.Nres,FDENSITY);
w = sort([w;wres]);

end

%----------------------- Subfunctions -----------------------------------


function w = localResGrid(s,Ts,NRES,FDENSITY)
% Generates finer grid around peak frequency for resonant
% S-plane poles or zeros
s = s(imag(s)>0);
w0 = abs(s);                   % natural frequency
zeta = abs(real(s))./w0;       % damping ratio (< 0.7)
zeta2 = zeta.^2;

% Compute frequency WPEAK (in DECADES) where gain peaks
if Ts==0,
   % Continuous mode
   wpeak = w0 .* sqrt(1-2*zeta2);
else
   % S-plane equivalent to discrete mode: get exact WPEAK by mapping
   % mode back to Z-plane
   z = exp(Ts*s);
   zmag2 = z.*conj(z);

   % Gain peaks either at 0, pi/Ts, or phi/Ts where
   %      cos(phi) = a(1+a^2+b^2)/2/(a^2+b^2)  ,  z=a+jb
   h = (real(z).*(1+zmag2)./zmag2)/2;
   idx = find(abs(h)<1);
   z = z(idx,:);
   th_peak = acos(h(idx,:));  % phi
   z_peak = exp(1i*th_peak);  % exp(j*phi)
   filt = (abs((z_peak-z).*(z_peak-conj(z))) < abs((z+1).*(conj(z)+1)));
   wpeak = th_peak(filt,:)/Ts;
end

% Refine grid near WPEAK. Additional frequencies to the right of 
% WPEAK are log-spaced according to the progression delta,2*delta,
% 3*delta,... and the last point is SEP*WPEAK where 
%   SEP = 10^(1/(3*FDENSITY))
n = ceil((NRES-1)/2);
delta = 2/FDENSITY/n/(n+1);  % log2(10^(1/3))~1
spacing = delta*cumsum(1:n);
grid = [fliplr(pow2(-spacing)),1,pow2(spacing)];
w = kron(wpeak,grid.');
if Ts>0
   w = w(w<pi/Ts/2,:);
end
end


function r = localMap2S(r,Ts)
% Map to S plane if system is discrete
zr = (abs(r)<1e-2);  % roots near z=0
r(zr,:) = pi/Ts;     % show phase shift up to Nyquist freq. for pseudo delays
r(~zr,:) = log(r(~zr,:))/Ts;
end
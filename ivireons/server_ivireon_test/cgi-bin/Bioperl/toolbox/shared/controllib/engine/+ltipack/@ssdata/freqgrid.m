function [w,FocusInfo] = freqgrid(D,z0,p0,Grade,FRange)
% Frequency grid generation for models with internal delays.
%
%    [W,FOCUSINFO] = FREQGRID(D,Z0,P0,GRADE,FRANGE) generates a   
%    frequency grid W given the nominal zeros Z0 and poles P0 
%    for each I/O pair (cell arrays).  Also returns a structure
%    FOCUSINFO containing
%      1) Frequency range DRANGE where internal delays 
%         have visible effect on response ([] if n/a)
%      2) Frequency FLIMIT where response settles into limit 
%         cycle.
%
%    GRADE is an integer between 1 and 4 that controls the grid
%    density for different plot types (1=finest, 4=coarsest).
%    FRANGE is either empty or specifies a desired frequency 
%    range [FMIN,FMAX] (the frequency grid W is then clipped to 
%    fit this range.

%    Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%    $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:31:00 $

% RE: Expects data for a single SISO or MIMO LTI model
Ts = abs(D.Ts);
tau = D.Delay.Internal;
if Ts>0
   tau = tau * Ts;
end
nfd = length(tau);

% Algorithm parameters
MinSep = 0.005; % min. log separation between grid points 

% Compute frequency grid for delay-free model (tau=0)
w0 = freqgrid(z0,p0,Ts,Grade,FRange);

% Frequency range of interest for delays
fmin = max(w0(1),pi/10/max(tau));
fmax = min(w0(end),1e8*fmin);  % limit refinement to 8 decades
FocusInfo = struct('DRange',[],'FLimit',Inf);

if fmin<fmax
   % Compute zpk representation of open-loop delay model H and compute
   % response in range where delays are active
   [rs,cs] = size(D.d);
   D.Delay.Input = zeros(cs,1);
   D.Delay.Output = zeros(rs,1);
   D.Delay.Internal = zeros(0,1);
   H = zpk(D);
   wH = freqgrid(H.z,H.p,Ts,Grade,[fmin fmax]);
   frH = fresp(H,wH);
   frH = permute(frH,[3 1 2]);
   
   % Construct fine grid WG used to locate gain extrema of G=lft(H,tau).
   % This grid combines a high-density uniform grid with estimates
   % WX of the frequencies where the gain of G is maximal/minimal
   wx = localEstimateExtrema(wH,frH,tau,MinSep);
   lf1 = log10(fmin);
   lf2 = log10(fmax);
   wG = localUniqueWithTol([wx ; logspace(lf1,lf2,round((lf2-lf1)/MinSep)).']);
   
   % Interpolate response of H over grid wG and compute approximate
   % response of G over this grid
   nzch = any(frH,1);
   inz = find(nzch(:));
   frH = frH(:,inz);   % discard zero channels
   frH(frH==0) = NaN;  % set remaining isolated zeros to NaN (interp1)
   frHi = zeros(length(wG),rs,cs);
   frHi(:,inz) = pow2(interp1(log2(wH),log2(frH),log2(wG)));
   % Add zero frequency for Nyquist/Nichols (for resonant peak gridding)
   if Grade<3
      wG = [0;wG];
      frHi = cat(1,reshape(dcgain(H),[1 rs cs]),frHi);
   end
   frG = localCloseDelayLoops(frHi,wG,tau);
   
   % For each I/O pair of G, locate extrema of |G(i,j)| and compute
   % low-density grid that includes key extrema and yields smooth
   % plot near such extrema
   w = [];  wxSat = NaN;  wxLast = NaN;
   for ct=1:(rs-nfd)*(cs-nfd)
      [wio,wioSat,wioLast] = localBuildGrid(wG,frG(:,ct),Grade,MinSep);
      w = [w;wio];   wxSat = max(wxSat,wioSat);   wxLast = max(wxLast,wioLast); %#ok<AGROW>
   end
   
   % Plot-specific refinements
   hasLimitCycle = (~isempty(w) && max(w)>fmax/2 && fmax>1e2*wxSat);
   w = localRefineGrid(w,w0,wxSat,fmax,tau,wG,frG,Grade,hasLimitCycle);
   
   % Return focus info for internal delays
   if isempty(FRange)
      wxLast = min(wxLast,wxSat);
      if isnan(wxLast)
         FocusInfo.DRange = [fmin , min(w0(end),1e2*fmin)]; % watch for nyquist freq
      else
         FocusInfo.DRange = [fmin , min(wxLast,1e6*fmin)];
      end
      if hasLimitCycle
         FocusInfo.FLimit = wxSat;
      end
   else
      if Ts>0
         FRange(2) = min(FRange(2),pi/Ts);
      end
      w = [FRange(1) ; w(w>FRange(1) & w<FRange(2)) ; FRange(2)];
   end
else
   % No delay contribution in the specified frequency range: default to usual grid
   w = w0;
end

%------------- Local Functions -----------------------

function [w,wxSat,wxLast] = localBuildGrid(wF,gF,Grade,MinSep)
% Generates grid W that highlights key extrema of G = lft(H,tau)
% and smoothes rapid variations of the response near such extrema
nF = length(wF);
mag = abs(gF);

% Find gain extrema
mag1 = mag(1:nF-2,:);
mag2 = mag(2:nF-1,:);
mag3 = mag(3:nF,:);
rgap = 1+1e4*eps;  % beware of rounding noise
isMin = [false;mag2<mag1/rgap & mag2<mag3/rgap;false];
isMax = [false;mag2>mag1*rgap & mag2>mag3*rgap;false];
ix = find(isMin | isMax);
wx = wF(ix);   % all extremal frequencies
nfx = length(wx);

% Compute test frequencies wL and wR interleaved with extrema
% (used for resonant peaks in Nyquist/Nichols)
if Grade<3
   dwx = diff([wF(1);wx;wF(nF)]);
   wL = max(0.95*wx,wx-.25*dwx(1:nfx,:));
   wR = min(1.05*wx,wx+.25*dwx(2:nfx+1,:));
   [~,is] = sort([wF;wL]);
   iL = is(find(is>nF)-1);   % length(ix)
   [~,is] = sort([wF;wR]);
   iR = is(find(is>nF)+1);   % length(ix)
   iBad = find(iL>nF | iR>nF);
   if ~isempty(iBad) % should never happen
      iL(iBad,:) = [];   iR(iBad,:) = [];
   end
end

% Drop extrema that do not add significant info to the plot
if nfx>0
   mag = mag(ix);
   magL = mag([1 1:nfx-1]);
   magR = mag([2:nfx nfx]);
   if Grade==1  % Nyquist
      MinVar = 0.02 * max(mag);
      MinGain = 0.05;
      % Ignore extremum when gain is within MinVar of its neighbors
      isSignificant = mag>MinGain & ...
         (mag>min(magL,magR)+MinVar | mag<max(magL,magR)-MinVar);
   else
      MinVar = pow2(0.01*log2(max(mag)/min(mag(mag>0))));
      % Ignore extremum when lgain is within MinVar multiplicative
      % factor of its neighbors
      isSignificant = (mag>MinVar*min(magL,magR) | mag<max(magL,magR)/MinVar);
   end
   is = find(isSignificant);
   wx = wx(is,:);  % WX = vector of all significant gain extrema
   nfx = length(is);
end

% Compute 
% 1) Frequency WXSAT where extremum density permanently 
%    drops below 4/MINSEP
% 2) Frequency WXLAST of last significant extremum
wxLast = NaN;   wxSat = NaN;
if nfx>10
   isep = find(wx(11:nfx)>wx(1:nfx-10)*10^(40*MinSep));
   if isempty(isep)
      wxSat = wx(1);
   elseif numel(isep)<nfx-10
      wxSat = wx(10+isep(end));
   end
end
if nfx>0
   wxLast = wx(nfx);
end

% Plot smoothing: add linearly-spaced points between
% extrema separated by at least MINSEP
isep = find(wx(2:nfx)>10^MinSep*wx(1:nfx-1));
ws = [wx(isep,:) , wx(1+isep,:)];
switch Grade
   case {1,2}
      t = .1:.1:.9;
   case {3,4}
      t = [.1,.25,.5,.75,.9];
end
ws = ws * [1-t;t];

% Plot smoothing: use nonlinear distribution near resonant
% peaks for Nyquist/Nichols
if Grade<3 && nfx>0 
   % LINSTEP = max step for default uniform gridding between extrema
   isep = [1;1+isep];
   if length(isep)<2
      LinStep = inf;
   else
      dw = diff(wx(isep));
      LinStep = .1 * max([0;dw],[dw;0]);
   end
   % Extract data for maxima
   imax = find(isMax(ix(is(isep))));
   issm = is(isep(imax));
   wPeak = wx(isep(imax),:);   gPeak = gF(ix(issm),:);
   iL = iL(issm);   iR = iR(issm);
   wL = wF(iL,:);   gL = gF(iL,:);
   wR = wF(iR,:);   gR = gF(iR,:);
   LinStep = LinStep(imax,:);
   % Handle peak at w=0
   if isfinite(gF(1)) && abs(gF(1))>abs(gF(2))
      wPeak = [0;wPeak];   gPeak = [gF(1);gPeak];
      wL = [-wF(2) ; wL];  gL = [conj(gF(2));gL];
      wR = [wF(2) ; wR];   gR = [gF(2);gR];
      LinStep = [inf;LinStep];
   end
   ws = [ws(:) ; localResonantGrid(wPeak,gPeak,wL,gL,wR,gR,LinStep)];
end

% Assemble grid
w = [wx ; ws(:)];


%------------------------------------------------------

function w = localRefineGrid(w,w0,wxSat,fmax,tau,wG,frG,Grade,hasLimitCycle)
% Refines and extends grid based on gain extrema
DelayPeriods = unique(6.28./tau(tau>0));  % sorted

% Low-density grid up to first extremum (Bode/sigma only)
if Grade>2 && ~isempty(w)
   lf1 = log10(max(w0(1),5e-3*DelayPeriods(1)));
   lf2 = log10(w(1));
   w = [w ; logspace(lf1,lf2,round((lf2-lf1)*20)).'];
end

% Cover first 4 periods for each delay to capture possible linear
% phase variations (occurs when |H22|<<1, see g342848)
fp = [DelayPeriods(1)/4 ; 4*DelayPeriods];
wph = [];
for ct=1:length(DelayPeriods)
   wph = [wph ; linspace(fp(ct),fp(ct+1),10).']; %#ok<AGROW>
end

% Merge grid contributions
w = localUniqueWithTol([w0 ; w ; wph(wph<fmax)]);

% Adjustments for limit cycles (persistent oscillations)
if hasLimitCycle  % false if wxSat = NaN
   switch Grade
      case 1
         % Nyquist: do not grid past wxSat to avoid choppy plot in [wxSat,inf]
         w = w(w<wxSat);
      case 2
         % Nichols: show at least 10 encirclements, try not to exceed wxSat
         ph = unwrap(angle(frG(:,:)),[],1);
         dph = abs(ph-ph(ones(1,length(wG)),:));
         wFocus = max([wxSat,wG(find(any(dph>20*pi,2),1))]);
         w = w(w<wFocus);
      case {3,4}
         % Bode, sigma: only track extrema for 3 decades past wxSat
         wStop = 1e3*wxSat;
         w = w(w<wStop);
         if wStop<w0(end)
            % Low-density fill-in toward Inf
            lf1 = log10(wStop);
            lf2 = log10(w0(end));
            w = [w ; logspace(lf1,lf2,round(20*(lf2-lf1))).'];
         end
   end
end
   
%-----------------------------------------------

function ws = localResonantGrid(w0,h0,wL,hL,wR,hR,LinStep)
% Generates finer grid near resonant magnitude peaks
   
% Fit model to wL,w0,wR and estimate rho
tau = 0.1./(wR-wL);
eL = exp(1i*tau.*(wL-w0));
eR = exp(1i*tau.*(wR-w0));
thL = (hL-h0)./(eL-1);
thR = (hR-h0)./(eR-1);
psiL = (eL.*hL-h0)./(eL-1);
psiR = (eR.*hR-h0)./(eR-1);
rho = real((psiL-psiR)./(thL-thR));

% Lobe-covering grid (in range space)
npts = 9;
theta = linspace(-2.8,2.8,2*npts+1);
tanth = tan(theta/2);

% Use finer grid only when step is smaller than LinStep
ires = find((theta(2)-theta(1))*abs(rho-1)<tau.*LinStep);
w0 = w0(ires,:);
rho = rho(ires,:); 
tau = tau(ires,:);

% Generate lobe-covering grid for these peaks
ws = (2 * (rho-1)./(rho+1)./tau) * tanth;
ws(:,npts+1) = [];
ws = w0(:,ones(1,2*npts)) + ws;
ws = ws(ws>0); % because of negative freqs obtained for w0=0
ws = ws(:);


%-----------------------------------------------

function wx = localEstimateExtrema(w,h,tau,MinSep)
% Computes approximate locations for the extrema of
% H11 + H12 * (exp(tau*s)-H22) \ H21.
%
% MinSep: min log separation log10(w(k+1)/w(k))>=MinSep 
wx = zeros(0,1);
mu = 10^MinSep;
logmu = MinSep * log(10);  % log(mu)

% Dimensions
nfd = length(tau);
[nf,rs,cs] = size(h);
ny = rs-nfd;
nu = cs-nfd;

% Locate extrema of 
%   * |exp(tau(k)*s)-H22(k,k)| where H22(k,k) close to 1
%   * |exp(tau(k)*s)+H12(i,k)*H21(k,j)/H11(i,j)| where |H22(k,k)|<<1
%     and all others entries of H22(k,:) and H22(:,k) are zero
for ct=1:nfd
   h22 = h(:,ny+ct,nu+ct);
   mag = abs(h22);
   mag1 = mag(1:nf-1,:);
   mag2 = mag(2:nf,:);
   % |exp(tau(k)*s)-H22(k,k)|
   idx = find(max(mag1,mag2)>0.01 & min(mag1,mag2)<100);
   wx = [wx ; localFindMinMax(...
      [w(idx,:) w(idx+1,:)],[h22(idx,:) h22(idx+1,:)],tau(ct),mu,logmu)]; %#ok<AGROW>
   % |exp(tau(k)*s)+H12(i,k)*H21(k,j)/H11(i,j)|
   ioff = [1:ct-1,ct+1:nfd];
   OffDiag = (any(h(:,ny+ioff,nu+ct),2) | any(h(:,ny+ct,nu+ioff),3));
   idx = find(mag1+mag2<0.1 & ~OffDiag(1:nf-1,:) & ~OffDiag(2:nf,:));
   if ~isempty(idx)
      hr = zeros(nf,1);
      for j=1:nu
         for i=1:ny
            h11 = h(:,i,j);
            ix1 = idx(h11(idx)~=0 & h11(idx+1)~=0);
            ix2 = [ix1;ix1+1];
            hr(ix2,:) = -h(ix2,i,nu+ct) .* h(ix2,ny+ct,j) ./ h11(ix2,:);
            mag1 = abs(hr(ix1,:));
            mag2 = abs(hr(ix1+1,:));
            ix1 = ix1(max(mag1,mag2)>0.01 & min(mag1,mag2)<100);
            wx = [wx ; localFindMinMax(...
               [w(ix1,:) w(ix1+1,:)],[hr(ix1,:) hr(ix1+1,:)],tau(ct),mu,logmu)]; %#ok<AGROW>
         end
      end
   end
end


%-----------------------------------------------

function wx = localFindMinMax(w,h,tau,mu,logmu)
% Finds minima and maxima of |exp(jw*tau)-h(jw)| in intervals 
% [w(iw,1),w(iw,2)].  Consecutive min. or max. frequencies are 
% constrained to be spaced by at least MU=EXP(LOGMU) (i.e., 
% w(k+1)/w(k)>=mu)
w1 = w(:,1);
w2 = w(:,2);
r = log(h(:,1))-1i*(tau*w1);     
s = log(h(:,2))-1i*(tau*w2)-r;   
mu1 = mu-1;

% Eliminate intervals with imag(s)=0
idx = find(imag(s)==0);
if ~isempty(idx)
   r(idx,:) = [];
   s(idx,:) = [];
   w1(idx,:) = [];
   w2(idx,:) = [];
end
dw = w2-w1;
r1 = real(r);  r2 = imag(r);
s1 = real(s);  s2 = imag(s);
sgn2 = sign(s2);

% Compute the number and location of extrema in each interval
nf = length(w1);
kmin = -inf(nf,1);
kmax = inf(nf,1);
idx = find(s1~=0);
s21 = s2(idx)./s1(idx);
kc = sgn2(idx).*(r2(idx)-r1(idx).*s21)/(2*pi);
rho = (1+s21.^2)/2;
kmin(idx) = kc-rho;
kmax(idx) = kc+rho;

% Minimizers th1+k*T1
ssq = s1.^2+s2.^2;
T1 = 2*pi*abs(s2)./ssq;
th1 = -(r1.*s1+r2.*s2)./ssq;
% Enforce t in [0,1]
ks1 = ceil(max(kmin,-th1./T1));
ke1 = floor(min(kmax,(1-th1)./T1));
% Enforce upper bound on density
beta1 = (th1+w1./dw)./T1;
N1 = floor(1/mu1-beta1); % note: beta+N ~= 1/(mu-1)
ms1 = ceil(log(max(mu,mu1*(beta1+ks1)))/logmu)-1;
dm1 = max(0,floor(log(max(mu,mu1*(beta1+ke1)))/logmu) - ms1);
ke1 = min(N1,ke1);

% Maximizers th2+k*T2
T2 = 2*pi./abs(s2);
th2 = (pi-r2)./s2;
% Enforce t in [0,1]
ks2 = ceil(max(kmin,-th2./T2));
ke2 = floor(min(kmax-1,(1-th2)./T2));
% Enforce upper bound on density
beta2 = (th2+w1./dw)./T2;
N2 = floor(1/mu1-beta2);
ms2 = ceil(log(max(mu,mu1*(beta2+ks2)))/logmu)-1;
dm2 = max(0,floor(log(max(mu,mu1*(beta2+ke2)))/logmu) - ms2);
ke2 = min(N2,ke2);

% Construct vector of extremal frequencies
nx = max(0,ke1-ks1+1) + dm1 + max(0,ke2-ks2+1) + dm2;
wx = zeros(sum(nx),1);
idx = find(nx>0);
aux = cumprod(mu(:,ones(1,max(max(dm1),max(dm2)))));
cnt = 0;
for ct=1:length(idx)
   p = idx(ct);
   k1 = [ks1(p):ke1(p) , round((mu^ms1(p)/mu1)*aux(1:dm1(p))-beta1(p))].';
   k2 = [ks2(p):ke2(p) , round((mu^ms2(p)/mu1)*aux(1:dm2(p))-beta2(p))].';
   wx(cnt+1:cnt+nx(p)) = w1(p) + [th1(p)+k1*T1(p) ; th2(p)+k2*T2(p)] * dw(p);
   cnt = cnt+nx(p);
end


%-----------------------------------------------

function htau = localCloseDelayLoops(h,w,tau)
% Closes delay loops
% RE: Faster but less accurate version of frdelay (no pivoting in
%     Gauss elimination)
nfd = length(tau);
[~,rs,cs] = size(h);
ny = rs-nfd;
nu = cs-nfd;
for k=nfd:-1:1
   th = exp((1i*tau(k))*w) - h(:,ny+k,nu+k);
   th(th==0) = NaN;
   for j=1:nu+k-1
      for i=1:ny+k-1
         h(:,i,j) = h(:,i,j) + h(:,i,nu+k) .* h(:,ny+k,j) ./ th;
      end
   end
end
htau = h(:,1:ny,1:nu);

%-----------------------------------------------

function w = localUniqueWithTol(w)
rtol = 1e-6;
w = sort(w);
w = w([true;w(2:end)>(1+rtol)*w(1:end-1)],:);

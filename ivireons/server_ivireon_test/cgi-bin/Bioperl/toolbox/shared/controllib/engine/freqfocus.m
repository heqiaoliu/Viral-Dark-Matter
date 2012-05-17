function FocusInfo = freqfocus(Grade,w,h,z,p,Ts,linDelay,fDelayInfo)
%FREQFOCUS  Computes frequency focus for single MIMO model.
%
%  FOCUSINFO = FREQFOCUS(GRADE,W,H,Z,P,TS,LINDELAYS,FDELAYINFO) select a 
%  "frequency range of interest" for the MIMO frequency response specified 
%  by:
%    * W,H: Complex frequency response excluding external delays
%      (W along first dimension of H)
%    * Z,P,TS: I/O dynamics and sampling time
%    * LINDELAYS: External delays expressed as equivalent continuous-time
%      delays (discrete delays must be multiplied by sampling time TS)
%    * FDELAYINFO: Frequency range where internal delays contribute to 
%      the response.
%  GRADE specifies the response grade (1 for Nyquist, 2 for Nichols,...).
%
%  The structure FOCUSINFO contains:
%    * Focus: frequency band to be shown for specified plotting grade
%    * DynRange: tight frequency range including all significant dynamics
%    * Soft: flag indicating when focus is immaterial (no significant dynamics) 
%     
%  See also MRGFOCUS.

%  Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:11:01 $
h = h(:,:);
mag = abs(h);
hasDelayDynamics = (~isempty(fDelayInfo));

% Compute range for each I/O pair
nios = size(h,2);
DynamicRanges = cell(nios,1);
SoftRangeFlags = false(nios,1);
for ct=1:nios
   fz = damp(z{min(ct,end)},Ts);
   fp = damp(p{min(ct,end)},Ts);
   [DynamicRanges{ct,1},SoftRangeFlags(ct,1)] = ...
      LocalGetDynamicRange(fz,fp,w,mag(:,ct),h(:,ct),Ts);
end

% Merge these ranges
DynRange = mrgfocus(DynamicRanges,SoftRangeFlags);
SoftFlag = all(SoftRangeFlags);

% Take internal delay contribution into account
if hasDelayDynamics
   if isempty(DynRange)
      DynRange = fDelayInfo.DRange;
   else
      DynRange = [min(DynRange(1),fDelayInfo.DRange(1)) , fDelayInfo.DRange(2)];
   end
   SoftFlag = false;
end

% Extend range up to asymptotes
Focus = DynRange;
if ~isempty(Focus)
   % Extend focus to show beginning of asymptotes
   [Focus,nLF,nHF] = LocalShowAsymptote(Focus,w,h);
   % Plot-specific adjustments
   Focus = LocalAdjustFocus(Focus,Grade,w,mag,linDelay,Ts,nLF,nHF);
   % Enforce upper limit on range when response has limit cycles
   if hasDelayDynamics
      if Grade==2
         % Nichols: limit phase range to 10 revolutions
         iw = length(w);
         ph = unwrap(angle(h),[],1);
         for ct=1:size(ph,2)
            iw = min([iw find(abs(ph(:,ct)-ph(1,ct))>63,1)]);
         end
         Focus(2) = min(Focus(2),w(iw));
      else
         Focus(2) = min(Focus(2),fDelayInfo.FLimit);
      end
   end
end

% Return focus info
FocusInfo = struct('Focus',Focus,'DynRange',DynRange,'Soft',SoftFlag);

%--------------- Local Functions ----------------------------

function [DynRange,SoftRange] = LocalGetDynamicRange(fz,fp,w,mag,h,Ts)
% Determines dynamic range for a single SISO model.  The dynamic
% range is chosen to contain most interesting dynamics while 
% being as compact as possible.
%
% SOFTRANGE is true when the response either has no dynamics, or can be 
% assimilated to pure gain, integrators, or differentiators. Models with 
% SOFTRANGE = true may not contribute to the overall range (see MRGFOCUS).

% Detect pure gains independently of dynamics (robust to
% cancellations, e.g., bode(ss(tf(1,[1 0]))-(1+tf(1,[1 0])))
if all(abs(h-h(1)) <= 1e-3*mag(1))
   DynRange = [];
   SoftRange = true;
   return
end

% Parameters
FGAP = 3;    % 3-decade gap for cluster separation
MGAP = 1e4;  % 80 dB gain drop for discarding LF and HF clusters
if Ts==0
   fMidRange = 1;
else
   nf = pi/Ts;   fMidRange = 1e-3 * nf;
end

% Get dynamics within ultimate range (g352625)
[flb,fub] = utMaxFreqRange(Ts);
f = sort([fz;fp]);
if Ts==0
   f = f(f>flb & f<fub,:);
else
   f = f(f>flb,:);
   f(f>nf) = nf;
end

% Cluster dynamics
nw = length(f);
isep = find(diff(log10(f))>FGAP);
idxs = [0;isep];
idxe = [isep;nw];

% Find and grow dominant cluster
if nw>0
   % Find dominant cluster
   logTarget = log10(fMidRange);
   [junk,idom] = max(idxe-idxs-abs(logTarget-log10(f(idxe) .* f(idxs+1))/2));
   fmin = f(idxs(idom)+1);
   fmax = f(idxe(idom));
   % Grow dominant cluster to the left
   for ct=idom-1:-1:1,
      gL = mag(find(w<=fmin/2,1,'last'));
      iLF = find(w<=f(idxe(ct)));
      gainLF = mag(iLF);
      if all(gainLF>gL*MGAP) || all(gainLF<gL/MGAP) || all(abs(1-h(iLF)/h(1))<.1)
         % Discard clusters 1,..,CT when equivalent to pure gain or pole/zero 
         % cluster at the origin (g352625)
         break
      else
         % Absorb cluster CT into dominant cluster
         fmin = f(idxs(ct)+1);
      end
   end
   % Grow dominant cluster to the right 
   for ct=idom+1:length(idxs)
      gR = mag(find(w>=fmax/2,1));
      iHF = find(w>=f(idxs(ct)+1));
      gainHF = mag(iHF);
      if all(gainHF>gR*MGAP) || all(gainHF<gR/MGAP) || all(abs(1-h(iHF)/h(end))<.1)
         % Discard clusters CT,CT+1,... when equivalent to pure gain or pole/zero 
         % cluster at infinity
         break
      else
         % Absorb cluster CT into dominant cluster
         fmax = f(idxe(ct));
      end
   end 
   DynRange = [fmin,fmax];
else
   % No dynamics beyond pure integrators or derivators
   DynRange = [];
end   
   
% Set SOFTRANGE flag
% Note: Use [1e-6,1e6] range in continuous time to weed out pure integ/deriv 
%       in MIMO models, e.g., bode([tf(1,[1 1e-7]) ; tf(100,[1 2 100])])
SoftRange = (isempty(DynRange) || localIsIntDiff(f,w,mag,Ts));

%%%%%%%%%%%%%%%

function [focus,nLF,nHF] = LocalShowAsymptote(focus,w,h)
% Extends focus up to frequencies where response behaves
% approximately as s^n (to show beginning of the asymptotes)
rtol = 0.05;
nLF = [];  % response behaves as s.^nLF near w=0 
nHF = [];  % response behaves as s.^nHF near w=Inf 

% Extend toward low frequencies
fmin = focus(1)/8;  % default, see sys1 in ltigallery
idx = find(w>focus(1)/200 & w<focus(1));
if ~isempty(idx)
   idx1 = idx(1);  w1 = w(idx1);
   idx2 = idx(find(w(idx)>2*w1,1));
   % RE: Watch for insufficient data
   if ~isempty(idx2)
      w2 = w(idx2);
      % Fit model H = a * W^n to w1,w2 data points
      h(:,h(idx1,:)==0 | h(idx2,:)==0) = [];  % see g267250
      % Beware of empty H, e.g., for nyquist(ss(1,1,0,0)) (all zero response)
      if ~isempty(h)
         n = round(real(log(h(idx1,:)./h(idx2,:))/log(w1/w2)));
         a = h(idx1,:) ./ w1.^n;
         % Get worst prediction error across I/O pairs for each frequency in W(IDX)
         % and set focus to last frequency where error < 5%
         emax = zeros(length(idx),1);
         for ct=1:length(idx)
            ctx = idx(ct);
            emax(ct) = max(abs(1 - h(ctx,:) ./ (a .* w(ctx).^n)));
         end
         idxa = idx(find(emax<rtol,1,'last'));
         if ~isempty(idxa) && w(idxa)>=2*w1
            % Second clause validates model and protects against bad data (see margex)
            fmin = w(idxa);
            nLF = n;
         end
      end
   end
end

% Extend toward high frequencies
fmax = focus(2)*8;  % default
idx = find(w>focus(2) & w<200*focus(2));
if ~isempty(idx)
   idx2 = idx(end);  w2 = w(idx2);
   idx1 = idx(find(w(idx)<w2/2,1,'last'));
   % RE: Watch for insufficient data (happens, e.g., when w(end) = Nyquist frequency)
   if ~isempty(idx1)
      w1 = w(idx1);
      % Fit model H = a * W^n to w1,w2 data points
      h(:,h(idx1,:)==0 | h(idx2,:)==0) = [];
      % Beware of empty H, e.g., for nyquist(ss(1,1,0,0)) (all zero response)
      if ~isempty(h)
         n = round(real(log(h(idx1,:)./h(idx2,:))/log(w1/w2)));
         a = h(idx2,:) ./ w2.^n;
         % Get worst prediction error across I/O pairs for each frequency in W(IDX)
         % and set focus to last frequency where error < 5%
         emax = zeros(length(idx),1);
         for ct=1:length(idx)
            ctx = idx(ct);
            emax(ct) = max(abs(1 - h(ctx,:) ./ (a .* w(ctx).^n)));
         end
         idxa = idx(find(emax<rtol,1));
         if ~isempty(idxa) && w(idxa)<=w2/2
            fmax = w(idxa);
            nHF = n;
         end
      end
   end
end

focus = [fmin,fmax];


%-----------------------
function focus = LocalAdjustFocus(focus,Grade,w,mag,linDelay,Ts,nLF,nHF)
% Make plot-specific adjustments.
switch Grade
   case 1
      % Nyquist      
      % Adjustments near w=0
      if ~isempty(nLF) && all(nLF>=0)
       % Set focus(1)=0 if h(0) is finite for all I/O pairs
        focus(1) = 0;
      end
      
      % Adjustments near w=inf
      if norm(linDelay,1)==0
         % No delays
         if ~isempty(nHF) && all(nHF<=0)
            % Nyquist: set focus(2)=inf if h(inf) is finite for all I/O pairs
            focus(2) = Inf;
         end
      else
         % Extend focus to show delay-related encirclements
         for ct=1:numel(linDelay)
            if linDelay(ct)>0
               if mag(end,ct)<0.05
                  % Extend focus to last frequency where the gain is > 0.05
                  focus(2) = max([focus(2);w(find(mag(:,ct)>=0.05,1,'last'))]);
               else
                  % Improper or settles to gain > 0.05: show at least one full
                  % encirclement after dynamics settle (three if unbounded at inf)
                  nperiods = 1 + 2 * (isempty(nHF) || nHF(ct)>0);
                  focus(2) = max(focus(2),focus(1,2)+nperiods*2*pi/linDelay(ct));
               end
            end
         end
      end
      
   case 2
      % Nichols
      % Adjustments near w=0
      if ~isempty(nLF) && all(nLF==0)
         % Set focus(1)=0 if h(0) is a finite point on the graph
         focus(1) = 0;
      else
         % Add 1/2 decade toward w=0 (dB scale warrants longer
         % asymptotes) e.g., nichols(tf(1,conv([1/81 2*0.1/9 1],[1 0])))
         focus(1) = 0.316 * focus(1);
      end
      
      % Adjustments near w=inf
      if norm(linDelay,1)==0
         if ~isempty(nHF) && all(nHF==0)
            % Nichols: set focus(2)=inf if h(inf) is a finite point on the graph
            focus(2) = Inf;
         else
            % Nichols: add 1/2 decade toward Inf
            focus(2) = 3.16 * focus(2);
         end
      else
         % Extend focus to show phase offset for largest delay
         maxDelay = max(linDelay(:));
         if pi/maxDelay<50*focus(2)
            focus(2) = max(focus(2),2*pi/maxDelay);
         end
      end
      
   case 3
      % Bode
      if norm(linDelay,1)>0
         % Extend focus to show phase offset for largest delay
         maxDelay = max(linDelay(:));
         if pi/maxDelay<50*focus(2)
            focus(2) = max(focus(2),2*pi/maxDelay);
         end
      end
end

% Discrete-time adjustments
if Ts~=0
   % Don't clip too close to Nyquist freq. in discrete time
   nf = pi/Ts;
   focus(1) = min(focus(1),nf/100);
   if focus(2)>nf/31.6
      focus(2) = nf;
   end
end

%---------------------------------

function SoftFocus = localIsIntDiff(f,w,mag,Ts)
% Tests if SISO response is close to that of a pure chain 
% of integrators or differentiators.
% NOTE: Pure gains detected prior to this call
SoftFocus = false;
septol = 1e3;
if Ts==0 && all(f<1e-6 | f>1e6)
   % No dynamics in [1e-6,1e6] range: check gain profile
   glf = mag(w<1e-6);
   ghf = mag(w>1e6);
   inRange = (w>=1e-6 & w<=1e6 & mag>0);  % pick gains in [1e-6,1e6] range
   w = w(inRange); g = mag(inRange);      % freq points and gains in [1e-6,1e6] range
   n = length(g);
   if n>1
      SoftFocus = ((w(1)*g(1)>w(n)*g(n)/2 && min([glf;inf])>g(1)/septol && max([ghf;-inf])<septol*g(n)) || ...
         (w(1)*g(n)>g(1)*w(n)/2 && max([glf;-inf])<septol*g(1) && min([ghf;inf])>g(n)/septol));
   end
elseif Ts~=0 && all(f<1e-8*pi/Ts)
   % No dynamics in [1e-8*nf,nf] range: check gain profile
   nf = pi/Ts;
   glf = mag(w<1e-8*nf);
   inRange = (w>=1e-8*nf & w<=nf/2 & mag>0);
   w = w(inRange); g = mag(inRange);
   n = length(g);
   if n>1
      SoftFocus = ((w(1)*g(1)>0.1*w(n)*g(n) && min([glf;inf])>g(1)/septol) || ...
         (w(1)*g(n)>0.1*w(n)*g(1) && max([glf;-inf])<septol*g(1)));
   end
end

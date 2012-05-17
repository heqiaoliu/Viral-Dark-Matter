function [mag,ph,w,FocusInfo] = freqresp(D,Grade,wspec,isPlotted)
% Generates frequency response data (magnitude+phase) for
% MIMO LTI models. Used by BODE, NICHOLS, and NYQUIST.
%
%  [MAG,PHASE,W,FOCUSINFO] = FREQRESP(D,GRADE,WSPEC,ISPLOTTED) 
%  computes the frequency response of a single MIMO model D
%  over some user-defined or auto-generated frequency grid W
%  and returns the magnitude and phase data MAG and PH (in 
%  radians). MAG and PH are of size Nf-by-Ny-by-Nu.
%
%  GRADE should be set to 1 for NYQUIST, 2 for NICHOLS, and 
%  3 for BODE.
%
%  WSPEC specifies the frequency grid or range as follows:
%             [] :  none (auto-selected)
%    {fmin,fmax} :  user-defined frequency range (grid spans 
%                   this range)
%         vector :  user-defined frequency grid
%
%  ISPLOTTED is true when the data is used for plotting and false 
%  otherwise (interpolation is used only when ISPLOTTED=true).
%  See FREQFOCUS for details on the contents of FOCUSINFO.

%  Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:30:13 $

% Read WSPEC
Ts = abs(D.Ts);
[w,Focus] = parseFreqSpec(D,wspec);
AutoGrid = isempty(w);   
AutoFocus = isempty(Focus);

% Get dynamics and total I/O delay
[z,p,k] = ltipack.ltidata.fGetDynamics(D);
linDelay = D.Delay.IO;
[ny,nu] = size(linDelay);
linDelay = linDelay + D.Delay.Input(:,ones(1,ny)).' + D.Delay.Output(:,ones(1,nu));
if Ts>0
   linDelay = linDelay * Ts;  % equivalent continuous-time delays
end

% Generate frequency grid if none specified
if AutoGrid
   % Generate frequency grid using model dynamics
   w = freqgrid(z,p,Ts,Grade,Focus);
   if AutoFocus && ~isPlotted
      % Cosmetic: include 10^k points for syntax [m,p,w]=bode(sys)
      w = ltipack.ltidata.fAddDecades(w,Ts);
   end
end

% Compute response without delays
% Note: ZPKBODERESP computes exact phase (no need for UNWRAP)
nf = length(w);
mag = zeros(nf,ny,nu);
ph = zeros(nf,ny,nu);
RealFlag = isreal(D);
for ct=1:ny*nu
   % Zeros and poles for D(i,j)
   zio = z{ct};  pio = p{min(ct,end)};
   % Sort by ascending magnitude to minimize risk of overflow
   [junk,isz] = sort(abs(zio));
   [junk,isp] = sort(abs(pio));
   % Evaluate mag,phase response at each frequency
   [mag(:,ct),ph(:,ct)] = zpkboderesp(zio(isz),pio(isp),k(ct),Ts,w,RealFlag);
end

% Cosmetic: In plots, set phase to NaN when gain is infinite
if isPlotted
   ph(~isfinite(mag)) = NaN;
end

% Pick frequency focus
if AutoFocus
   FocusInfo = freqfocus(Grade,w,mag.*exp(1i*ph),z,p,Ts,linDelay,[]);
else
   % User-defined (includes case AutoGrid=false)
   FocusInfo = struct('Focus',Focus,'DynRange',Focus,'Soft',false);
end

% Add phase shift due to I/O delays
if norm(linDelay,1)>0
   ph = ph - reshape(w*reshape(linDelay,[1 numel(linDelay)]),size(ph));
   if AutoGrid && isPlotted
      % Cosmetic: In plots, refine grid to produce smooth plot where phase 
      % varies rapidly (likely to increase number of frequency points)
      [w,mag,ph] = ltipack.ltidata.fShowPhaseShift(...
         Grade,w,mag,ph,Ts,linDelay,FocusInfo.Focus);
   end
end

% Sort frequencies if response is plotted
if isPlotted
   [w,is] = sort(w);  mag = mag(is,:,:);  ph = ph(is,:,:);
end

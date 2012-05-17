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
%   Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:31:01 $
Ts = abs(D.Ts);
[w,Focus] = parseFreqSpec(D,wspec);
AutoGrid = isempty(w);   
AutoFocus = isempty(Focus);

% Scale the state-space realization to maximize accuracy in the
% frequency band of interest
if ~D.Scaled
   [D.a,D.b,D.c,D.e,~,~,~,~,Info] = ...
      xscale(D.a,D.b,D.c,D.d,D.e,D.Ts,'Focus',Focus,'Warn',false);
   if ~isempty(Info.WarnID)
      % Tailor warning to frequency response functions
      ctrlMsgUtils.warning(strrep(Info.WarnID,...
         'Control:transformation:StateSpaceScaling',...
         'Control:analysis:ScalingIssue'));
   end
   D.Scaled = true;
end

% Check for delay-induced dynamics
ioDelay = getIODelay(D);
[ny,nu] = size(ioDelay);
if any(isnan(ioDelay(:)))
   % Internal delays give rise to delay dynamics: use
   % state-space representation to compute response.
   if AutoGrid
      % Generate frequency grid if none specified.
      % Compute dynamics with internal delays set to zero
      % RE: Watch for possible XSCALE warnings
      [z,p] = ltipack.ltidata.fGetDynamics(D);
      % Generate frequency grid
      [w,fDelayInfo] = freqgrid(D,z,p,Grade,Focus);
      if AutoFocus && ~isPlotted
         % Cosmetic: include 10^k points for syntax [m,p,w]=bode(sys)
         w = ltipack.ltidata.fAddDecades(w,Ts);
      end
   end

   % Gather external delays
   linDelay = D.Delay.Input(:,ones(1,ny)).' + D.Delay.Output(:,ones(1,nu));
   if Ts>0
      linDelay = linDelay * Ts;  % equivalent continuous-time delays
   end

   % Compute response without external delays
   D.Delay.Input(:) = 0;   D.Delay.Output(:) = 0;
   [w,is] = sort(w);  % sort frequencies (required for phase unwrapping)
   h = permute(fresp(D,w),[3 1 2]);
   [mag,ph] = ltipack.getMagPhase(h,1,isPlotted);
   
   % Pick frequency focus
   if AutoFocus
      FocusInfo = freqfocus(Grade,w,h,z,p,Ts,linDelay,fDelayInfo);
   else
      % User-defined (includes case AutoGrid=false)
      FocusInfo = struct('Focus',Focus,'DynRange',Focus,'Soft',false);
   end
   
   % Add phase shift due to external delays
   if norm(linDelay,1)>0
      ph = ph - reshape(w*reshape(linDelay,[1 numel(linDelay)]),size(ph));
      if AutoGrid && isPlotted
         % Cosmetic: In plots, refine grid to produce smooth plot where phase
         % varies rapidly (likely to increase number of frequency points)
         [w,mag,ph] = ltipack.ltidata.fShowPhaseShift(...
            Grade,w,mag,ph,Ts,linDelay,FocusInfo.Focus);
      end
   end

   % Undo frequency sorting for [mag,ph] = xxx(sys,w) syntax
   if ~isPlotted && any(diff(is)<0)
      w(is) = w;    mag(is,:,:) = mag;   ph(is,:,:) = ph;
   end
   
else
   % No delay-induced dynamics: Use the ZPK representation to compute 
   % magnitude and phase data (yields exact phase + enforces consistency 
   % with equivalent TF/ZPK responses and computed stability margins)
   [mag,ph,w,FocusInfo] = freqresp(zpk(D),Grade,wspec,isPlotted);
end


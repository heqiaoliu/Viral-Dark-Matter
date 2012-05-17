function [sv,w,FocusInfo] = sigmaresp(D,type,wspec,isPlotted)
% Generates singular value response data for MIMO LTI models. 
% Used by SIGMA.
%
%  [SV,W,FOCUSINFO] = SIGMARESP(D,TYPE,WSPEC,ISPLOTTED) 
%  computes the frequency response of a single MIMO model D
%  over some user-defined or auto-generated frequency grid W
%  and returns the singular values (principal gains) of the
%  response. SV is of size min(Ny,Nu)-by-Nf.
%
%  TYPE is 0 to compute the singular values of H, 1 for inv(H), 
%  2 for I+H, and 3 for I+inv(H).
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
%  $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:31:39 $
Ts = abs(D.Ts);
[w,Focus] = parseFreqSpec(D,wspec);
AutoGrid = isempty(w);   
AutoFocus = isempty(Focus);

% Scale the state-space realization to maximize accuracy in the
% frequency band of interest
if ~D.Scaled
   [D.a,D.b,D.c,D.e,junk,junk,junk,junk,Info] = ...
      xscale(D.a,D.b,D.c,D.d,D.e,D.Ts,'Focus',Focus,'Warn',false);
   if ~isempty(Info.WarnID)
      % Tailor warning to SIGMA
      ctrlMsgUtils.warning(strrep(Info.WarnID,...
         'Control:transformation:StateSpaceScaling',...
         'Control:analysis:ScalingIssue'));
   end
   D.Scaled = true;
end

% Generate frequency grid if none specified
if AutoGrid
   % Get dynamics (use MIMO zeros for speed)
   hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
   p = {pole(D)};   z = {zero(D)};
   hw = []; %#ok<NASGU>
   
   % Generate frequency grid
   ioDelay = getIODelay(D);
   if any(isnan(ioDelay(:)))
      % Some I/O transfers have delay-induced dynamics
      [w,fDelayInfo] = freqgrid(D,z,p,4,Focus);
   else
      % No delay-induced dynamics
      w = freqgrid(z,p,Ts,4,Focus);
      fDelayInfo = [];
   end
   
   % Cosmetic: include 10^k points for [m,p,w]=sigma(sys)
   if AutoFocus && ~isPlotted
      w = ltipack.ltidata.fAddDecades(w,Ts);
   end
end
      
% Compute response 
h = fresp(D,w);
sv = ltipack.getSV(h,type);

% Pick frequency focus
if AutoFocus
   FocusInfo = freqfocus(4,w,permute(h,[3 1 2]),z,p,Ts,0,fDelayInfo);
else
   % User-defined (includes case AutoGrid=false)
   FocusInfo = struct('Focus',Focus,'DynRange',Focus,'Soft',false);
end

% Sort frequencies if response is plotted
if isPlotted
   [w,is] = sort(w);  sv = sv(:,is);
end


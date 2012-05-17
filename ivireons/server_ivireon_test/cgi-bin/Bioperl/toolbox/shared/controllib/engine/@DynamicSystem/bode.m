function [magout,phase,w] = bode(varargin)
%BODE  Bode frequency response of dynamic systems.
%
%   BODE(SYS) draws the Bode plot of the dynamic system SYS. The frequency 
%   range and number of points are chosen automatically.
%
%   BODE(SYS,{WMIN,WMAX}) draws the Bode plot for frequencies between WMIN 
%   and WMAX (in radians/second).
%
%   BODE(SYS,W) uses the user-supplied vector W of frequencies, in
%   radian/second, at which the Bode response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   BODE(SYS1,SYS2,...,W) graphs the Bode response of several systems
%   SYS1,SYS2,... on a single plot. The frequency vector W is optional. 
%   You can specify a color, line style, and marker for each model, for
%   example:
%      bode(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [MAG,PHASE] = BODE(SYS,W) and [MAG,PHASE,W] = BODE(SYS) return the
%   response magnitudes and phases in degrees (along with the frequency 
%   vector W if unspecified).  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, MAG and PHASE are arrays of 
%   size [NY NU LENGTH(W)] where MAG(:,:,k) and PHASE(:,:,k) determine 
%   the response at the frequency W(k).  To get the magnitudes in dB, 
%   type MAGDB = 20*log10(MAG).
%
%   For discrete-time models with sample time Ts, BODE uses the
%   transformation Z = exp(j*W*Ts) to map the unit circle to the 
%   real frequency axis.  The frequency response is only plotted 
%   for frequencies smaller than the Nyquist frequency pi/Ts, and 
%   the default value 1 (second) is assumed when Ts is unspecified.
%
%   See BODEPLOT for additional graphical options for Bode plots.
%
%   See also DYNAMICSYSTEM/BODEPLOT, BODEMAG, NICHOLS, NYQUIST, SIGMA, 
%   FREQRESP, LTIVIEW, DYNAMICSYSTEM.

%   Authors: P. Gahinet  8-14-96
%   Revised: A. DiVergilio
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:33 $
ni = nargin;
no = nargout;

% Handle various calling sequences
if no,
   % Parse input list
   try
      [sysList,Extras] = DynamicSystem.parseRespFcnInputs(varargin);
      [sysList,wspec] = DynamicSystem.checkBodeInputs(sysList,Extras);
   catch E
      throw(E)
   end
   sys = sysList(1).System;
   if (numel(sysList)>1 || numsys(sys)~=1),
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','bode');
   end
   
   % Compute frequency response
   [m,p,w,FocusInfo] = freqresp(getPrivateData(sys),3,wspec,false);
   m = permute(m,[2 3 1]);
   p = permute(p,[2 3 1]);

   % Note: When grid is supplied, the following code
   % could be used for top speed (at the expense of
   % phase offsets...)
   % w = wspec;   h = fresp(D,w);
   % [m,p] = ltipack.getMagPhase(h,3);

   % Adjust frequency range
   if isempty(wspec)
      % Clip to FOCUS and make W(1) and W(end) entire decades
      [w,m,p] = roundfocus('freq',FocusInfo.Focus,w,m,p);
   end
      
   % Set units
   magout = m;
   phase = (180/pi)*p;

else
   % Bode response plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   varargin = argname2sysname(varargin,ArgNames);
   try
      bodeplot(varargin{:});
   catch E
      throw(E)
   end
end

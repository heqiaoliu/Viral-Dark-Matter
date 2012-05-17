function [reout,im,w] = nyquist(varargin)
%NYQUIST  Nyquist frequency response of dynamic systems.
%
%   NYQUIST(SYS) draws the Nyquist plot of the dynamic system SYS.  The 
%   frequency range and number of points are chosen automatically. See BODE   
%   for details on the notion of frequency in discrete-time.
%
%   NYQUIST(SYS,{WMIN,WMAX}) draws the Nyquist plot for frequencies between
%   WMIN and WMAX (in radians/second).
%
%   NYQUIST(SYS,W) uses the user-supplied vector W of frequencies 
%   (in radian/second) at which the Nyquist response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NYQUIST(SYS1,SYS2,...,W) plots the Nyquist response of several systems
%   SYS1,SYS2,... on a single plot. The frequency vector W is optional. 
%   You can specify a color, line style, and marker for each model, for
%   example:
%      nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [RE,IM] = NYQUIST(SYS,W) and [RE,IM,W] = NYQUIST(SYS) return the real
%   parts RE and imaginary parts IM of the frequency response (along with 
%   the frequency vector W if unspecified).  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, RE and IM are arrays of size 
%   [NY NU LENGTH(W)] and the response at the frequency W(k) is given by 
%   RE(:,:,k)+j*IM(:,:,k).
%
%   See also NYQUISTPLOT, BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, DYNAMICSYSTEM.

%   Authors: P. Gahinet 6-21-96
%   Revised: A. DiVergilio, 6-16-00
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:52 $
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
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','nyquist');
   end
   
   % Compute frequency response
   % (always use ZPK form for consistency)
   [m,p,w,FocusInfo] = freqresp(getPrivateData(sys),1,wspec,false);  % Grade=1
   m = permute(m,[2 3 1]);
   p = permute(p,[2 3 1]);
   
   % Adjust frequency range
   if isempty(wspec)
      % Clip to FOCUS and make W(1) and W(end) entire decades
      % Note: W(1)=0 if gain is finite at s=0
      [w,m,p] = roundfocus('freq',FocusInfo.Focus,w,m,p);
   end
   
   reout = m .* cos(p);
   im = m .* sin(p);

else
   % Nyquist plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
   try
      nyquistplot(varargin{:});
   catch E
      throw(E)
   end
end

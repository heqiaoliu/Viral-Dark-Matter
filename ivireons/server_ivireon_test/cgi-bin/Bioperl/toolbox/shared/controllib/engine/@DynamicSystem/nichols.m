function [magout,phase,w] = nichols(varargin)
%NICHOLS  Nichols frequency response of dynamic systems.
%
%   NICHOLS(SYS) draws the Nichols plot of the dynamic system SYS. The 
%   The frequency range and number of points are chosen automatically.  
%   See BODE for details on the notion of frequency in discrete-time.
%
%   NICHOLS(SYS,{WMIN,WMAX}) draws the Nichols plot for frequencies
%   between WMIN and WMAX (in radian/second).
%
%   NICHOLS(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the Nichols response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NICHOLS(SYS1,SYS2,...,W) plots the Nichols plot of several systems
%   SYS1,SYS2,... on a single plot. The frequency vector W is optional.
%   You can specify a color, line style, and marker for each model, for
%   example:
%      nichols(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [MAG,PHASE] = NICHOLS(SYS,W) and [MAG,PHASE,W] = NICHOLS(SYS) return
%   the response magnitudes and phases in degrees (along with the 
%   frequency vector W if unspecified). No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, MAG and PHASE are arrays of 
%   size [NY NU LENGTH(W)] where MAG(:,:,k) and PHASE(:,:,k) determine 
%   the response at the frequency W(k).
%
%   See NICHOLSPLOT for additional graphical options for Nichols plots.
%
%   See also NICHOLSPLOT, BODE, NYQUIST, SIGMA, FREQRESP, LTIVIEW, DYNAMICSYSTEM.

%   Authors: P. Gahinet, B. Eryilmaz
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:51 $
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
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','nichols');
   end

   % Compute frequency response (grade = 2)
   [m,p,w,FocusInfo] = freqresp(getPrivateData(sys),2,wspec,false);
   m = permute(m,[2 3 1]);
   p = permute(p,[2 3 1]);

   % Adjust frequency range
   if isempty(wspec)
      % Clip to FOCUS and make W(1) and W(end) entire decades
      [w,m,p] = roundfocus('freq',FocusInfo.Focus,w,m,p);
   end

   % Set units
   magout = m;
   phase = (180/pi)*p;

else
   % Nichols plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
   try
      nicholsplot(varargin{:});
   catch E
      throw(E)
   end
end

function [svout,w] = sigma(varargin)
%SIGMA  Singular value plot of dynamic systems.
%
%   SIGMA(SYS) produces a singular value (SV) plot of the frequency response
%   of the dynamic system SYS. The frequency range and number of points are 
%   chosen automatically. See BODE for details on the notion of frequency 
%   in discrete time.
%
%   SIGMA(SYS,{WMIN,WMAX}) draws the SV plot for frequencies ranging between
%   WMIN and WMAX (in radians/second).
%
%   SIGMA(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the frequency response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   SIGMA(SYS,W,TYPE) or SIGMA(SYS,[],TYPE) draws the following
%   modified SV plots depending on the value of TYPE:
%          TYPE = 1     -->     SV of  inv(SYS)
%          TYPE = 2     -->     SV of  I + SYS
%          TYPE = 3     -->     SV of  I + inv(SYS) 
%   SYS should be a square system when using this syntax.
%
%   SIGMA(SYS1,SYS2,...,W,TYPE) draws the SV response of several systems
%   SYS1,SYS2,... on a single plot. The arguments W and TYPE are optional.
%   You can also specify a color, line style, and marker for each system, 
%   for example, 
%      sigma(sys1,'r',sys2,'y--',sys3,'gx').
%   
%   SV = SIGMA(SYS,W) and [SV,W] = SIGMA(SYS) return the singular values SV
%   of the frequency response (along with the frequency vector W if 
%   unspecified). No plot is drawn on the screen. The matrix SV has length(W) 
%   columns and SV(:,k) gives the singular values (in descending order) at 
%   the frequency W(k).
%
%   For additional graphical options for singular value plots, see SIGMAPLOT.
%
%   See also SIGMAPLOT, BODE, NICHOLS, NYQUIST, FREQRESP, LTIVIEW, DYNAMICSYSTEM.

%	Andrew Grace  7-10-90
%	Revised ACWG 6-21-92
%	Revised by Richard Chiang 5-20-92
%	Revised by W.Wang 7-20-92
%       Revised P. Gahinet 5-7-96
%       Revised A. DiVergilio 6-16-00
%       Revised K. Subbarao 10-11-01
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:03 $
ni = nargin;

% Handle various calling sequences
if nargout>0
   % Call with output arguments
   try
      [sysList,Extras] = DynamicSystem.parseRespFcnInputs(varargin);
      [sysList,wspec,type] = DynamicSystem.checkSigmaInputs(sysList,Extras);
   catch E
      throw(E)
   end
   sys = sysList(1).System;
   if (numel(sysList)>1 || numsys(sys)~=1),
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','sigma');
   end
   
   % Compute frequency response
   [svout,w,FocusInfo] = sigmaresp(getPrivateData(sys),type,wspec,false);
   if isempty(wspec)
      [w,svout] = roundfocus('freq',FocusInfo.Focus,w,svout);
   end

else
   % Singular Values plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
   try
      sigmaplot(varargin{:});
   catch E
      throw(E)
   end
end


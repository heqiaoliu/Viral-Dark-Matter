function [rout,kout] = rlocus(varargin)
%RLOCUS  Evans root locus.
%
%   RLOCUS(SYS) computes and plots the root locus of the single-input,
%   single-output LTI model SYS. The root locus plot is used to analyze 
%   the negative feedback loop
%
%                     +-----+
%         ---->O----->| SYS |----+---->
%             -|      +-----+    |
%              |                 |
%              |       +---+     |
%              +-------| K |<----+
%                      +---+
%
%   and shows the trajectories of the closed-loop poles when the feedback 
%   gain K varies from 0 to Inf.  RLOCUS automatically generates a set of 
%   positive gain values that produce a smooth plot.  
%
%   RLOCUS(SYS,K) uses a user-specified vector K of gain values.
%
%   RLOCUS(SYS1,SYS2,...) draws the root loci of several models SYS1,SYS2,... 
%   on a single plot. You can specify a color, line style, and marker for 
%   each model, for example:
%      rlocus(sys1,'r',sys2,'y:',sys3,'gx').
%
%   [R,K] = RLOCUS(SYS) or R = RLOCUS(SYS,K) returns the matrix R of
%   complex root locations for the gains K.  R has LENGTH(K) columns
%   and its j-th column lists the closed-loop roots for the gain K(j).  
% 
%   See RLOCUSPLOT for additional graphical options for root locus plots.
%
%   See also RLOCUSPLOT, SISOTOOL, POLE, ISSISO, LTI.

%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 7-8-89, 6-21-92 
%   Revised P. Gahinet 7-96
%   Revised A. DiVergilio 6-00
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:01 $
ni = nargin;
no = nargout;

% Handle various calling sequences
if no
   % Parse input list
   try
      [sysList,Extras] = DynamicSystem.parseRespFcnInputs(varargin);
      [sysList,GainVector] = DynamicSystem.checkRootLocusInputs(sysList,Extras);
   catch E
      throw(E)
   end
   sys = sysList(1).System;
   if (numel(sysList)>1 || numsys(sys)~=1),
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','rlocus');
   end
   [rout,kout] = rlocus(getPrivateData(sys),GainVector);

else
   % Root locus plot
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   varargin = argname2sysname(varargin,ArgNames);
   try
      rlocusplot(varargin{:});
   catch E
      throw(E)
   end
end


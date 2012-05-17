function [pout,zout] = pzmap(varargin)
%PZMAP  Pole-zero map of dynamic systems.
%
%   PZMAP(SYS) computes the poles and (transmission) zeros of the
%   dynamic system SYS and plots them in the complex plane. The poles 
%   are plotted as x's and the zeros are plotted as o's.  
%
%   PZMAP(SYS1,SYS2,...) shows the poles and zeros of several systems
%   SYS1,SYS2,... on a single plot. You can specify distinctive colors 
%   for each model, for example:
%      pzmap(sys1,'r',sys2,'y',sys3,'g')
%
%   [P,Z] = PZMAP(SYS) returns the poles and zeros of the system in two 
%   column vectors P and Z. No plot is drawn on the screen.  
%
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of dynamic systems, PZMAP plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   See PZPLOT for additional graphical options for pole/zero plots.
%
%   See also PZPLOT, POLE, ZERO, SGRID, ZGRID, RLOCUS, DYNAMICSYSTEM.

%	Clay M. Thompson  7-12-90
%	Revised ACWG 6-21-92, AFP 12-1-95, PG 5-10-96, ADV 6-16-00
%          Kamesh Subbarao 10-29-2001
%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:00 $
ni = nargin;

% Handle various calling sequences
if nargout
   % Parse input list
   if ni>1
      ctrlMsgUtils.error('Control:analysis:rfinputs01')
   end
   sys = varargin{1};
   if numsys(sys)~=1
      ctrlMsgUtils.error('Control:analysis:RequiresSingleModelWithOutputArgs','sigma');
   end
   try
      pout = pole(sys);
      zout = zero(sys);
   catch E
      ltipack.throw(E,'command','pzmap',class(sys))
   end
else
   % Call with graphical output
   ArgNames = cell(ni,1);
   for ct=1:ni
      ArgNames(ct) = {inputname(ct)};
   end
   % Assign vargargin names to systems if systems do not have a name
   varargin = argname2sysname(varargin,ArgNames);
   try
      pzplot(varargin{:});
   catch E
      throw(E)
   end
end

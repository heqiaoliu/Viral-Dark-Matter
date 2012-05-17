function [wnout,z,r] = damp(sys)
%DAMP  Natural frequency and damping of linear system dynamics.
%
%    [Wn,Z] = DAMP(SYS) returns vectors Wn and Z containing the natural 
%    frequencies and damping factors of the linear system SYS. For 
%    discrete-time models, the equivalent s-plane natural frequency and 
%    damping ratio of an eigenvalue lambda are:
%               
%       Wn = abs(log(lambda))/Ts ,   Z = -cos(angle(log(lambda))) .
%
%    Wn and Z are empty vectors if the sample time Ts is undefined.
%
%    [Wn,Z,P] = DAMP(SYS) also returns the poles P of SYS.
%
%    When invoked without left-hand arguments, DAMP prints the poles with 
%    their natural frequency and damping factor in a tabular format on the 
%    screen. The poles are sorted by increasing frequency.
%
%    See also POLE, ESORT, DSORT, PZMAP, ZERO.

%   J.N. Little, Clay M. Thompson, Pascal Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:48:44 $

% Compute the poles and their characteristics
try
   r = pole(sys);
catch E
   % Recast message from DAMP perspective
   if strcmp(E.identifier,'Control:general:NotSupportedModelsofClass')
      error(E.identifier,strrep(E.message,'pole','damp'))
   else
      throw(E)
   end
end
Ts = getTs_(sys);
[wn,z] = damp(r,Ts);

% Sort by increasing natural frequency
sr = size(r);
if Ts>=0
   for k=1:prod(sr(3:end))
      % RE: SORT does the right thing with NaNs
      [wn(:,k),perm] = sort(wn(:,k));
      r(:,k) = r(perm,k);
      z(:,k) = z(perm,k);
   end
else
   % Discrete system with unspecified Ts: sort by mag
   for k=1:prod(sr(3:end)),
      ifin = isfinite(r(:,k));
      r(ifin,k) = dsort(r(ifin,k));
   end
end

% Output
if nargout
   wnout = wn;
elseif length(sr)>2
   ctrlMsgUtils.error('Control:analysis:damp1');
else
   printdamp(r,wn,z,Ts)
end

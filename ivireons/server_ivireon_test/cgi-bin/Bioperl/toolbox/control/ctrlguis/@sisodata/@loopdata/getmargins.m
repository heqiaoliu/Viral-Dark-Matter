function Margins = getmargins(this,idxL)
% Computes stability margins of a given feedback loop.

%   Authors: P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $  $Date: 2008/06/13 15:14:02 $

% RE: not called unless OpenLoop is well defined
L = this.L(idxL);
if isempty(L)
   Margins = [];
   return
end

% Recompute margins if not already cached
if isempty(L.Margins)
   % Compute margins
   % RE: Units are: GM(absolute)  Pm(degree)  Wcg,Wcp(radians/sec)
   sw = warning('off','Control:transformation:StateSpaceScaling'); [lw,lwid] = lastwarn;
   [Gm,Pm,junk,Wcg,Wcp,isStable] = utGetMinMargins(allmargin(getOpenLoop(L)));
   warning(sw); lastwarn(lw,lwid);
   
   % Build and store result
   L.Margins = struct('Gm',Gm,'Pm',Pm,'Wcg',Wcg,'Wcp',Wcp,'Stable',isStable);
end

Margins = L.Margins;


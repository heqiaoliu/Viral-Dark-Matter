function rcvis = io2rcvis(this,rcflag,iovis)
%IO2RCVIS  Converts I/O visibility into row/column visibility for @axesgrid.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:15 $

switch rcflag
case 'r'
   rcvis = [iovis iovis];
   if strcmp(this.MagVisible,'off'),
      rcvis(:,1) = {'off'};
   end
   if strcmp(this.PhaseVisible,'off'),
      rcvis(:,2) = {'off'};
   end
   rcvis = reshape(rcvis',[2*length(iovis),1]);
case 'c'
   rcvis = iovis;
end

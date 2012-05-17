function updatelims(this)
%UPDATELIMS  Limit picker for root locus plots.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:23:50 $

% Unit circle visibility
if anydiscrete(this)
   set(this.BackgroundLines(:,:,4),'Visible','on')
else
   set(this.BackgroundLines(:,:,4),'Visible','off')
end
   
% RE: Scene prepared by ADJUSTVIEW
% Compute tick-friendly X and Y limits
updatelims(this.AxesGrid)

% Enforce symmetry of Y limits in auto mode
this.ylimconstr('Symmetry','on')
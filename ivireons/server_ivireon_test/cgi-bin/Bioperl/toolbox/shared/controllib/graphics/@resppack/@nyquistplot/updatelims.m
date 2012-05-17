function updatelims(this,CriticalFlag)
%UPDATELIMS  Custom limit picker.
%
%   UPDATELIMS(H) implements the "custom" limit manager. This limit manager
%   computes adequate X and Y range based on the data and frequency focus 
%   information.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:32 $

AxGrid = this.AxesGrid;
if nargin==1
   % Standard limit picker call
   % Let HG compute the limits
   updatelims(AxGrid)
else
   % UPDATELIMS(RESPPLOT,'critical') syntax: zoom around (-1,0)
   AxGrid.XLimMode = 'auto';
   AxGrid.YLimMode = 'auto';
   % Prepare view for limit picker
   for r=this.Responses(strcmp(get(this.Responses,'Visible'),'on'))'
      adjustview(r,'critical')
   end
   % Let HG compute the limits
   updatelims(AxGrid)
   % Go to manual limits
   AxGrid.XLimMode = 'manual';
   AxGrid.YLimMode = 'manual';
end

% Enforce symmetry of Y limits in auto mode
% See nyquist(zpk(1,1e3,1e-5)) and nyquist(zpk([0 0],[],1))
MinExtent = [-1e-8,1e-8];
if this.ShowFullContour
   this.ylimconstr('MinExtent',MinExtent,'Symmetry','on')
else
   this.ylimconstr('MinExtent',MinExtent)
end
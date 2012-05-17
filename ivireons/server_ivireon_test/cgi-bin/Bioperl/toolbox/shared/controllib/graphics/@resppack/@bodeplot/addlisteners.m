function addlisteners(this,L)
%  ADDLISTENERS  Installs additional listeners for @bodeplot class.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:03 $

if nargin == 1
  % Initialization. First install generic listeners
  this.generic_listeners;
  
  % Add @bodeplot specific listeners
  pvis = [this.findprop('MagVisible');...
	  this.findprop('PhaseVisible')];
  L = [handle.listener(this, pvis, 'PropertyPostSet', @LocalRefreshPlot)];
  set(L, 'CallbackTarget', this);
end
this.Listeners.addListeners(L);


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%
function LocalRefreshPlot(this, eventdata)
% Updates plot when the axes visibility changes.
% Notify @axesgrid of new visible subgrid
% RE: Issues ViewChanged event which triggers limit update
Rvis = this.io2rcvis('r',this.OutputVisible);
this.AxesGrid.RowVisible = Rvis;

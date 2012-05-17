function addlisteners(this, L)
%ADDLISTENERS  Installs listeners for @waveform class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:46 $

if nargin == 1
   % Install generic DATAVIEW listeners
   generic_listeners(this)
   
   % Source-related listeners
   % ATTN: SourceObject must be updated when DataSrc
   LocalSrcChgListener(this);
   L = handle.listener(this, this.findprop('DataSrc'), ...
         'PropertyPostSet', @(x,y) LocalSrcChgListener(this));
end

this.Listeners = [this.Listeners ; L];


% ----------------------------------------------------------------------------%
% Local Functions
% -------------------------------------------------------------------------

% ----------------------------------------------------------------------------%
% Purpose: Update SourceObject of DataSrcListener when DataSrc changes
% ----------------------------------------------------------------------------%
function LocalSrcChgListener(this)
delete(this.DataSrcListener);
if ~isempty(this.DataSrc)
   this.DataSrcListener = ...
      handle.listener(this.DataSrc, 'SourceChanged', @(x,y) LocalRedraw(this));
else
   this.DataSrcListener = [];
end

% ---------------------------------------------------------------------------%
% Purpose: Update waveform plot when receiving a SourceChanged event
% ----------------------------------------------------------------------------%
function LocalRedraw(this)
% Turn off DataChanged listener (for speed)
set(this.DataChangedListener,'Enable','off')

% Clear hsvchart data
clear(this.Data)

% Redraw response
if strcmp(this.Parent.Visible,'on') % speed-optimized
   draw(this,'nocheck')
end

% Reenable DataChanged listener
set(this.DataChangedListener,'Enable','on')


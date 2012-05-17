function addlisteners(this,L)
%ADDLISTENERS  Installs listeners.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:15 $

if nargin==1
   % Install built-in listeners
   L = [handle.listener(this, this.findprop('Model'),'PropertyPostSet', @LocalUpdate)];
   set(L, 'CallbackTarget', this);
end

this.Listeners = [this.Listeners ; L];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose:  Respond to change in model data
% ----------------------------------------------------------------------------%
function LocalUpdate(this, eventdata)
% Clear dependent data
reset(this)
% Notify peers
this.send('SourceChanged')
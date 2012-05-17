function addListeners(this)
% add listeners to keep parameters and zpk in sync

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2005/11/15 00:47:05 $

Listeners.Parameters =  handle.listener(this,this.findprop('Parameters'), ...
    'PropertyPostSet',{@LocalupdateZPK this});

this.Listeners = Listeners;

function LocalupdateZPK(es,ed,this)
this.updateZPK;


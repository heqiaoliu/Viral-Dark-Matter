function addListeners(this, LoopData)
% add listeners to keep parameters and zpk in sync

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:46:27 $

L = handle.listener(this,findprop(this,'PZGroup'),'PropertyPostSet',@LocalPZGroupChanged);
set(L,'CallbackTarget',this)
this.Listeners.PZGroup = L;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalPZGroupChanged %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalPZGroupChanged(this,event)
% Make dirty PZGROUPSpec
this.resetZPKParameterSpec;

function addlisteners(this,L)
%ADDLISTENERS  Installs listeners for @nyquistplot class.

%  Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:22:21 $
if nargin==1
   this.generic_listeners;
   
   % Listener to ShowFullContour
   L = handle.listener(this,findprop(this,'ShowFullContour'),...
      'PropertyPostSet',@LocalUpdateView);
   L.CallbackTarget = this;
end
this.Listeners.addListeners(L);

%------------------- Local Functions -------------------------------

function LocalUpdateView(this,eventdata)
% PostSet for ShowFullContour property
% Propagate settings
ShowFullContour = strcmp(eventdata.NewValue,'on');
for r=this.Responses'
   for v=r.View'
      v.ShowFullContour = ShowFullContour;
   end
end
% Redraw
draw(this)
function setTarget(this,NewTarget)
%SETTARGET  (Re)targets the Property Editor.

%   Author(s): A. DiVergilio, P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:12:57 $

if ~isequal(this.Target,NewTarget)
   % Unselect old target's axes  
   if ~isempty(this.Target) && ~this.Target.isBeingDestroyed
       CurrentAxes = getaxes(this.Target);
       if ~isactiveuimode(ancestor(CurrentAxes(1),'figure'),'Standard.EditPlot')
           set(getaxes(this.Target),'Selected','off')
       end
   end
   % Update property
   this.Target = NewTarget;
   % Listener management
   if isempty(NewTarget)
      % Delete target-dependent listeners
      this.TargetListeners = [];
      set(cat(1,this.Tabs.Contents),'TargetListeners',[])
   else
      % Listen for Target destruction
      L = handle.listener(NewTarget,'ObjectBeingDestroyed',@close);
      L.CallbackTarget = this;
      this.TargetListeners = L;
      
      % Populate tabs and sync data with new target
      NewTarget.edit(this)
      
      % Pack frame
      this.Java.Frame.pack;
      
      % Show which plot is selected
      NewAxes = getaxes(NewTarget);
      if ~isactiveuimode(ancestor(NewAxes(1),'figure'),'Standard.EditPlot')
          set(NewAxes,'Selected','on')
      end
   end
end

% Dialog visibility
f = this.Java.Frame;

% Used to force the dialog to spawn ontop of the figure
drawnow expose

if isempty(NewTarget)
   % If clearing Target, hide GUI
   awtinvoke(f,'setVisible(Z)',false)
else
   % Raise GUI
   awtinvoke(f,'setVisible(Z)',true)
   f.toFront
end
function show(h,varargin)
%SHOW  Brings up and points dialog to a particular container/constraint.

%   Authors: Bora Eryilmaz
%   Revised: A. Stothert, added focus traversal for tab order
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.7.4.7 $ $Date: 2009/02/06 14:16:37 $

% Initialize when first used
if isempty(h.Handles)
    % Build GUI frame
    h.Handles = h.build;
    % Listeners
    Containers = h.ContainerList;
    h.Listeners = [...
            handle.listener(h, h.findprop('Container'), ...
            'PropertyPostSet', @LocalContainer) ; ...
            handle.listener(h, h.findprop('Constraint'), ...
            'PropertyPostSet', @LocalConstraint); ...
            handle.listener(Containers, Containers(1).findprop('Visible'), ...
            'PropertyPostSet', @LocalVisible); ...
            handle.listener(h, 'ObjectBeingDestroyed', {@LocalDestroy h})];
    set(h.Listeners, 'CallbackTarget', h);
end

% Target editor
h.target(varargin{:});

% Make frame visible
Frame = h.Handles.Frame;
Frame.repaint;

% Used to force the dialog to spawn on top of the figure
drawnow expose

if Frame.isVisible
  % Raise window
  Frame.toFront;
else
  % Bring it up
  Host = handle( h.Container);
  hAx = Host.getaxes;
  centerfig(h.Handles.Frame, hAx(1).Parent);
  awtinvoke(Frame, 'setVisible(Z)', true);
  %Force parambox to update, as contents only update when visible
  LocalConstraintBox(h);
end
end


%% Logic to update container choice list. Triggered when container changes
function LocalContainer(h, eventData)
if ~isempty(eventData.NewValue)
    % Update container list
    h.refresh('Containers');
end
end

%% Logic to update constraint parameter box.
function LocalConstraint(h, eventData)
if ~isempty(eventData.NewValue) 
    % Update constraint popup list
    h.refresh('Constraints');

    % Update parameter box
    LocalConstraintBox(h);
    
    % Turn markers on for edited constraint
    h.Constraint.Selected = true;
    
    % Listener to Constraint move/resize using mouse.
    localAddTempListeners(h)
     
else
    % Detargeting: remove listeners
    localRemoveListeners(h);
end
end

%% Add temporary constraint listeners
function localAddTempListeners(h)
%
if ~isempty(h.TempListeners) && isvalid(h.TempListeners)
    delete(h.TempListeners)
end
h.TempListeners = addlistener(h.Constraint, 'ObjectBeingDestroyed', @(hSrc,hData) localConstraintDelete(hSrc,h));
end

%% Logic to update container list when any container's visibility
%  changes.
function LocalVisible(h, eventData)
% Current container list
if h.isVisible
    if isequal(h.Container,eventData.AffectedObject)
        % Targeted container is going invisible: retarget to first valid container
        h.target;
    else
        % Just update container list
        h.refresh('Containers');
    end
end
end

%% Updates constraint editor parameter box.
function LocalConstraintBox(h)
% Clean-up the parameter box

import com.mathworks.toolbox.control.util.*;

h.Handles.Frame.setDone(false);
if ~isempty(h.ParamEditor)
   % Clean up current editor settings
   if ishandle(h.ParamEditor.Listeners)
      delete(h.ParamEditor.Listeners);
   end
   h.ParamEditor = [];
end
ParamBox = h.Handles.ParamBox;
awtinvoke(ParamBox,'removeAll');
% Update parameters box content
h.ParamEditor = h.Constraint.getWidgets(h.Handles.ParamBox);
awtinvoke(ParamBox,'revalidate()');
awtinvoke(ParamBox,'repaint()');

%Set tab order
editorTabOrder = h.ParamEditor.tabOrder;
nTabOrder = numel(editorTabOrder);
tabOrder = javaArray('java.awt.Component',3+nTabOrder);
tabOrder(1) = h.Handles.ConstrSelect;
for ct = 2:2+nTabOrder-1
   tabOrder(ct) = editorTabOrder(ct-1);
end
tabOrder(1+nTabOrder+1)   = h.Handles.Handles{6};
tabOrder(1+nTabOrder+2) = h.Handles.Handles{7};
focusTraversal = MJGenericFocusTraversal(tabOrder);
awtinvoke(h.Handles.Frame,'setFocusTraversalPolicy(Ljava.awt.FocusTraversalPolicy;)',focusTraversal);

% Redraw
dim = awtinvoke(h.Handles.Frame,'getSize()');
if dim.width < 440 || dim.height < 275
    %Forces resize to some min dimensions.
    awtinvoke(h.Handles.Frame,'pack()');
end
end

%% Manage deletion of active constraint
function localConstraintDelete(hConstr,h)

if numel(h.ConstraintList) > 1
   %Remove deleted constraint from list
   idx = hConstr ~= h.ConstraintList;
   h.target(h.Container,h.ConstraintList(find(idx,1,'first')));
   h.ConstraintList = h.ConstraintList(idx);
   h.refresh('Constraints');
else
   %Deleted one and only constraint
   LocalDestroy([],[],h);
end
end

%% Deletes the editor dialog.
function LocalDestroy(eventSrc,eventData,h)

%Remove listeners
localRemoveListeners(h)
% Hide dialog
h.Handles.Frame.hide;
end

%% Helper function to remove listeners and dependencies
function localRemoveListeners(h)

if ~isempty(h.ParamEditor)
   delete(h.ParamEditor.Listeners);
end
h.ParamEditor = [];
delete(h.TempListeners);
h.TempListeners = [];
if ~isempty(h.Handles.ParamBox)
   ParamBox = h.Handles.ParamBox;
   awtinvoke(ParamBox,'removeAll');
   awtinvoke(ParamBox,'revalidate()');
   awtinvoke(ParamBox,'repaint()');
end
import com.mathworks.toolbox.control.util.*;
tabOrder    = javaArray('java.awt.Component',3);
tabOrder(1) = h.Handles.ConstrSelect;
tabOrder(2) = h.Handles.Handles{4};
tabOrder(3) = h.Handles.Handles{5};
focusTraversal = MJGenericFocusTraversal(tabOrder);
awtinvoke(h.Handles.Frame,'setFocusTraversalPolicy(Ljava.awt.FocusTraversalPolicy;)',focusTraversal);
end
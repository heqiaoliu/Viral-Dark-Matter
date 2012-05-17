classdef StepResponse < editconstr.absEditor
   % STEPRESPONSE  Editor panel class for Step response constraint
   %
   
   % Author(s): A. Stothert 25-Nov-2008
   % Copyright 2008-2009 The MathWorks, Inc.
   % $Revision: 1.1.8.2 $ $Date: 2009/12/07 20:44:29 $
   
   methods
      function this = StepResponse(SrcObj)
         this = this@editconstr.absEditor(SrcObj);
         this.Activated = true;
         this.setDisplayUnits('xunits','sec');
         this.setDisplayUnits('yunits','abs');
         this.Orientation = 'both';
      end
      
      function widgets = getWidgets(this,Container)
         %Import packages
         import com.mathworks.toolbox.control.plotconstr.*;
         
         % Definitions
         Prefs = cstprefs.tbxprefs;
         
         % Create widget
         labels    = javaArray('java.lang.String',9);
         labels(1) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqInitialValue'));
         labels(2) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqStepTime'));
         labels(3) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqRiseTime'));
         labels(4) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqSettlingTime'));
         labels(5) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqPercentOvershoot'));
         labels(6) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqFinalValue'));
         labels(7) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqPercentRise'));
         labels(8) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqPercentSettling'));
         labels(9) = java.lang.String(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepReqPercentUndershoot'));
         hPanel = StepResponseEditor(...
            labels, ...
            Prefs.JavaFontP);
         
         %Add widget to container
         awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',hPanel,java.awt.BorderLayout.CENTER);
         
         % Listeners: update edit boxes due to changes in constraint data
         Listener = handle.listener(this.Data,'DataChanged',{@localUpdate this hPanel});
         
         % Callbacks: update constraint due to edit changes
         awtinvoke(hPanel.getEditBox(1),'setEnabled(Z)',false) %Cant change initial value
         awtinvoke(hPanel.getEditBox(2),'setEnabled(Z)',false) %Cant change step time
         h = handle(hPanel.getEditBox(3),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'RiseTime'});
         Listener = [Listener; L];
         h = handle(hPanel.getEditBox(4),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'SettlingTime'});
         Listener = [Listener; L];
         h = handle(hPanel.getEditBox(5),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'PercentOvershoot'});
         Listener = [Listener; L];
         h = handle(hPanel.getEditBox(6),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'FinalValue'});
         Listener = [Listener; L];
         h = handle(hPanel.getEditBox(7),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'PercentRise'});
         Listener = [Listener; L];
         h = handle(hPanel.getEditBox(8),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'PercentSettling'});
         Listener = [Listener; L];
         h = handle(hPanel.getEditBox(9),'callbackproperties');
         L = handle.listener(h,'PropertyChange', {@localEdit this hPanel 'PercentUndershoot'});
         Listener = [Listener; L];
         
         %Store tab order
         tabOrder    = javaArray('java.awt.Component',9);
         tabOrder(1) = hPanel.getEditBox(1);
         tabOrder(2) = hPanel.getEditBox(6);
         tabOrder(3) = hPanel.getEditBox(2);
         tabOrder(4) = hPanel.getEditBox(3);
         tabOrder(5) = hPanel.getEditBox(7);
         tabOrder(6) = hPanel.getEditBox(4);
         tabOrder(7) = hPanel.getEditBox(8);
         tabOrder(8) = hPanel.getEditBox(5);
         tabOrder(9) = hPanel.getEditBox(9);
         
         % Save other handles
         widgets = struct(...
            'Panels', hPanel,...
            'Handles', hPanel,...
            'Listeners',Listener, ...
            'tabOrder', tabOrder);
         
         % Initialize text field values
         localUpdate([],[],this,hPanel,true);
      end
      function Str = describe(this, keyword)
         Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepResponseBound');
         
         if (nargin == 2) && strcmp(keyword, 'detail')
            XUnits = this.getDisplayUnits('xunits');
            Range = unitconv(this.Data.getData('xData'), ...
               this.Data.getData('xUnits'), ...
               XUnits);
            Range = Range(:);
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblStepResponseBoundFromTo',...
               sprintf('%0.3g',min(Range)), sprintf('%0.3g',max(Range)), XUnits);
         end
         if (nargin == 2) && strcmp(keyword, 'identifier')
            Str = 'StepResponse';
         end
      end
   end
end

%% Manage changes in the plotconstr object
function localUpdate(~,~,this,hPanel,forced)

if nargin < 5, forced = false; end
if ~forced && ~hPanel.isShowing
   %Quick return as not visible
   return
end

data = this.Requirement.getStepCharacteristics;
hPanel.getEditBox(1).setValue(data.InitialValue);
hPanel.getEditBox(2).setValue(data.StepTime);
hPanel.getEditBox(3).setValue(data.RiseTime);
hPanel.getEditBox(4).setValue(data.SettlingTime);
hPanel.getEditBox(5).setValue(data.PercentOvershoot);
hPanel.getEditBox(6).setValue(data.FinalValue);
hPanel.getEditBox(7).setValue(data.PercentRise);
hPanel.getEditBox(8).setValue(data.PercentSettling);
hPanel.getEditBox(9).setValue(data.PercentUndershoot);

%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(hPanel);
if ~isempty(hFrame), hFrame.setDone(true); end
end

function localEdit(hSrc,eventData,this,hPanel,WhatChanged)

if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
   %Quick return as numerical value didn't change
   return
end

hSrc     = handle(hSrc);  %MJNumericalTextField object
newValue = get(hSrc,'Value');
if isequal(newValue,eventData.JavaEvent.getOldValue)
   %Quick return as no update
   return
else
   newValue = ctrluis.convertJavaComplexToDouble(newValue);
end

if ~isreal(newValue) || ~isscalar(newValue) || ~isfinite(newValue)
   %Invalid setting
   changeAccepted = false;
else
   stepChar = this.Requirement.getStepCharacteristics;
   stepChar.(WhatChanged) = newValue;
   changeAccepted = this.Requirement.setStepCharacteristics(stepChar);
end

if ~changeAccepted
   %Revert to old values
   localUpdate([],[],this,hPanel);
end
end

classdef SettlingTime < editconstr.absEditor
    % SETTLINGTIME  Editor panel class for a settling time constraint
    %
    
    % Author(s): A. Stothert 07-Jan-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:54 $
    
    methods
        function this = SettlingTime(SrcObj)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','sec');  %x=time, y=unused
            this.setDisplayUnits('yunits','none');
        end
        
        function widgets = getWidgets(this,Container)
            %Import packages
            import java.awt.*;
            import javax.swing.* ;
            import javax.swing.border.*;
            import com.mathworks.mwswing.*;
            import com.mathworks.toolbox.control.util.*;
            
            % Definitions
            Prefs = cstprefs.tbxprefs;
            
            % Labels
            P1 = MJPanel(java.awt.BorderLayout(0,0));
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',P1,java.awt.BorderLayout.WEST);
            Lbl = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblSettlingTimeLEQ'));
            awtinvoke(P1,'add(Ljava.awt.Component;)',Lbl);
            awtinvoke(Lbl,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            
            % Parameters
            P2 = MJPanel(java.awt.BorderLayout(0,0));
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',P2,java.awt.BorderLayout.CENTER);
            % Settling time bound
            T = MJNumericalTextField();
            awtinvoke(T,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(T,'setName(Ljava.lang.String;)',java.lang.String('edtTime'));
            awtinvoke(P2,'add(Ljava.awt.Component;Ljava.lang.Object;)',T,java.awt.BorderLayout.CENTER);
            
            % Listeners: update widgets due to constraint data changes
            Listeners = handle.listener(this.Data,'DataChanged',{@localUpdate this T});
            
            % Callbacks: update constraint data due to widget changes
            h = handle(T,'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localEdit this T});
            Listeners = [Listeners; L];
            
            % Save other handles
            widgets = struct(...
                'Panels',{{P1;P2}},...
                'Handles',{{Lbl;T}},...
                'Listeners',Listeners, ...
                'tabOrder', T);
            
            % Initialize text field values
            localUpdate([],[],this,T,true);
        end
        function Str = describe(this, keyword)
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblSettlingTime');
            
            if (nargin == 2) && strcmp(keyword, 'detail')
                str1 = unitconv(this.Data.getData('xData'), ...
                    this.Data.getData('xUnits'), this.getDisplayUnits('xunits'));
                Str = sprintf('%s (%0.3g)', Str, str1);
            end
            if (nargin == 2) && strcmp(keyword, 'identifier')
                Str = 'SettlingTime';
            end
            
        end
    end
end

%% Update displayed value when constraint data changes
function localUpdate(~,~,this,T,forced)

if nargin < 5, forced = false; end
if ~forced && ~T.isShowing
   %Quick return as not visible
   return
end

T.setValue(unitconv(this.Data.getData('xData'),this.Data.getData('xunits'), this.getDisplayUnits('xunits')));
%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(T);
if ~isempty(hFrame), hFrame.setDone(true); end
end

%% Manage edit box actions
function localEdit(~,eventData,this,T)
% Update settling value

if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
   %Quick return as numerical value didn't change
   return
end

value = eventData.JavaEvent.getNewValue;
if isequal(value,eventData.JavaEvent.getOldValue)
   %Quick return as no update
   return
else
   value = ctrluis.convertJavaComplexToDouble(value);
end

if ~isscalar(value) || ~isreal(value) || ~isfinite(value) || value<=0,
   %Invalid value revert to old value
   localUpdate([],[],this,T);
   return
end

% Update settling time
T = this.recordon;
this.Data.setData('xdata',unitconv(value,this.getDisplayUnits('xunits'),this.Data.getData('xUnits')));
this.recordoff(T);
end
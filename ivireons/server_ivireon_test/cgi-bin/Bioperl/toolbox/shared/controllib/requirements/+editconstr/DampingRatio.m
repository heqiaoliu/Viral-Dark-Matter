classdef DampingRatio < editconstr.absEditor
    % DAMPINGRATIO  Editor panel class for a damping ratio constraint
    %
    
    % Author(s): A. Stothert 05-Jan-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:48 $
    
    properties
        Type = 'damping';   %What type of editor to display, {'damping','overshoot'}.
        %Default is overshoot
    end
    
    methods
        function this = DampingRatio(SrcObj,Type)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','abs');  %x=damping ratio, y=unused
            this.setDisplayUnits('yunits','none');
            if nargin >= 2
                this.Type = Type;
            end
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
            if strcmpi(this.Type,'damping')
                Lbl = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblDampingRatioGEQ'));
            else
                Lbl = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPercentOvershootLEQ'));
            end
            awtinvoke(P1,'add(Ljava.awt.Component;)',Lbl);
            awtinvoke(Lbl,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            
            % Parameters
            P2 = MJPanel(java.awt.BorderLayout(0,0));
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',P2,java.awt.BorderLayout.CENTER);
            % Bound value
            T = MJNumericalTextField();
            awtinvoke(T,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(T,'setName(Ljava.lang.String;)',java.lang.String('edtOvershoot'));
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
            if strcmp(this.Type,'damping')
                Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblDampingRatio');
            else
                Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPercentOvershoot');
            end
            
            if (nargin == 2) && strcmp(keyword, 'detail')
                if strcmp(this.Type, 'damping')
                    Str = sprintf('%s (%0.3g)', Str, this.Data.getData('xData'));
                else
                    Str = sprintf('%s (%0.3g)', Str, this.Requirement.overshoot);
                end
            end
            
            if (nargin == 2) && strcmp(keyword, 'identifier')
                if strcmp(Constr.Format, 'damping')
                    Str = 'DampingRatio';
                else
                    Str = 'PercentOvershoot';
                end
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

if strcmpi(this.Type,'damping')
   T.setValue(this.Data.getData('xData'));
else
   T.setValue(this.Requirement.overshoot);
end
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

DampFormat = strcmpi(this.Type,'damping');
if ~isscalar(value) || ~isreal(value) || ~isfinite(value) || DampFormat && value>1
   %Invalid value revert to old value
   localUpdate([],[],this,T);
   return
end

% Have valid value to update
if ~DampFormat
   %Convert from overshoot to damping ratio
   if value <= 0
      value = 1;
   else
      value = min(value,100);
      t = (log(value/100)/pi)^2;
      value = sqrt(t/(1+t));
   end
end
T = this.recordon;
%Update numerical value and store transaction for undo
this.Data.setData('xData',max(value,eps));
this.recordoff(T);
end
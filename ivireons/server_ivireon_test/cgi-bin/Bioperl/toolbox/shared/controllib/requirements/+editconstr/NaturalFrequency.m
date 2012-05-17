classdef NaturalFrequency < editconstr.absEditor
    % NATURALFREQUENCY Editor panel class for a natural frequency constraint
    %
    
    % Author(s): A. Stothert 07-Jan-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:50 $
    
    
    methods
        function this = NaturalFrequency(SrcObj,Type)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','rad/sec');  %x=frequency, y=not used
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
            Lbl = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNaturalFrequency'));
            awtinvoke(Lbl,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(P1,'add(Ljava.awt.Component;)',Lbl);
            
            % Parameters
            P2 = MJPanel(java.awt.BorderLayout(0,0));
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',P2,java.awt.BorderLayout.CENTER);
            
            % Upper/lower
            C = MJComboBox;
            awtinvoke(C,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(C,'setName(Ljava.lang.String;)',java.lang.String('cmbLessThan'));
            awtinvoke(C,'removeAllItems');
            awtinvoke(C,'addItem(Ljava.lang.Object;)',ctrlMsgUtils.message('Controllib:graphicalrequirements:lblAtMost'));
            awtinvoke(C,'addItem(Ljava.lang.Object;)',ctrlMsgUtils.message('Controllib:graphicalrequirements:lblAtLeast'));
            awtinvoke(P2,'add(Ljava.awt.Component;Ljava.lang.Object;)',C,java.awt.BorderLayout.WEST);
            % Frequency bound
            T = MJNumericalTextField;
            awtinvoke(T,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(T,'setName(Ljava.lang.String;)',java.lang.String('edtFrequency'));
            awtinvoke(P2,'add(Ljava.awt.Component;Ljava.lang.Object;)',T,java.awt.BorderLayout.CENTER);
            
            % Listeners: update widgets due to constraint data changes
            Listeners = handle.listener(this.Data,'DataChanged',{@localUpdate this T C});

            % Callbacks: update constraint data due to widget changes
            h = handle(C,'callbackproperties');
            L = handle.listener(h,'ItemStateChanged', {@localSetType this C});
            Listeners = [Listeners; L];
            h = handle(T,'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localEditFrequency this T C});
            Listeners = [Listeners; L];
            
            %Store tab order
            tabOrder    = javaArray('java.awt.Component',2);
            tabOrder(1) = C;
            tabOrder(2) = T;
            
            % Save other handles
            widgets = struct(...
                'Panels',{{P1;P2}},...
                'Handles',{{Lbl;T;C}},...
                'Listeners',Listeners, ...
                'tabOrder', tabOrder);
            
            % Initialize text field values
            localUpdate([],[],this,T,C,true);
        end
        function Str = describe(this, keyword)
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNaturalFrequency');
            
            if (nargin == 2) && strcmp(keyword, 'detail')
                str1 = unitconv(this.Data.getData('xData'), ...
                    this.Data.getData('xUnits'), this.getDisplayUnits('xunits'));
                Str = sprintf('%s (%0.3g)', Str, str1);
            end
            
            if (nargin == 2) && strcmp(keyword, 'identifier')
                Str = 'NaturalFrequency';
            end
        end
    end
end

%% Update displayed value when constraint data changes
function localUpdate(~,~,this,T,C,forced)

if nargin < 6, forced = false; end
if ~forced && ~T.isShowing
   %Quick return as not visible
   return
end

%Update value
value = unitconv(this.Data.getData('xData'),...
   this.Data.getData('xUnits'),this.getDisplayUnits('xunits'));
T.setValue(value)
% Updates popup
if strcmp(this.Data.getData('Type'),'upper')
    awtinvoke(C,'setSelectedIndex(I)',0);
else
    awtinvoke(C,'setSelectedIndex(I)',1);
end

%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(T);
if ~isempty(hFrame), hFrame.setDone(true); end
end

%% Manage changes in the combobox
function localSetType(~,eventData,this,C)

if( isequal(eventData.JavaEvent.getStateChange,java.awt.event.ItemEvent.SELECTED))
   % Switch constraint type
   T = this.recordon;
   T.Name = ctrlMsgUtils.message('Controllib:graphicalrequirements:msgFlipConstraint');
   T.Transaction.Name = ctrlMsgUtils.message('Controllib:graphicalrequirements:msgFlipConstraint');
   if C.getSelectedIndex==0,
      this.Data.setData('Type','upper');
   else
      this.Data.setData('Type','lower');
   end
   this.recordoff(T);
end
end

%% Manage changes in the natural frequency edit box
function localEditFrequency(~,eventData,this,T,C)

if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
   %Quick return as numerical value didn't change
   return
end

newValue = T.getValue;
if isequal(newValue,eventData.JavaEvent.getOldValue)
   %Quick return as no update
   return
else
   newValue = ctrluis.convertJavaComplexToDouble(newValue);
end

newValue = unitconv(newValue,this.getDisplayUnits('xunits'),this.Data.getData('xUnits'));
if ~isscalar(newValue) || ~isreal(newValue) || ~isfinite(newValue) || newValue <= 0
   %Invalid value revert to old value
   localUpdate([],[],this,T,C);
   return
end

% Update frequency
T = this.recordon;
this.Data.setData('xData',newValue);
this.recordoff(T);
end

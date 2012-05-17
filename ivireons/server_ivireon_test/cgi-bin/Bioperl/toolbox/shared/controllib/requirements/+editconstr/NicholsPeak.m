classdef NicholsPeak < editconstr.absEditor
    % NICHOLSPEAK  Editor panel class for closed loop peak gain constraint
    %
    
    % Author(s): A. Stothert 05-Jan-2009
    % Copyright 2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:52 $
    
    properties
        Type = 'nichols';   %What type of editor to display, {'nichols'}.
        %Nichols type has extra edit field for origin.
        %Default is Nichols
    end
    
    properties(SetObservable, AbortSet)
        Origin   %Phase location to display constraint on a nichols plot
    end
    
    methods
        function this = NicholsPeak(SrcObj,Type)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','deg');  %x=phase, y=gain as on Nichols plot
            this.setDisplayUnits('yunits','dB');
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
            GL_21 = java.awt.GridLayout(2,1,0,3);
            
            % Modified Labels and TextFields
            Lbls = cell(2,2); % Info and units
            T = cell(2,1); % Data input
            
            % Main Panel in the Center of the Container (Frame)
            P1 = MJPanel(java.awt.BorderLayout(0,0));
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',P1,java.awt.BorderLayout.CENTER);
            
            % Dialog information labels
            P2 = MJPanel(GL_21);
            W = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblClosedLoopPeakGainLEQ'));
            Lbls{1,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(P2,'add(Ljava.awt.Component;)',W);
            W = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblLocatedAt'));
            Lbls{2,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(P2,'add(Ljava.awt.Component;)',W);
            awtinvoke(P1,'add(Ljava.awt.Component;Ljava.lang.Object;)',P2, java.awt.BorderLayout.WEST);
            
            % Dialog data input
            P3 = MJPanel(GL_21);
            W = MJNumericalTextField;
            T{1,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('edtGain'));
            awtinvoke(P3,'add(Ljava.awt.Component;)',W);
            W = MJNumericalTextField;
            T{2,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('edtLocation'));
            awtinvoke(P3,'add(Ljava.awt.Component;)',W);
            awtinvoke(P1,'add(Ljava.awt.Component;Ljava.lang.Object;)',P3, java.awt.BorderLayout.CENTER);
            
            % Listeners: update panel due to constraint data changes
            Listener = handle.listener(this.Data,'DataChanged',{@localUpdate this T});
            
            % Callbacks: update constraint data due to Panel changes
            h = handle(T{1,1},'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localEditGain this T});
            Listener = [Listener; L];
            h = handle(T{2,1},'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localEditOrigin this T});
            Listener = [Listener; L];
            
            %Store tab order
            tabOrder    = javaArray('java.awt.Component',2);
            tabOrder(1) = T{1,1};
            tabOrder(2) = T{2,1};
            
            % Save other handles
            widgets = struct(...
                'Panels', {{P1;P2;P3}}, ...
                'Handles', {{Lbls;T}}, ...
                'Listeners', Listener, ...
                'tabOrder', tabOrder);
            
            % Initialize text field values
            localUpdate([],[],this,T,true);
        end
        function Str = describe(this, keyword)
            
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblClosedLoopPeakGain');
            
            if (nargin == 2) && strcmp(keyword, 'detail')
                str1 = unitconv(this.Data.getData('yData'), this.Data.getData('yUnits'), this.getDisplayUnits('yunits'));
                str2 = unitconv(this.Data.getData('xData'), this.Data.getData('xUnits'), this.getDisplayUnits('xunits'));
                Str = sprintf('%s (%0.3g at %0.3g)', Str, str1, str2);
            end
            
            if (nargin == 2) && strcmp(keyword, 'identifier')
                Str = 'CLPeakGain';
            end
        end
    end
end

%% Update displayed value when constraint data changes
function localUpdate(~,~,this,T,forced)

if nargin < 5, forced = false; end
if ~forced && ~T{1,1}.isShowing
    %Quick return as not visible
    return
end

XUnits = this.Data.getData('xUnits');   %x=phase, y=gain
YUnits = this.Data.getData('yUnits');
Gain   = unitconv(this.Data.getData('yData'), YUnits, this.getDisplayUnits('yunits'));
Origin = unitconv(this.Data.getData('xData'), XUnits, this.getDisplayUnits('xunits'));

T{1,1}.setValue(Gain);
T{2,1}.setValue(Origin);
%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(T{1,1});
if ~isempty(hFrame), hFrame.setDone(true); end
end

%% Manage changes in gain edit field
function localEditGain(~,eventData, this, T)

if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
    %Quick return as numerical value didn't change
    return
end

newValue = T{1,1}.getValue;
if isequal(newValue,eventData.JavaEvent.getOldValue)
    %Quick return as no update
    return
else
    newValue = ctrluis.convertJavaComplexToDouble(newValue);
end

v = unitconv(newValue, this.getDisplayUnits('yunits'), this.Data.getData('yUnits'));
vabs = unitconv(newValue, this.Data.getData('yUnits'), 'abs');
if ~isscalar(newValue) || ~isreal(newValue) || ~isfinite(newValue) || vabs <= 0
    %Invalid value revert to old value
    localUpdate([],[],this,T);
    return
end

% Update gain margin
R = this.recordon;
this.Data.setData('yData',v);
this.recordoff(R);
end

%% Manage changes in location edit field
function localEditOrigin(~, eventData, this, T)

if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
    %Quick return as numerical value didn't change
    return
end

newValue = T{2,1}.getValue;
if isequal(newValue,eventData.JavaEvent.getOldValue)
    %Quick return as no update
    return
else
    newValue = ctrluis.convertJavaComplexToDouble(newValue);
end

newValue = unitconv(newValue, this.getDisplayUnits('xunits'), 'deg');
if ~isscalar(newValue) || ~isreal(newValue) || ~isfinite(newValue)
    %Invalid value revert to old value
    localUpdate([],[],this,T);
    return
end

% Phase margin origin should sit at -180 + 360k (in deg) for some k,
% so that the initial phase margin origin is closest to the mouse position.
sgnPhaOrig = (newValue >= 0) - (newValue < 0);

% Update phase margin origin (in deg)
newValue = sgnPhaOrig * (abs(newValue) + 180 - rem(abs(newValue),360));
oldValue = unitconv(this.Data.getData('xData'),this.Data.getData('xUnits'),'deg');
if isequal(oldValue,newValue)
    %No change revert to old value
    localUpdate([],[],this,T)
else
    R = this.recordon;
    this.Data.setData('xData',unitconv(newValue,'deg',this.Data.getData('xUnits')));
    this.recordoff(R);
end
end
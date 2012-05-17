classdef GainPhaseMargin < editconstr.absEditor
    % GAINPHASEMARIN  Editor panel class for gain & phase margin constraint
    %
    
    % Author(s): A. Stothert 25-Nov-2008
    % Copyright 2008-2009 The MathWorks, Inc.
    % $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:49 $
    
    properties
        Type = 'bode';   %What type of editor to display, {'bode','nichols'}.
                         %Nichols type has extra edit field for origin. 
                         %Default is bode
    end
    
    properties(SetObservable, AbortSet)
        Origin   %Phase location to display constraint on a nichols plot
    end
    
    methods
        function this = GainPhaseMargin(SrcObj,Type)
            this = this@editconstr.absEditor(SrcObj);
            this.Activated = true;
            this.setDisplayUnits('xunits','deg');  %x=phase, y=gain as on Nichols plot
            this.setDisplayUnits('yunits','dB');
            if nargin >= 2
                this.Type = Type;
            end
        end
        
        function widgets = getWidgets(this,Container)
            %Import java packages
            import java.awt.*;
            import javax.swing.* ;
            import javax.swing.border.*;
            import com.mathworks.mwswing.*;
            import com.mathworks.toolbox.control.util.*;
            
            % Definitions
            Prefs = cstprefs.tbxprefs;
            if strcmp(this.Type,'nichols')
                %Labels and TextFields
                Grid = java.awt.GridLayout(3,1,0,3);
                Lbls = cell(3,2); % Checkboxes and Labels
                T    = cell(3,1); % Data input
            else
                %Labels and TextFields
                Grid = java.awt.GridLayout(2,1,0,3);
                Lbls = cell(2,2); % Checkboxes and Labels
                T    = cell(2,1); % Data input
            end
            
            % Main Panel in the Center of the Container (Frame)
            P1 = MJPanel(java.awt.BorderLayout(0,0));
            awtinvoke(Container,'add(Ljava.awt.Component;Ljava.lang.Object;)',P1,java.awt.BorderLayout.CENTER);
            
            % Dialog information labels
            P2 = MJPanel(Grid);
            W = MJCheckBox(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblGainMarginGEQ'));
            Lbls{1,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('chkGain'));
            awtinvoke(P2,'add(Ljava.awt.Component;)',W);
            W = MJCheckBox(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblPhaseMarginGEQ'));
            Lbls{2,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('chkPhase'));
            awtinvoke(P2,'add(Ljava.awt.Component;)',W);
            if strcmp(this.Type,'nichols')
                W = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblLocatedAt'));
                Lbls{3,1} = W;
                awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
                awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('lblLocation'));
                awtinvoke(P2,'add(Ljava.awt.Component;)',W);
            end
            awtinvoke(P1,'add(Ljava.awt.Component;Ljava.lang.Object;)',P2, java.awt.BorderLayout.WEST);
                
            % Dialog data input
            P3 = MJPanel(Grid);
            W = MJNumericalTextField;
            T{1,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('edtGain'));
            awtinvoke(P3,'add(Ljava.awt.Component;)',W);
            W = MJNumericalTextField;
            T{2,1} = W;
            awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
            awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('edtPhase'));
            awtinvoke(P3,'add(Ljava.awt.Component;)',W);
            if strcmp(this.Type,'nichols')
                W = MJNumericalTextField;
                T{3,1} = W;
                awtinvoke(W,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
                awtinvoke(W,'setName(Ljava.lang.String;)',java.lang.String('edtLocation'));
                awtinvoke(P3,'add(Ljava.awt.Component;)',W);
            end
            awtinvoke(P1,'add(Ljava.awt.Component;Ljava.lang.Object;)',P3, java.awt.BorderLayout.CENTER);
            
            % Listeners: update table due to constraint data changes
            Listener = handle.listener(this.Data,'DataChanged',{@localUpdate this T Lbls});
            if strcmp(this.Type,'nichols')
                localAddOriginUpdate(this,T,Lbls);
            end
                        
            % Callbacks: update constraint data due to table changes
            h = handle(T{1,1},'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localEditMargin this T Lbls 'gainmargin'});
            Listener = [Listener; L];
            h = handle(T{2,1},'callbackproperties');
            L = handle.listener(h,'PropertyChange', {@localEditMargin this T Lbls 'phasemargin'});
            Listener = [Listener; L];
            h = handle(Lbls{1,1},'callbackproperties');
            L = handle.listener(h,'ItemStateChanged', {@localEnableMargin this T 'gainmargin'});
            Listener = [Listener; L];
            h = handle(Lbls{2,1},'callbackproperties');
            L = handle.listener(h,'ItemStateChanged', {@localEnableMargin this T 'phasemargin'});
            Listener = [Listener; L];
            
            if strcmp(this.Type,'nichols')
                %Store tab order
                tabOrder    = javaArray('java.awt.Component',5);
                tabOrder(1) = Lbls{1,1};
                tabOrder(2) = T{1,1};
                tabOrder(3) = Lbls{2,1};
                tabOrder(4) = T{2,1};
                tabOrder(5) = T{3,1};
                
                h = handle(T{3,1},'callbackproperties');
                L = handle.listener(h,'PropertyChange', {@localEditLocation this T Lbls});
                Listener = [Listener; L];
            else
                %Store tab order
                tabOrder    = javaArray('java.awt.Component',4);
                tabOrder(1) = Lbls{1,1};
                tabOrder(2) = T{1,1};
                tabOrder(3) = Lbls{2,1};
                tabOrder(4) = T{2,1};
            end
            
            % Save other handles
            widgets = struct(...
                'Panels', {{P1;P2;P3}}, ...
                'Handles', {{Lbls;T}}, ...
                'Listeners', Listener, ...
                'tabOrder', tabOrder);
            
            % Initialize text field values
            localUpdate([],[],this, T, Lbls, true);
        end
        function Str = describe(this,keyword)
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblGainPhaseMargins');
            if (nargin == 2) && strcmp(keyword, 'detail')
                MarginPha  = this.Data.getData('xdata');
                MarginGain = this.Data.getData('ydata');
                gainphase  = this.Data.getData('type');
                Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:lblGainPhase');
                if strcmp(gainphase,'gain') || strcmp(gainphase,'both') 
                    strGM = unitconv(MarginGain, this.Data.getData('yUnits'), this.getDisplayUnits('yunits'));
                    Str = sprintf('%s \n GM > %0.3g', Str, strGM);
                end
                if strcmp(gainphase,'phase') || strcmp(gainphase,'both')
                    strPM = unitconv(MarginPha, this.Data.getData('xUnits'), this.getDisplayUnits('xunits'));
                    Str = sprintf('%s \n PM > %0.3g', Str, strPM);
                end
            end
            if (nargin == 2) && strcmp(keyword, 'identifier')
                Str = 'GPMargins';
            end
        end
    end
end

%% Manage changes in margin edit fields
function localEditMargin(~, eventData, this, T, Lbls, EditWhat)

if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
   %Quick return as numerical value didn't change
   return
end

switch EditWhat
   case 'gainmargin'
      units = {this.getDisplayUnits('yunits'), this.Data.getData('yUnits')};
      fld   = 'yData';
      idx   = 1;
   case 'phasemargin'
      units = {this.getDisplayUnits('xunits'),this.Data.getData('xUnits')};
      fld   = 'xData';
      idx   = 2;
end

newValue = T{idx,1}.getValue;
if isequal(newValue,eventData.JavaEvent.getOldValue)
   %Quick return as no update
   return
else
   newValue = ctrluis.convertJavaComplexToDouble(newValue);
end

newValue = unitconv(newValue, units{1}, units{2});
if ~isscalar(newValue) || ~isreal(newValue) || ~isfinite(newValue) || newValue<=0 || newValue > 90
   %Invalid value revert to old value
   localUpdate([],[],this,T, Lbls);
   return
end

% Update the margin (in dB)
R = this.recordon;
this.Data.setData(fld,newValue)
this.recordoff(R);
end

%% Manage changes in margin check boxes
function localEnableMargin(~, eventData, this, T, EnableWhat)

switch EnableWhat
    case 'gainmargin'
        editedPhase = false;
        idx = 1;
    case 'phasemargin'
        editedPhase = true;
        idx = 2;
end

%Is the request and enable?
request = eventData.Source.isSelected;
%Modify gainphase property based on current state, edited checkbox, and
%checkbox state
switch this.Data.getData('type')
    case 'gain'
        if editedPhase && request
            this.Data.setData('type','both');
        end
        if ~editedPhase && ~request
            this.Data.setData('type','none');
        end
    case 'phase'
        if editedPhase && ~request
            this.Data.setData('type','none');
        end
        if ~editedPhase && request
            this.Data.setData('type','both');
        end
    case 'both'
        if editedPhase && ~request
            this.Data.setData('type','gain');
        end
        if ~editedPhase && ~request
            this.Data.setData('type','phase');
        end
    case 'none'
        if editedPhase && request
            this.Data.setData('type','phase');
        end
        if ~editedPhase && request 
            this.Data.setData('type','gain');
        end
end

if eventData.Source.isSelected
   %Enable edit box
   awtinvoke(T{idx,1},'setEnabled(Z)',true)
else
   %Disable edit box
   awtinvoke(T{idx,1},'setEnabled(Z)', false);
end
end

%% Manage changes in location edit boxes
function localEditLocation(~, eventData, this, T, Lbls)
if ~isempty(eventData) && ~strcmp(eventData.JavaEvent.getPropertyName,'numValue')
   %Quick return as numerical value didn't change
   return
end

newValue = T{3,1}.getValue;
if isequal(newValue,eventData.JavaEvent.getOldValue)
   %Quick return as no update
   return
else
   newValue = ctrluis.convertJavaComplexToDouble(newValue);
end

newValue = unitconv(newValue, this.getDisplayUnits('xunits'), 'deg');
if ~isscalar(newValue) || ~isreal(newValue) || ~isfinite(newValue) 
   %Invalid value revert to old value
   localUpdate([],[],this,T,Lbls);
   return
end

% Phase margin origin should sit at -180 + 360k (in deg) for some k,
% so that the initial phase margin origin is closest to the mouse position.
sgnPhaOrig = (newValue >= 0) - (newValue < 0);
   
% Update phase margin origin (in deg)
newValue = sgnPhaOrig * (abs(newValue) + 180 - rem(abs(newValue),360));
if isequal(this.Origin,newValue)
   %No change revert to old value
   localUpdate([],[],this,T,Lbls)
else
   R = this.recordon;
   this.Origin = sgnPhaOrig * (abs(newValue) + 180 - rem(abs(newValue),360));
   this.recordoff(R);
end
end

%% Update displayed value when constraint data changes
function localUpdate(~,~,this,T,Lbls, forced)

if nargin < 6, forced = false; end
if ~forced && ~T{1,1}.isShowing
   %Quick return as not visible
   return
end

%Set edit fields
MarginPha  = unitconv(this.Data.getData('xData'), ...
    this.Data.getData('xUnits'), this.getDisplayUnits('xunits'));
MarginGain = unitconv(this.Data.getData('yData'), ...
    this.Data.getData('yUnits'), this.getDisplayUnits('yunits'));
T{1,1}.setValue(MarginGain);
T{2,1}.setValue(MarginPha);
if strcmp(this.Type,'nichols')
    Origin = unitconv(this.Origin, 'deg', this.getDisplayUnits('xunits'));
    T{3,1}.setValue(Origin);
end

%Set checkboxes according to constraint properties
gainphase = this.Data.getData('Type');
if strcmp(gainphase,'gain') || strcmp(gainphase,'both')
    awtinvoke(T{1,1},'setEnabled(Z)',true);
    awtinvoke(Lbls{1,1},'setSelected(Z)',true);
else
    awtinvoke(T{1,1},'setEnabled(Z)',false);
    awtinvoke(Lbls{1,1},'setSelected(Z)',false);
end
if strcmp(gainphase,'phase') || strcmp(gainphase,'both')
    awtinvoke(T{2,1},'setEnabled(Z)',true);
    awtinvoke(Lbls{2,1},'setSelected(Z)',true);
else
    awtinvoke(T{2,1},'setEnabled(Z)',false);
    awtinvoke(Lbls{2,1},'setSelected(Z)',false);
end

%Set frame done state to true, only used for testing
import com.mathworks.toolbox.control.util.*;
hFrame = ExplorerUtilities.getFrame(T{1,1});
if ~isempty(hFrame), hFrame.setDone(true); end
end

function localAddOriginUpdate(this,T,Lbls)
%Local function to avoid problems with anonymous function copying workspace
addlistener(this,'Origin','PostSet',@(hSrc,hData) localUpdate([],[],this,T,Lbls));
end

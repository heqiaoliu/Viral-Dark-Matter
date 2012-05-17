function thisTab = lagpanel(this,h)

% Copyright 2004-2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import java.awt.*
import com.mathworks.mwswing.*;
import javax.swing.*;

%% Build freq panel
h.Handles.LagPanel = localBuildPanel(h,this);
thisTab = struct('Name','Domain','Handles',[]);
thisTab.Name = 'Domain';
h.Tabs = [h.Tabs; thisTab];
outerLagPanel = MJPanel(BorderLayout);
outerLagPanel.add(h.Handles.LagPanel,BorderLayout.CENTER);
outerLagPanel.setBorder(BorderFactory.createEmptyBorder(10,5,5,5));
if h.Handles.TabPane.isValid
    awtinvoke(h.Handles.TabPane,'add(Ljava/lang/String;Ljava/awt/Component;)',...
        java.lang.String(xlate('Define Lags')),outerLagPanel);
else
    h.Handles.TabPane.add(xlate('Define Lags'),outerLagPanel);
end

%% Listener to ViewChanged event which keeps the hist
%% panel updated
h.Listeners = [h.Listeners; handle.listener(this.AxesGrid,'ViewChange',...
    {@localupdatelags h this})];
localupdatelags([],[],h,this)


function LagPanel = localBuildPanel(h,this)

import com.mathworks.mwswing.*;
import javax.swing.*;
import java.awt.*;

%% Build panel
LagPanel = MJPanel(BorderLayout);

%% Create components
LBLnumlagLeft = MJLabel(xlate('From :'));
h.Handles.TXTnumlagLeft = MJTextField(12);
awtinvoke(h.Handles.TXTnumlagLeft,'setText(Ljava.lang.String;)','-10');
LBLnumlagRight = MJLabel(xlate('To :'));
h.Handles.TXTnumlagRight = MJTextField(12);
awtinvoke(h.Handles.TXTnumlagRight,'setText(Ljava.lang.String;)','10');

%% Add callbacks
set(handle(h.Handles.TXTnumlagLeft,'callbackproperties'),'ActionPerformedCallback',...
    {@localupdatelags h this})
set(handle(h.Handles.TXTnumlagRight,'callbackproperties'),'ActionPerformedCallback',...
    {@localupdatelags h this})

%% Create inner panel and add components
PNLinner = MJPanel(GridLayout(2,2,5,5));
PNLinner.add(LBLnumlagLeft);
PNLinner.add(h.Handles.TXTnumlagLeft);
PNLinner.add(LBLnumlagRight);
PNLinner.add(h.Handles.TXTnumlagRight);
PNLouter = MJPanel(BorderLayout);
PNLouter.add(PNLinner,BorderLayout.WEST);

%% Help Panel
PNLHelp = MJPanel(BorderLayout(5,10));
h.Handles.HelpButton = MJButton(xlate('Help'));
set(handle(h.Handles.HelpButton,'callbackproperties'),'ActionPerformedCallback',...
    @(es,ed) tsDispatchHelp('pe_correlation','modal',ancestor(this.AxesGrid.Parent,'figure')));
PNLHelp.add(h.Handles.HelpButton,BorderLayout.EAST);

%% Finalize panel
LagPanel.add(PNLouter,BorderLayout.NORTH);
LagPanel.add(PNLHelp,BorderLayout.SOUTH);

function localupdatelags(es,ed,h,this)

%% Update the lags property of the plot based on the definitions in the 
%% tsspecnode Dialog

left = str2double(char(h.Handles.TXTnumlagLeft.getText));
if isempty(left) || ~isscalar(left) || left-round(left)~=0 || isnan(left) || ~isfinite(left) 
    % Invalid number of lags - abort and revert to default
    awtinvoke(h.Handles.TXTnumlagLeft,'setText(Ljava.lang.String;)',mat2str(this.Lags(1)));
    return
end
right = str2double(char(h.Handles.TXTnumlagRight.getText));
if isempty(right) || ~isscalar(right) || right-round(right)~=0 || isnan(right) || ~isfinite(right) 
    % Invalid number of lags - abort and revert to default
    awtinvoke(h.Handles.TXTnumlagRight,'setText(Ljava.lang.String;)',mat2str(this.Lags(end)));
    return
end
if right>=left
   Lags = left:right;    
else
   Lags = right:left;    
   awtinvoke(h.Handles.TXTnumlagLeft,'setText(Ljava.lang.String;)',mat2str(right));
   awtinvoke(h.Handles.TXTnumlagRight,'setText(Ljava.lang.String;)',mat2str(left));
end
%% Apply the vector to the datafcn for each wave
if ~isequal(this.Lags,Lags);
    this.Lags = Lags;    
    for k=1:length(this.Responses)
        this.Responses(k).DataSrc.send('SourceChanged');
    end
end
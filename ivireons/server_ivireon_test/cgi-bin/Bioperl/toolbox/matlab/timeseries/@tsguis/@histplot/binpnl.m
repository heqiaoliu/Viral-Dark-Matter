function thisTab = binpnl(this,h)

% Copyright 2004-2005 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;
import java.awt.*
import com.mathworks.mwswing.*;
import javax.swing.*;

%% Build freq panel
h.Handles.BinPnl = localBuildPanel(h,this);
thisTab = struct('Name','Domain','Handles',[]);
thisTab.Name = 'Domain';
h.Tabs = [h.Tabs; thisTab];
outerBinPanel = MJPanel(BorderLayout(5,5));
outerBinPanel.setBorder(BorderFactory.createEmptyBorder(10,5,5,5));
outerBinPanel.add(h.Handles.BinPnl,BorderLayout.CENTER);
h.Handles.TabPane.add(xlate('Define Bins'),outerBinPanel);     

%% Listener to ViewChanged event which keeps the hist
%% panel updated
h.Listeners = [h.Listeners; handle.listener(this,this.findprop('Waves'),'PropertyPostSet',...
    {@localupdatebins h this})];
localupdatebins([],[],h,this)


function BinPnl = localBuildPanel(h,this)

import com.mathworks.mwswing.*;
import javax.swing.*;
import java.awt.*;

%% Build panel
BinPnl = MJPanel(BorderLayout(5,5));

%% Create components
h.Handles.RADIOCenters = MJRadioButton(xlate('Uniform centers      '));
h.Handles.RADIOCenters.setSelected(true);
h.Handles.RADIOCustom = MJRadioButton(xlate('Custom centers      '));
BTNGRP = ButtonGroup;
BTNGRP.add(h.Handles.RADIOCenters);
BTNGRP.add(h.Handles.RADIOCustom);
LBLnumbins = MJLabel(xlate('Number of bins:'));
LBLcenters = MJLabel(xlate('Vector of centers:'));
h.Handles.TXTnumbins = MJTextField(12);
h.Handles.TXTnumbins.setName('histplot:binpnl:numbins');
awtinvoke(h.Handles.TXTnumbins,'setText(Ljava.lang.String;)','50');
h.Handles.TXTcustomcenters = MJTextField(12);
awtinvoke(h.Handles.TXTcustomcenters,'setText(Ljava.lang.String;)','1:10');
h.Handles.TXTcustomcenters.setName('histplot:binpnl:bincenters');
%% Add callbacks
set(handle(h.Handles.RADIOCenters,'callbackproperties'),'ActionPerformedCallback',...
    {@localupdatebins h this})
set(handle(h.Handles.RADIOCustom,'callbackproperties'),'ActionPerformedCallback',...
    {@localupdatebins h this})
set(handle(h.Handles.TXTnumbins,'callbackproperties'),'ActionPerformedCallback',...
    {@localupdatebins h this})
set(handle(h.Handles.TXTnumbins,'callbackproperties'),'FocusLostCallback',...
    {@localupdatebins h this})
set(handle(h.Handles.TXTcustomcenters,'callbackproperties'),'ActionPerformedCallback',...
    {@localupdatebins h this})
set(handle(h.Handles.TXTcustomcenters,'callbackproperties'),'FocusLostCallback',...
    {@localupdatebins h this})

%% Create inner panel and add components
PNLinner = MJPanel(GridLayout(2,3,5,5));
PNLinner.add(h.Handles.RADIOCenters);
PNLinner.add(LBLnumbins);
PNLinner.add(h.Handles.TXTnumbins);
PNLinner.add(h.Handles.RADIOCustom);
PNLinner.add(LBLcenters);
PNLinner.add(h.Handles.TXTcustomcenters);
PNLouter = MJPanel(BorderLayout(5,5));
PNLouter.add(PNLinner,BorderLayout.WEST);

%% Help Panel
PNLHelp = MJPanel(BorderLayout(5,10));
h.Handles.HelpButton = MJButton(xlate('Help'));
set(handle(h.Handles.HelpButton,'callbackproperties'),'ActionPerformedCallback',...
         'tsDispatchHelp(''pe_histogram'',''modal'')');
PNLHelp.add(h.Handles.HelpButton,BorderLayout.EAST);

%% Finalize panel
BinPnl.add(PNLouter,BorderLayout.NORTH);
BinPnl.add(PNLHelp,BorderLayout.SOUTH);

function localupdatebins(es,ed,h,this)

%% Update the bins property of the plot based on the definitions in the 
%% tsspecnode Dialog

%% Quick return if plot is being deleted
if isempty(this) || ~ishandle(this)
    return
end
%% When text has chnaged, select the corresponding radio button
if isempty(ed) || ~isjava(ed) || ...
        (strcmp(char(es.getName),'histplot:binpnl:numbins') && ...
            h.Handles.RADIOCustom.isSelected)
    awtinvoke(h.Handles.RADIOCenters,'setSelected(Z)',true);
elseif strcmp(char(es.getName),'histplot:binpnl:bincenters') && ...
        h.Handles.RADIOCenters.isSelected
    awtinvoke(h.Handles.RADIOCustom,'setSelected(Z)',true);
end
%% Process the new bun vector
if h.Handles.RADIOCenters.isSelected
    % Construct a uniform bin vector
    numbins = eval(char(h.Handles.TXTnumbins.getText),'[]');
    if isscalar(numbins) && numbins>1 && numbins<1000 
        bins = numbins;
    else % Invalid number of bins - abort and revert to prev val or default
        if ~isempty(this.Bins)
            awtinvoke(h.Handles.TXTnumbins,'setText(Ljava.lang.String;)',sprintf('%d',length(this.Bins)));
        else
            awtinvoke(h.Handles.TXTnumbins,'setText(Ljava.lang.String;)','50');
        end
        return
    end
else
    % Construct a custom bin vector
    try
         bins = eval(h.Handles.TXTcustomcenters.getText);
    catch
         bins = [];
    end
    % If bin vec is invalid abort and revert to default 
    if isempty(bins) || ~(all(isfinite(bins)) && ndims(bins)==2 && min(size(bins))==1 && ...
        issorted(bins)) || length(bins)<=1
        if ~isempty(this.Bins)
            binInt = diff(this.Bins);
            maxInt = max(binInt);
            if length(this.Bins)>3 && maxInt-min(binInt)==0
                awtinvoke(h.Handles.TXTcustomcenters,'setText(Ljava.lang.String;)',...
                    sprintf('%0.4g:%0.4g:%0.4g',...
                    this.Bins(1),maxInt,this.Bins(end)));
            else
                awtinvoke(h.Handles.TXTcustomcenters,'setText(Ljava.lang.String;)',...
                    ['[' num2str(this.Bins) ']']);
            end
        else
            awtinvoke(h.Handles.TXTcustomcenters,'setText(Ljava.lang.String;)','1:10');
        end    
        return
    end
end

%% Apply the bin vector to the datafcn for each wave
if ~isequal(this.Bins,bins);
    this.Bins = bins;
    for k=1:length(this.Waves)
        this.Waves(k).DataSrc.send('SourceChanged')
    end
end
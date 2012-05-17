function state = lsimgui(h, mode)
%LIMGUI Opens lsim GUI for the @simplot
%
% LSIMGUI(@SIMPLOT,MODE) Opens lsim GUI for the handle @SIMPLOT
% with MODE determining which tab is initially selected
%
%   See also LSIM, INITIAL.
%
%  Author(s): J. G. Owen
%  Copyright 1986-2010 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2010/05/10 17:37:41 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import com.mathworks.ide.workspace.*;

if isempty(h.Responses)
   msgbox(sprintf('An LTI system must be imported before the Linear Simulation Tool can be opened'), ...
     sprintf('Linear Simulation Tool'),'modal');
     state = [];
   return
end

if isempty(h.InputDialog) || ~ishandle(h.InputDialog) % No lsim GUI has been created
    % Set hourglass cursor
    set(get(get(h,'axesgrid'),'parent'),'Pointer','watch');
    
    % Create guistate object   
    state = lsimgui.lsimguistate;
    state.Simplot = h;
    state.Visible = 'on';
    
    % Build gridbag layour objects
    gridbag = GridBagLayout;
    constr = GridBagConstraints;
    
    if strcmp(h.Tag,'lsim')
        if ~isempty(h.Input)
           thisTimeVector = h.Input.Data(1).Time; 
        else
           thisTimeVector = [];
        end          
    
        % Build timing panel    
        javaHandles = localBuildTimePnl(thisTimeVector);
        localBagConstraints(constr,1,[],5);
        gridbag.setConstraints(javaHandles.PNLTimeOuter,constr);
        hc = handle(javaHandles.BTNtimeimport, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localTimeImport(es,ed,state));
               
        % Build system panel   
        gridbag2 = GridBagLayout; 
        javaHandles.PNLsystem = JPanel(gridbag2);
        javaHandles.PNLsystemouter = JPanel(GridLayout(1,1));
        localBagConstraints(constr,[],1,5,[],[],1);
        gridbag.setConstraints(javaHandles.PNLsystemouter,constr);
    
        % Assign input names & build inputable object
        state.Inputtable = lsimgui.siminputtable;
        inputNames = h.Input.ChannelName;
        numinputs = length(inputNames);

        % Replace empty input names by default
        defInputs = cellstr(num2str((1:numinputs)'));
        inputNames(strcmp(inputNames,'')) = defInputs(strcmp(inputNames,''));
        state.Inputtable.initialize(numinputs,{xlate('Channels'),xlate('Data'),xlate('Variable Dimensions')},'inputtable');
        state.Inputtable.guistate = state; %needed by siggen & importselector to refocus main gui
        state.Inputtable.Inputnames = inputNames;
    
        % Assign inputtable time vector
        if length(thisTimeVector)>2
            state.Inputtable.Starttime = thisTimeVector(1);
            state.Inputtable.Interval = thisTimeVector(2)-thisTimeVector(1);
        end
        state.Inputtable.Simsamples = length(thisTimeVector); % Update the simplot prop to reflect the datafcn
    
        % Configure input table
        [javaHandles.varscroll, javaHandles.PNLtable] = localModifyInputTable(state.inputtable.STable);
        
        
        % Add the initial input data  
        localInitialInputs(state.Inputtable,h);
       
    
        % Add siminputtable listeners
         L =[handle.listener(state.Inputtable,'userentry',{@localUserEntry state})
             handle.listener(state.Inputtable,state.Inputtable.findprop('Simsamples'),'PropertyPostSet',...
                  {@localDurationUpdate state.Inputtable ...
                      javaHandles.TXTendTime javaHandles.TXTtimeStep ...
                      javaHandles.LBLnumSamples})];
        state.inputtable.addlisteners(L);


        % Build the table panel
        localBagConstraints(constr,1,1,1,1,1,0,1);
        constr.insets = Insets(5,5,0,0);
        gridbag2.setConstraints(javaHandles.PNLtable,constr);


        % Build interpolation panel
        javaHandles.PNLinterpOuter = JPanel(GridLayout(1,1));
        javaHandles.PNLinterp = JPanel(BorderLayout);
        javaHandles.BTNimport = JButton(sprintf('Import signal...'));
        javaHandles.BTNimport.setName('MainFrame:button:import');
        hc = handle(javaHandles.BTNimport, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) showImportFrame(es,ed,state));
        javaHandles.BTNdesign = JButton(sprintf('Design signal...'));
        javaHandles.BTNdesign.setName('MainFrame:button:design');
        hc = handle(javaHandles.BTNdesign, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) showSignalGenerator(es,ed,state));
        javaHandles.PNLinterpInner = JPanel;
        javaHandles.PNLinterpInner.add(javaHandles.BTNimport);
        javaHandles.PNLinterpInner.add(javaHandles.BTNdesign);
        javaHandles.PNLinterp.add(javaHandles.PNLinterpInner,BorderLayout.EAST);
        javaHandles.PNLinterpOuter.add(javaHandles.PNLinterp);
        localBagConstraints(constr,0,0,1,1,1,2,1);
        constr.insets = Insets(10,0,10,0);
        gridbag2.setConstraints(javaHandles.PNLinterpOuter,constr);

        % Build right panel
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % to be added when java figures can be used to represent signal
        % summary
        %javaHandles.PNLsummaryOuter = JPanel;
        %javaHandles.PNLsummaryOuter.setMinimumSize(Dimension(200,200));
        %javaHandles.PNLsummaryOuter.setPreferredSize(Dimension(250,250));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Summary non-editable text box
        javaHandles.TXTsummary = JTextArea(20,20);
        javaHandles.TXTsummary.setFont(javaHandles.LBLstartTime.getFont);
        javaHandles.TXTsummary.setBackground(javaHandles.PNLTimeOuter.getBackground);
        javaHandles.TXTsummary.setEditable(0);
        javaHandles.TXTsummary.setBorder(EmptyBorder(0,0,0,0));
        localBagConstraints(constr,1,0,1,1,1,1,0);
        gridbag2.setConstraints(javaHandles.TXTsummary,constr);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % to be added when java figures can be used to represent signal summary            
        %javaHandles.PNLsummaryOuter.add(javaHandles.TXTsummary);
        %localBagConstraints(constr,1,1,10,12,GridBagConstraints.RELATIVE);
        %constr.insets = Insets(0,0,0,0);
        %constr.anchor = GridBagConstraints.CENTER;
        % to be added when java figures can be used to represent signal summary
        % gridbag.setConstraints(javaHandles.PNLsummaryOuter,constr);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % Finish systems panel
        javaHandles.PNLsystem.add(javaHandles.PNLtable);
        javaHandles.PNLsystem.add(javaHandles.TXTsummary);
        javaHandles.PNLsystem.add(javaHandles.PNLinterpOuter);
        javaHandles.PNLsystemouter.add(javaHandles.PNLsystem);
        
    else % initial plot GUI
        javaHandles = struct;
    end
    
    % Build init tab
    [javaHandles.PNLinit javaHandles.LBLinit javaHandles.BTNinit javaHandles.initScroll ...
             javaHandles.COMBsys] = localBuildInitTab(state, h);
    
    % Build bottom button panel
    [javaHandles.PNLsim, javaHandles.COMBmethod, javaHandles.LBLmethod, javaHandles.BTNsim, ...
            javaHandles.BTNclose, javaHandles.PNLinterp, javaHandles.PNLsimbutton] = localLowerBtnPnl;
        
    if strcmp(h.Tag,'lsim')    

        interpStr = {'zoh','foh','auto'};
        state.Inputtable.Interpolation = 'zoh';
        if ~isempty(h.input) 
            interpIndex = find(strcmp(h.input.Interpolation,interpStr));
            awtinvoke(javaHandles.COMBmethod,'setSelectedIndex(I)',interpIndex-1);
            state.Inputtable.Interpolation = interpStr{interpIndex};
        end
    
        hc = handle(javaHandles.COMBmethod, 'callbackproperties');
        set(hc,'ItemStateChangedCallback',@(es,ed) localSetInterpolation(es,ed,state.inputtable,javaHandles.COMBmethod));
        
            

        % Add borders
        javaHandles.PNLsystem.setBorder(EmptyBorder(5,5,5,5));
        javaHandles.PNLTimeOuter.setBorder(BorderFactory.createTitledBorder(sprintf('Timing')));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % to be added when java figures can be used to represent signal summary
        % *** javaHandles.PNLsummaryOuter.setBorder(BorderFactory.createTitledBorder('Data for input:'));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        javaHandles.PNLsystemouter.setBorder(BorderFactory.createTitledBorder(sprintf('System inputs')));
        
        % Build main tabs and assign callbacks
        [javaHandles, menuLabel] = localBuildTabs(javaHandles,gridbag,mode,true);
        hc = handle(javaHandles.fileMenu1, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) loadGUI(es,ed,state));    
        hc = handle(javaHandles.fileMenu2, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) saveGUI(es,ed,state,'lsimGUI.mat'));
        hc = handle(javaHandles.editSubmenu1, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localMenuSelect(es,ed,state.Inputtable,menuLabel{1}));
        hc = handle(javaHandles.editSubmenu2, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localMenuSelect(es,ed,state.Inputtable,menuLabel{2}));
        hc = handle(javaHandles.editSubmenu3, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localMenuSelect(es,ed,state.Inputtable,menuLabel{3}));
        hc = handle(javaHandles.editSubmenu4, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localMenuSelect(es,ed,state.Inputtable,menuLabel{4}));
        hc = handle(javaHandles.editSubmenu5, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localMenuSelect(es,ed,state.Inputtable,menuLabel{5}));       
        hc = handle(javaHandles.editMenu, 'callbackproperties');
        set(hc,'MenuSelectedCallback',@(es,ed) localEditMenuClick(es,ed,state.Inputtable,javaHandles.editSubmenu));
        hc = handle(javaHandles.helpMenu1, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localHelp(es,ed));



        
        % Add listener to selected tab
        hc = handle(javaHandles.Jtab, 'callbackproperties');
        set(hc,'StateChangedCallback',@(es,ed) localTabChanged(es,ed,state,javaHandles.Jtab));
       
        % Set timing change callbacks
        hc = handle(javaHandles.TXTendTime, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localUpdateTime(es,ed,javaHandles.TXTendTime, ...
                javaHandles.TXTtimeStep,javaHandles.LBLnumSamples,state.Inputtable));
        hc = handle(javaHandles.TXTtimeStep, 'callbackproperties');
        set(hc,'ActionPerformedCallback',@(es,ed) localUpdateTime(es,ed,javaHandles.TXTendTime, ...
                javaHandles.TXTtimeStep,javaHandles.LBLnumSamples,state.Inputtable));
        hc = handle(javaHandles.TXTendTime, 'callbackproperties');
        set(hc,'FocusLostCallback',@(es,ed) localUpdateTime(es,ed,javaHandles.TXTendTime, ...
                javaHandles.TXTtimeStep,javaHandles.LBLnumSamples,state.Inputtable));           
        hc = handle(javaHandles.TXTtimeStep, 'callbackproperties');
        set(hc,'FocusLostCallback',@(es,ed) localUpdateTime(es,ed,javaHandles.TXTendTime, ...
                javaHandles.TXTtimeStep,javaHandles.LBLnumSamples,state.Inputtable));      
            
            
   
            
        % Rong Chen
        % set(state.Handles.initialTable.STable,'FocusLostCallback', {@localUserEntry state});
        
    else
        javaHandles = localBuildTabs(javaHandles,gridbag,mode,false);
        % Disable input components for initial plots
        awtinvoke(javaHandles.COMBmethod,'setVisible(Z)',false);
        awtinvoke(javaHandles.LBLmethod,'setVisible(Z)',false);
        awtinvoke(javaHandles.editMenu,'setEnabled(Z)',false);
        awtinvoke(javaHandles.fileMenu,'setEnabled(Z)',false);
        awtinvoke(javaHandles.Jtab,'setEnabledAt(IZ)',0,false);
        javaHandles.TXTtimeStep = [];
        javaHandles.TXTendTime = [];
        javaHandles.LBLnumSamples = [];
    end

    % "Simulate" button callback
    hc = handle(javaHandles.BTNsim, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localSimulate(es,ed,state,h, ...
        javaHandles.TXTtimeStep, javaHandles.TXTendTime, javaHandles.LBLnumSamples));
            
    state.Handles = javaHandles;
    state.Handles.initialTable = state.initialtable; %store the current table in the vector of past tables
    
    
    % New GUI handle
    h.InputDialog = state;
            
    % Set window close callbacks
    hc = handle(javaHandles.frame, 'callbackproperties');
    set(hc,'WindowClosingCallback',@(es,ed) localVisibleChange(es,ed,state,'off'));
    hc = handle(javaHandles.BTNclose, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localVisibleChange(es,ed,state,'off'));
    
    sources = get(h.Responses,'datasrc');
    if ~iscell(sources)
        sources = {sources};
    end
    
    % Update summary
    state.updatesummary; % update summary based on existing selection
    
    % Assign listeners
    state.addlisteners(...
      [handle.listener(state,state.findprop('Visible'),'PropertyPostSet',{@localGUIstateVisibility state state.inputtable})  
      handle.listener(h.Axesgrid.Parent,'ObjectBeingDestroyed', {@localDelete javaHandles.frame state})
      handle.listener(h,'ObjectBeingDestroyed', {@localDelete javaHandles.frame state})
      handle.listener(h.Responses,'ObjectBeingDestroyed', {@localDelete javaHandles.frame state})
      handle.listener([sources{:}],'SourceChanged', {@localDelete javaHandles.frame state})
      handle.listener(h,findprop(h,'Visible'),'PropertyPostSet', {@localVisibleChange state})
      handle.listener(h,findprop(h,'Responses'),'PropertyPostSet',{@localDelete javaHandles.frame state})
      handle.listener(state,findprop(state,'CurrentTab'),'PropertyPostSet',{@localMenuEnable state javaHandles.editMenu javaHandles.fileMenu})]);
   
    % listener 1: closes the gui when the state is set to invisible
    % listener 2: directly closes the gui when the @simplot is closed - to
    %             avoid udd delay
    % listener 3: closes the gui when the @simplot is closed
    % listener 4: closes the gui when the data src changes
    % listener 5: closes the gui when the @simplot becomes invisible in the
    %             ltiviewer
    % listener 6: closes the gui when the new responses are added
    % listener 7: disables the file and edit menus when the "initial" tab
    % is selected
    
    javaHandles.frame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));   
    set(get(get(h,'Axesgrid'),'parent'),'Pointer','arrow');
    
else % Reset main panel - an lsim gui already exists    
    state = h.InputDialog; % recapture GUI state
    if strcmp(state.Visible,'off') 
        state.Handles.Jtab.setSelectedIndex(double(strcmpi(mode,'lsiminit')));
    else % thread safe tab selection
        awtinvoke(state.Handles.Jtab,'setSelectedIndex(I)',int32(strcmpi(mode,'lsiminit')));
    end
    state.Visible = 'on';
end

    
%-------------------- Local Functions ---------------------------

function localVisibleChange(eventSrc, eventData, state,  varargin)

if nargin==4
    state.Visible = varargin{1}; % visibility listener will hide the frame
elseif strcmp(state.Simplot.Visible,'off') % don't reopen gui if @simplot visibility is on, user does this with menu
    state.Visible = state.Simplot.Visible; % visibility listener will hide the frame
end


function localBagConstraints(constr,varargin)

import java.awt.*;

constr.weightx = 0;
constr.weighty = 0;
constr.gridwidth = 1;
constr.gridheight = 1;
constr.gridx = 0;
constr.gridy = 0;
constr.fill = GridBagConstraints.BOTH;
if nargin >=2 && ~isempty(varargin{1})
   constr.weightx = varargin{1};
end
if nargin >=3 && ~isempty(varargin{2})
   constr.weighty = varargin{2};
end
if nargin >=4 && ~isempty(varargin{3})
   constr.gridwidth = varargin{3};
end
if nargin >=5 && ~isempty(varargin{4})
   constr.gridheight = varargin{4};
end
if nargin >=6 && ~isempty(varargin{5})
   constr.gridx = varargin{5};
end
if nargin >=7 && ~isempty(varargin{6})
   constr.gridy = varargin{6};
end
if nargin >=8 && ~isempty(varargin{7})
   constr.fill = varargin{7};
end

function localUserEntry(eventSrc, eventData, state)

% Input table user entry callback
if ~all(all(strcmp(state.Inputtable.Lastcelldata,state.Inputtable.Celldata)))
    state.Inputtable.userinput;
end
state.updatesummary;

function x = localInitialTableClicked(eventSrc, eventData, initialtable)


x = [];
% Update only if the table data has changed or this is not a listener callback
if isempty(eventSrc) || (~isempty(initialtable.Userdata) && ...
        ~all(strcmp(initialtable.Userdata(:),initialtable.Celldata(:))))
    try
        initcelldata = initialtable.Celldata(:,2);
        for k=1:initialtable.Numstates
            x(k) = str2double(initcelldata{k}); 
            if ~isfinite(x(k))
                ctrlMsgUtils.error('Controllib:general:UnexpectedError','Non-numeric entry');
            end
        end
        x = x'; % want column
        initialtable.Userdata = initialtable.Celldata;
    catch
        errordlg(sprintf('Initial conditions must be finite numeric scalars'),...
            sprintf('Linear Simulation Tool'), 'modal')
        initialtable.setCells(initialtable.Userdata);
    end
end

function showImportFrame(eventSrc, eventData, state)

% Opens Data Import dialog when user hits "Import Data"

import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

if isempty(state.Inputtable.ImportSelector) %nothing created yet
	state.Handles.frame.setCursor(Cursor(Cursor.WAIT_CURSOR));
end

state.Inputtable.ImportSelector = state.Inputtable.edit;
importhandles = state.Inputtable.ImportSelector.Importhandles;
awtinvoke(importhandles.importDataFrame,'setVisible(Z)',true);

if getType(state.Handles.frame.getCursor)~=0
	state.Handles.frame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
end

function showSignalGenerator(eventSrc, eventData, state)

% Opens the signal designer

import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

if state.Inputtable.Simsamples>1
    if isempty(state.InputTable.Signalgenerator)
         state.Handles.frame.setCursor(Cursor(Cursor.WAIT_CURSOR));
         state.InputTable.Signalgenerator = state.InputTable.siggen;
         state.Handles.frame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
    else
         state.InputTable.Signalgenerator.Visible = 'on';    
    end
	% Force the signal designer to the front
	awtinvoke(state.InputTable.Signalgenerator.jhandles.frame,'setVisible(Z)',true);
else
    msgbox(sprintf('The time vector must have at least two samples to design an input signal'), ...
        sprintf('Linear Simulation Tool'),'modal');
end

function localSimulate(eventSrc, eventData, state , h, TXTtimeStep,TXTendTime,LBLnumSamples)
% Updates the simulation based on the current GUI configuration
        
inputtable = state.Inputtable;
initialtable = state.Initialtable; % note this could change depending on the system selection 

% Process input vector for lsim plots
if strcmp(h.Tag,'lsim')
    % Rong Chen
    % avoid seg fault
    if ~isempty(inputtable)
        thisEditor = inputtable.STable.getCellEditor;
        if ~isempty(thisEditor)
            awtinvoke(thisEditor,'stopCellEditing()');
        end
        % wait 0.1 second to avoid thread competition
        pause(0.1);
        state.Inputtable.userinput;
        state.updatesummary;
    end
    if ~isempty(initialtable)
        thisEditor = initialtable.STable.getCellEditor;
        if ~isempty(thisEditor)
            awtinvoke(thisEditor,'stopCellEditing()');
        end
    end

        % Fire the simulation time text box update to ensure that the state.Inputtable.Simsamples
        % is up to date
        inputtable.updatetime(TXTendTime,TXTtimeStep,LBLnumSamples);

        % Update the @simplot
        minlength = inputtable.Simsamples;
        if minlength > 0 && ~isempty(inputtable.Interval) && inputtable.Interval>0

            % Time vector
            T = (0:(minlength-1))*inputtable.Interval+inputtable.Starttime; 

            numinputs = length(inputtable.Inputsignals);

            % Refresh the table models if necessary
            thisEditor = inputtable.STable.getCellEditor;
            if ~isempty(thisEditor)
                awtinvoke(thisEditor,'stopCellEditing()');
            end

            % Create input matrix as a cell array
            X = cell(1,numinputs);
            for k=1:numinputs
                rawdata = inputtable.Inputsignal(k).values;
                if ~isempty(rawdata)
                    X{k} = rawdata(inputtable.Inputsignal(k).interval(1):inputtable.Inputsignal(k).interval(2));
                else
                    X{k} = [];
                end
            end

            % How many responses have enough inputs?
            numSimulations = 0;
            inputsUsed = false(numinputs,1);
            for k=1:length(h.Responses)
                if ~isempty(h.Responses(k).DataSrc) && all(ismember(h.Responses(k).Context.InputIndex,find(~cellfun('isempty',X))))
                    numSimulations = numSimulations+1;
                    inputsUsed(h.Responses(k).Context.InputIndex) = true;
                end
            end

            minlength = min(minlength, min(cellfun('length',X(inputsUsed))));
            if minlength<=1
                errordlg(sprintf('Cannot simulate for less than 2 samples'),...
                    sprintf('Linear Simulation Tool'),'modal');
                return
            end

            % Warn or error if there are insufficient inputs
            if numSimulations==0
                errordlg(sprintf('None of the systems have a complete set of inputs'),...
                    sprintf('Linear Simulation Tool'),'modal') 
                return
            elseif numSimulations<length(h.Responses)
                warnstr = sprintf('%s%d%s%d%s','Outputs can only be generated for ',numSimulations, ...
                   ' out of the total ', length(h.Responses), ' responses');
                warndlg(warnstr,sprintf('Linear Simulation Tool'),'modal')
            end

            % Update Input @waveform with the specified inputs
            for k=1:numinputs
                if inputsUsed(k)
                    h.Input.Data(k).Time = T;            
                    h.Input.Data(k).Focus = [T(1) T(end)];  
                    h.Input.Data(k).Amplitude = X{k}(1:minlength);
                else
                    h.Input.Data(k).Time = [];            
                    h.Input.Data(k).Focus = [];  
                    h.Input.Data(k).Amplitude = [];
                end
            end
            h.Input.Interpolation =  inputtable.Interpolation;      
            inputVisible = h.Input.Visible;
        else
               errordlg(sprintf('Invalid time interval'),sprintf('Linear Simulation Tool'),'modal');
               return
        end
end

% Process initial states for lsim and initial plots

 % Finish editing the initial table
if ~isempty(initialtable) % initialtable is empty if the system(sec) have no valid states
    thisEditor = initialtable.STable.getCellEditor;
    if ~isempty(thisEditor)
        awtinvoke(thisEditor,'stopCellEditing()');
    end
end 

% Initialize initial conditions
for k=1:length(h.Responses)
   if isStateSpace(h.responses(k).datasrc.model)
       h.Responses(k).Context.IC = zeros(size(h.Responses(k).dataSrc.Model,'order'),1);
   end
end
   
% Assign table values to initial conditions
for k=1:length(h.InputDialog.Handles.initialTable)
    h.InputDialog.Handles.initialTable(k).Response.Context.IC = ...
       localInitialTableClicked([],[],h.InputDialog.Handles.initialTable(k));
end        


% Clear data so that draw will refresh
for k=1:length(h.Responses)
    h.Responses(k).Data.clear;
end  

% Refresh input waveforms
h.Input.refresh;

% Draw the plot
if isvisible(h)
   h.draw;
else
   h.Visible = 'on'; %ltiviewer opens the lsimgui with an invisible @simplot
end

% Write back the previous @simplot input visibility for lsim plots
if strcmp(h.Tag,'lsim')
    h.Input.Visible = inputVisible;
end

% Transfer the focus to the @simplot
figure(double(h.axesgrid.parent));



function localDelete(eventSrc, eventData, frame, state, inputtable)

% Resets the lsim GUI after hiding it

% Dispose dependent frames if necessary
if ~isempty(state.Inputtable)
    if ~isempty(state.Inputtable.ImportSelector)
        state.Inputtable.ImportSelector.Importhandles.importDataFrame.dispose;
    end
    if ~isempty(state.Inputtable.Signalgenerator)
        state.Inputtable.Signalgenerator.jhandles.frame.dispose;
    end
    if ~isempty(state.Timeimportdialog)
        state.Timeimportdialog.Frame.dispose;
    end
end
state.handles.frame.dispose;
delete(state);

function localUpdateTime(eventSrc, eventData, TXTendTime,TXTtimeStep,LBLnumSamples,inputtable)

% callback which updates the table when the simulation time interval is
% changed
inputtable.updatetime(TXTendTime,TXTtimeStep,LBLnumSamples);

function [PNLinit, LBLinit, BTNinit, scroll1, COMBsys] = localBuildInitTab(state, h)

% Build initial conditions tab. Called with varargin == 'initial' if
% this is a build requiring full construction

import com.mathworks.toolbox.control.spreadsheet.*;
import java.awt.*;
import javax.swing.*;

ssresps = localGetStateNames(h);
PNLinit = JPanel(BorderLayout);


if ~isempty(ssresps) % build a state initial value table
    state.initialtable = localCreateInitTable(h, ssresps(1), state);    
    scroll1 = JScrollPane(state.initialtable.STable);
     
    % Create datasrc name panel
    PNLsys = JPanel;
    LBLsys = JLabel(sprintf('Selected system'));
    COMBsys = JComboBox;
    COMBsys.setName('Init:combo:sys');
    for k=1:length(ssresps)
       COMBsys.addItem(ssresps(k).Name);
    end
    COMBsys.setPreferredSize(Dimension(LBLsys.getPreferredSize.getWidth,...
         COMBsys.getPreferredSize.getHeight));
    PNLsys.add(LBLsys);
    PNLsys.add(COMBsys);
    hc = handle(COMBsys, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localChangeTable(es,ed,COMBsys,h));
    
    set(COMBsys,'UserData',ssresps);   
    % Import button
    BTNinit = JButton(sprintf('Import state vector...'));
    BTNinit.setName('Init:button:importstate');
    hc = handle(BTNinit, 'callbackproperties');
    set(hc,'ActionPerformedCallback',@(es,ed) localInitialImport(es,ed,state));
    
    LBLinit = JLabel;   
    PNLtable = JPanel(BorderLayout(10,10));
    PNLinit.add(PNLsys,BorderLayout.NORTH);
    PNLtable.add(scroll1,BorderLayout.CENTER);
    PNLimportinfo = JPanel(BorderLayout(10,10));
    PNLimportinfo.add(LBLinit, BorderLayout.CENTER);
    PNLimportinfo.add(BTNinit, BorderLayout.EAST);
    PNLtable.add(PNLimportinfo,BorderLayout.SOUTH);

else
    LBLinit = JLabel(sprintf('None of the systems are in state space form'));
    PNLtable = JPanel(BorderLayout(10,10));
    PNLtable.add(LBLinit,BorderLayout.CENTER);
    BTNinit = [];
    scroll1 = [];
    COMBsys = [];    
end


PNLtableOuter = JPanel(GridLayout(1,1));
PNLtableOuter.setBorder(BorderFactory.createTitledBorder(sprintf('Specify initial states')));
PNLtable.setBorder(BorderFactory.createEmptyBorder(0,10,0,10));
PNLtableOuter.add(PNLtable);
PNLinit.add(PNLtableOuter,BorderLayout.CENTER);

function localEditMenuClick(eventSrc, eventData, h, menus)

h.menuoptions(menus)

function localMenuSelect(eventSrc, eventData, h, thisMenu)

h.menuselect(thisMenu);

function localHelp(eventSrc, eventData)

ctrlguihelp('lsim_overview');

function loadGUI(eventSrc, eventData, state)

% step length
% end time
% savedCellData
% savedInputSignals

[fname pname] = uigetfile('*.mat',sprintf('Select Linear Simulation Tool conditions file'));
if ischar(fname) 
    load([pname fname]);
    numinputs = length(state.inputtable.inputsignals);
    if length(savedInputSignals) == numinputs  
        newcelldata = state.inputtable.celldata;
        newcelldata(1:numinputs,:) = savedCellData; %preserve any trailing blank cells
        state.inputtable.setCells(newcelldata);
        state.inputtable.lastcelldata = newcelldata;
        state.inputtable.inputsignals = savedInputSignals;
        state.Inputtable.Starttime = savedStartTime;
        state.Inputtable.Interval = savedStepLength;
        state.Inputtable.Simsamples = savedsimsamples; %listener updates the boxes
        state.handles.LBLstartTime.setText(sprintf('Start time (sec): %s',num2str(state.Inputtable.Starttime)));
        state.inputtable.update
    else
        msgbox(sprintf('Mismatch between saved data, which was defined by a system with %s inputs, and this system which has %s inputs.',...
            num2str(length(savedInputSignals)),num2str(numinputs)),...
            sprintf('Linear Simulation Tool'),'modal');
    end
end

function saveGUI(eventSrc, eventData,  state, varargin)

filefilter = '*.mat';
if ~isempty(varargin)
    filefilter = varargin{1};
end
[fname pname] = uiputfile(filefilter,sprintf('Select Linear Simulation Tool conditions file'));
numinputs = length(state.inputtable.inputsignals);
if ischar(fname) 
    savedStepLength = state.Inputtable.Interval;
    savedStartTime = state.Inputtable.Starttime;
    savedsimsamples = state.Inputtable.Simsamples;
    savedCellData = state.inputtable.celldata(1:numinputs,:); %skip any blank trailing cells
    savedInputSignals = state.inputtable.inputsignals;
    save([pname fname],'savedStartTime','savedStepLength','savedsimsamples', ...
        'savedCellData','savedInputSignals');
end

function localSetInterpolation(eventSrc, eventData, inputtable, COMBmethod)

% Callback for the interpolation combo
interpStr = {'zoh','foh','auto'};
inputtable.Interpolation = interpStr{COMBmethod.getSelectedIndex+1};

function localInitialInputs(inputtable,h)

% Assigns the initial inputs to those in the @simplot

% All responses must have the inp matrix
if ~isempty(h.Input)
    inputdata = get(h.Input.Data,{'Amplitude'});
    for k=1:length(inputdata)
        if ~isempty(inputdata{k})
            inputtable.Inputsignals(k) = struct('values',inputdata{k},'source','ini',...
            'subsource','','construction','','interval', [1 length(inputdata{k})], ...
            'column',k,'name','default','transposed',false,'size',[size(inputdata{k},1) length(inputdata)]);
        end
    end
end

inputtable.update %refresh


function localGUIstateVisibility(eventSrc, eventData, state, h)

import javax.swing.*;
import com.mathworks.toolbox.control.spreadsheet.*;

% input table visibility assigned to lsimguistate visibility
h.visible = state.visible;

% show main window
awtinvoke(state.handles.frame,'setVisible(Z)',strcmp(state.visible,'on'));


function localDurationUpdate(eventSrc, eventData, h, TXTendTime, TXTtimeStep,LBLnumSamples)

h.durationupdate(TXTendTime, TXTtimeStep, LBLnumSamples);

function localInitialImport(eventSrc, eventData, state)

% open initial vector importer

import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import javax.swing.border.*;

if isempty(state.initialtable) %nothing created yet
	state.handles.frame.setCursor(Cursor(Cursor.WAIT_CURSOR));
end

% If an importselector doesn't exist create one. Make the frame visible
if isempty(state.initialtable.importSelector)
    state.initialtable.edit(state.handles.frame)
    state.initialtable.importSelector.frame.setVisible(1);
else
    if ~isempty(state.initialtable.numstates)
        state.initialtable.importSelector.workbrowser.open([1 state.initialtable.numstates;
            state.initialtable.numstates 1]);
    else
        state.initialtable.importSelector.workbrowser.open
    end
    awtinvoke(state.initialtable.importSelector.frame,'setVisible(Z)',true);
end

if getType(state.handles.frame.getCursor)~=0
	state.handles.frame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
end


function javaHandles = localBuildTimePnl(thisTimeVector)

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;

% build timing panel    
javaHandles.PNLTimeOuter = JPanel(GridLayout(2,1,5,5));
%javaHandles.LBLendTime = JLabel(sprintf('to '));
javaHandles.LBLendTime = JLabel(sprintf('      End time (sec):'));

if ~isempty(thisTimeVector)
    % display almost integers as integers
    if abs(round(thisTimeVector(1))-thisTimeVector(1))<10*eps
       javaHandles.LBLstartTime = JLabel(sprintf('Start time (sec): %1.0f',thisTimeVector(1)));
    else
       javaHandles.LBLstartTime = JLabel(sprintf('Start time (sec): %0.3f',thisTimeVector(1)));
    end
    if abs(round(thisTimeVector(end))-thisTimeVector(end))<10*eps
       javaHandles.TXTendTime = JTextField(sprintf('%1.0f',thisTimeVector(end)));
    else
       javaHandles.TXTendTime = JTextField(sprintf('%0.3f',thisTimeVector(end)));
    end
    if abs(round(thisTimeVector(2)-thisTimeVector(1))-thisTimeVector(2)-thisTimeVector(1))<10*eps
       javaHandles.TXTtimeStep = JTextField(sprintf('%1.0f',thisTimeVector(2)-thisTimeVector(1)));
    else
       javaHandles.TXTtimeStep = JTextField(sprintf('%0.3f',thisTimeVector(2)-thisTimeVector(1)));
    end
    javaHandles.LBLnumSamples = JLabel(sprintf('Number of samples: %s',...
          num2str(length(thisTimeVector))));    
else
    javaHandles.LBLstartTime = JLabel(sprintf('Start time (sec): 0')); 
    javaHandles.TXTendTime = JTextField;
    javaHandles.TXTtimeStep = JTextField;
    javaHandles.LBLnumSamples = JLabel(sprintf('Number of samples:'));
end
javaHandles.TXTendTime.setName('MainFrame:textfield:endtime');
javaHandles.TXTendTime.setColumns(5);
javaHandles.LBLtimeStep = JLabel(sprintf('      Interval (sec):')); 
javaHandles.TXTtimeStep.setName('MainFrame:textfield:timestep');
javaHandles.TXTtimeStep.setColumns(5);
javaHandles.BTNtimeimport = JButton(sprintf('Import time')); 
javaHandles.BTNtimeimport.setName('MainFrame:button:importtime');
  
% start time - interval - stop time
javaHandles.PNLTimeVec = JPanel(FlowLayout(FlowLayout.LEFT,10,0));
javaHandles.PNLTimeVec.add(javaHandles.LBLstartTime,FlowLayout.LEFT);
javaHandles.PNLTimeVec.add(javaHandles.LBLendTime);
javaHandles.PNLTimeVec.add(javaHandles.TXTendTime);
javaHandles.PNLTimeVec.add(javaHandles.LBLtimeStep);
javaHandles.PNLTimeVec.add(javaHandles.TXTtimeStep);

% number of samples - import btn
javaHandles.PNLBtnTimeImport = JPanel;
javaHandles.PNLBtnTimeImport.add(javaHandles.BTNtimeimport);
javaHandles.PNLTimeCharOuter = JPanel(GridLayout(1,1));
javaHandles.PNLTimeCharOuter.setBorder(EmptyBorder(0,10,0,10));
javaHandles.PNLTimeCharInner = JPanel(BorderLayout);
javaHandles.PNLTimeCharInner.add(javaHandles.LBLnumSamples,BorderLayout.WEST);
javaHandles.PNLTimeCharInner.add(javaHandles.PNLBtnTimeImport,BorderLayout.EAST);
javaHandles.PNLTimeCharInner.add(javax.swing.Box.createGlue,BorderLayout.CENTER);

javaHandles.PNLTimeCharOuter.add(javaHandles.PNLTimeCharInner);
javaHandles.PNLTimeOuter.add(javaHandles.PNLTimeVec); 
javaHandles.PNLTimeOuter.add(javaHandles.PNLTimeCharOuter); 


function [varscroll, PNLtable] = localModifyInputTable(table)

import javax.swing.*;
import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.border.*; 
% Configure input table
s = Dimension(table.getWidth,25);
table.getTableHeader.setPreferredSize(s);
table.setRowHeight(25);
table.setCellSelectionEnabled(0);
table.setRowSelectionAllowed(1);
table.setRowSelectionInterval(0,0);
table.getColumnModel.getColumn(2).setMinWidth(100);
table.setName('MainFrame:table:input_table');
varscroll = JScrollPane(table);
PNLtable = JPanel(BorderLayout);
PNLtable.add(varscroll,BorderLayout.CENTER);
varscroll.setBorder(BorderFactory.createEmptyBorder(0,0,0,0));

function [PNLsim, COMBmethod, LBLmethod, BTNsim, BTNclose, PNLinterp,  PNLsimbutton] = localLowerBtnPnl
    
import javax.swing.*;
import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.border.*;

% Build bottom button panel
PNLsim = JPanel(BorderLayout);  
COMBmethod = JComboBox;
COMBmethod.setName('MainFrame:combo:interp');
COMBmethod.addItem(xlate('Zero order hold'));
COMBmethod.addItem(xlate('First order hold'));
COMBmethod.addItem(xlate('Automatic'));
COMBmethod.setSize(120,27);
LBLmethod = JLabel(xlate('Interpolation method:'));
LBLmethod.setSize(220,27);
BTNsim = JButton(sprintf('Simulate'));
BTNsim.setName('MainFrame:button:simulate');
BTNclose = JButton(sprintf(' Close '));
BTNclose.setName('MainFrame:button:close');
PNLinterp = JPanel;
PNLinterp.add(LBLmethod);
PNLinterp.add(COMBmethod);
PNLsim.add(PNLinterp,BorderLayout.CENTER);
PNLsimbutton = JPanel(GridLayout(1,1));
PNLsimbuttonInner = JPanel(FlowLayout(FlowLayout.LEFT,5,5));
PNLsimbuttonInner.add(BTNsim);
PNLsimbuttonInner.add(BTNclose);
PNLsimbutton.add(PNLsimbuttonInner);
PNLsim.add(PNLsimbutton,BorderLayout.EAST);
PNLsim.setBorder(EmptyBorder(5,5,5,5));

function [javaHandles, varargout] = localBuildTabs(javaHandles, gridbag, mode, fulltabs)

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwswing.*;

% Empty lsim tab
javaHandles.mainDataPanel = JPanel(gridbag);

javaHandles.mainInitialPanel = JPanel;
javaHandles.Jtab = MJTabbedPane;
javaHandles.Jtab.setName('MainFrame:tabs:tabs');
javaHandles.Jtab.addTab(sprintf('Input signals'), javaHandles.mainDataPanel);
javaHandles.Jtab.addTab(sprintf('Initial states'), javaHandles.PNLinit);
javaHandles.frame = MJFrame(sprintf('Linear Simulation Tool'));    
javaHandles.frame.setCursor(Cursor(Cursor.WAIT_CURSOR));   
javaHandles.menuBar = JMenuBar;
javaHandles.fileMenu = JMenu(sprintf('File'));
javaHandles.fileMenu.setName('MainFrame:menus:file');
javaHandles.editMenu = JMenu(sprintf('Edit'));
javaHandles.editMenu.setName('MainFrame:menus:edit');
javaHandles.helpMenu = JMenu(sprintf('Help'));
javaHandles.helpMenu.setName('MainFrame:menus:help');


if fulltabs % lsim GUI not initial GUI
    javaHandles.mainDataPanel.add(javaHandles.PNLTimeOuter);
    javaHandles.mainDataPanel.add(javaHandles.PNLsystemouter);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % to be added when java figures can be used to represent signal summary
    %javaHandles.mainDataPanel.add(javaHandles.PNLsummaryOuter);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    javaHandles.fileMenu1 = JMenuItem(sprintf('Load input table'));
    javaHandles.fileMenu1.setName('MainFrame:submenus:load');
    javaHandles.fileMenu.add(javaHandles.fileMenu1);  
    javaHandles.fileMenu2 = JMenuItem(sprintf('Save input table'));
    javaHandles.fileMenu2.setName('MainFrame:submenus:save');
    javaHandles.fileMenu.add(javaHandles.fileMenu2);          
    menuLabel = {xlate('Cut signal'),xlate('Copy signal'),...
        xlate('Paste signal'),xlate('Insert signal'),xlate('Delete signal')};
    javaHandles.editSubmenu1 = JMenuItem(menuLabel{1});
    javaHandles.editSubmenu1.setName('MainFrame:submenus:cut');
    javaHandles.editMenu.add(javaHandles.editSubmenu1);    
    javaHandles.editSubmenu2 = JMenuItem(menuLabel{2});
    javaHandles.editSubmenu2.setName('MainFrame:submenus:copy');
    javaHandles.editMenu.add(javaHandles.editSubmenu2);  
    javaHandles.editSubmenu3 = JMenuItem(menuLabel{3});
    javaHandles.editSubmenu3.setName('MainFrame:submenus:paste');
    javaHandles.editMenu.add(javaHandles.editSubmenu3);  
    javaHandles.editSubmenu4 = JMenuItem(menuLabel{4});
    javaHandles.editSubmenu4.setName('MainFrame:submenus:insert');
    javaHandles.editMenu.add(javaHandles.editSubmenu4);  
    javaHandles.editSubmenu5 = JMenuItem(menuLabel{5});
    javaHandles.editSubmenu5.setName('MainFrame:submenus:delete');
    javaHandles.editMenu.add(javaHandles.editSubmenu5); 
    javaHandles.editSubmenu  = [javaHandles.editSubmenu1; 
    javaHandles.editSubmenu2;javaHandles.editSubmenu3;...
                javaHandles.editSubmenu4;javaHandles.editSubmenu5];
    varargout{1} = menuLabel;
    javaHandles.helpMenu1 = JMenuItem(sprintf('About linear simulation tool'));
    javaHandles.helpMenu1.setName('MainFrame:submenus:about');
    javaHandles.helpMenu.add(javaHandles.helpMenu1);  
end        
        
javaHandles.menuBar.add(javaHandles.fileMenu);
javaHandles.menuBar.add(javaHandles.editMenu);
javaHandles.menuBar.add(javaHandles.helpMenu);
javaHandles.mainFramePNL = JPanel(BorderLayout(5,5));
javaHandles.mainFramePNL.add(javaHandles.Jtab,BorderLayout.CENTER);
javaHandles.mainFramePNL.add(javaHandles.PNLsim,BorderLayout.SOUTH);
javaHandles.frame.getContentPane.add(javaHandles.mainFramePNL);
javaHandles.frame.setJMenuBar(javaHandles.menuBar);
javaHandles.frame.setSize(630,530);
javaHandles.Jtab.setSelectedIndex(double(strcmpi(mode,'lsiminit')));
javaHandles.frame.setVisible(1);
javaHandles.frame.toFront;
% table scroll panels should have no border
if ~isempty(javaHandles.initScroll)
    awtinvoke(javaHandles.initScroll,'setBorder','');
end



function initTable = localCreateInitTable(h, thisresp, state)

% Creates or retrieves an @initialtable object to display on the 
% intitial states tab

import javax.swing.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import java.awt.*;

% Return any table which already exists for this dataSrc
if isfield(state.Handles,'initialTable')
    tableResps = get(state.Handles.initialTable,{'Response'});
    I = find(thisresp==[tableResps{:}]);
    if ~isempty(I)
        initTable = state.Handle.initialTable(I(1));
        return
    end
else
    state.Handles.initialTable = [];
end

% Get state information for this dataSrc
[ssresps, stateNames,initStates,numStates,ssCount] = localGetStateNames(h, thisresp);
if ssCount==0
    return %Named response does not exist as a @SS object
end

% Create Table
if numStates(1)==0
    initTableContents = cell(0,2);
else
    initTableContents = [stateNames{1} cellstr(num2str(initStates{1}))];
end
initReadOnlyRows = [];
minrows = 10;
if numStates<minrows % pad the table if required
    extraInitialRows = cell(minrows-numStates,2);
    extraInitialRows(:) = {' '};
    initTableContents = [initTableContents; extraInitialRows];
    initReadOnlyRows = numStates(1)+1:minrows;
end
initTable = lsimgui.initialtable(initTableContents, ...
    {xlate('State name'),xlate('Initial value')});    
set(initTable, 'leadingcolumn', 'on', 'Numstates', numStates(1),...
   'readonlyrows', initReadOnlyRows, 'readonlycols', 1);
set(initTable,'STable',STable(STableModel(initTable)));
initTable.STable.setName(['MainFrame:table:initialconds:' thisresp.Name]);

% Touch up table appearance
s = Dimension(initTable.STable.getWidth,25);
initTable.STable.getTableHeader.setPreferredSize(s);
initTable.STable.setRowHeight(25);
L = [handle.listener(initTable,'userentry',{@localInitialTableClicked initTable})
     handle.listener(initTable,'tablecellchanged',{@localInitialTableClicked initTable})];
initTable.addlisteners(L);

% Storage
initTable.userdata = initTable.celldata; 
initTable.Response = thisresp;
state.Handles.initialTable = [state.Handles.initialTable initTable];


function [resps, varargout] = localGetStateNames(h, varargin)

resps = [];
stateNames = {};
initStates = {};
numStates = [];
       
dataSrcs = get(h.Responses,{'DataSrc'});

ct = 0;
for k=1:length(dataSrcs)
    if ~isempty(dataSrcs{k}) && isa(dataSrcs{k}.Model,'ss') && ...
        (nargin==1 || varargin{1}.DataSrc==dataSrcs{k})
       ct = ct+1;
       s = getsize(dataSrcs{k});
       resps = [resps h.Responses(k)];
       
       % Screen out LTI arrays with differing numbers of states
       thisModel = dataSrcs{k}.Model(:,:,1);
       thisModelStates = length(get(thisModel,'A'));
       for j=2:prod(s(3:end))
          if thisModelStates~=length(get(dataSrcs{k}.Model(:,:,j),'A'))
             thisModelStates = 0;
             break
          end
       end
%        if thisModelStates==0
%            stateNames{ct} = '';
%            initStates{ct} = [];
%            numStates(ct) = 0;       
%            break
%        end
       
       % Create outputs
       stateNames{ct} = thisModel.StateName;
       initStates{ct} = h.Responses(k).Context.IC;
       if isempty(initStates{ct})
          initStates{ct} = zeros(thisModelStates,1);
       end
       numStates(ct) = thisModelStates;       
       
       % Replace empty state names with defaults
       defStates = cellstr([repmat('state',numStates(ct),1) num2str((1:numStates(ct))')]);
       emptyStateNames = find(strcmp(stateNames{ct},''));
       stateNames{ct}(emptyStateNames) = defStates(emptyStateNames);
    end
end
ssCount = ct;
if nargout ==5
    varargout{1} = stateNames;
    varargout{2} = initStates;
    varargout{3} = numStates;
    varargout{4} = ssCount;
end


function localChangeTable(eventSrc, eventData, COMBsys, h)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

% Update the initial scroll pane with the current initial table
thisInd = double(COMBsys.getSelectedIndex)+1;
ssresps = get(COMBsys,'UserData');
if thisInd>0
   h.InputDialog.Initialtable = localCreateInitTable(h, ssresps(thisInd),h.InputDialog);
   awtinvoke(h.InputDialog.Handles.initScroll,'setViewportView',h.InputDialog.Initialtable.STable);
   %h.InputDialog.Handles.initScroll.setViewportView(h.InputDialog.Initialtable.STable);
end 

function localTabChanged(eventSrc, eventData, state, Jtabs)

% Callback to change tab state
state.CurrentTab = double(Jtabs.getSelectedIndex)+1;

function localMenuEnable(eventSrc, eventData, state, editMenu, fileMenu)

if state.CurrentTab == 1
    awtinvoke(editMenu,'setEnabled(Z)',true);
    awtinvoke(fileMenu,'setEnabled(Z)',true);
else
    awtinvoke(editMenu,'setEnabled(Z)',false);
    awtinvoke(fileMenu,'setEnabled(Z)',false);
end


function localTimeImport(eventSrc, eventData, state)
% open time vector importer

import java.awt.*;
import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

if isempty(state.initialtable) %nothing created yet
	awtinvoke(state.handles.frame,'setCursor(Ljava.awt.Cursor;)',Cursor(Cursor.WAIT_CURSOR));
end

% If an importselector doesn't exist create one. Make the frame visible
if isempty(state.TimeImportDialog)
    state.TimeImportDialog = state.timeimport;
    awtinvoke(state.TimeImportDialog.Frame,'setVisible(Z)',true);
else
    state.TimeImportDialog.workbrowser.open([1 NaN; NaN 1]);
    awtinvoke(state.TimeImportDialog.Frame,'setVisible(Z)',true);
end

awtinvoke(state.handles.frame,'setCursor(Ljava.awt.Cursor;)',Cursor(Cursor.DEFAULT_CURSOR));




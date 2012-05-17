function Frame = exportdlg(this)
%EXPORTDLG  Opens and manages the export dialog.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.25.4.12 $  $Date: 2010/04/21 21:10:46 $
import com.mathworks.mwt.*;
import java.awt.*;

% GUI data structure
s = struct(...
    'LoopData',this.LoopData,...
    'MatFile','',...
    'DesignNames',[],...
    'ModelList',[],...
    'Preferences',cstprefs.tbxprefs,...
    'Frame',[],...
    'Table',[],...
    'DesignSelect',[],...
    'Handles',[],...
    'Listeners',[]);

% Frame
Frame = MWFrame(sprintf('SISO Tool Export'));
s.Frame = Frame;

% Main panel
MainPanel = MWPanel(MWGridLayout(3,2,0,0));
MainPanel.setInsets(Insets(12,5,5,5));
Frame.add(MainPanel,MWBorderLayout.CENTER);

% Add components
s = LocalBuildDialog(s,MainPanel,this);

% Layout
Frame.pack;

% Center wrt SISO Tool window
centerfig(Frame,this.Figure);

% Install listeners
s.Listeners = [...
      handle.listener(s.LoopData,'ObjectBeingDestroyed',{@LocalClose Frame});...
      handle.listener(s.LoopData,'ConfigChanged',{@LocalConfigCB Frame}); ...
      handle.listener(s.LoopData,s.LoopData.findprop('LoopView'),'PropertyPostSet',{@LocalRefresh Frame})];

% Set callbacks and store handles 
set(Frame,'UserData',s);
hc = handle(Frame, 'callbackproperties');
set(hc,'WindowClosingCallback',@(es,ed) LocalHide(es,ed,Frame));
set(hc,'WindowActivatedCallback',@(es,ed) LocalRefresh(es,ed,Frame));

LocalRefresh([],[],Frame);  % populate to limit flashing

% Make frame visible
Frame.show;
Frame.toFront;


%--------------------------Callback Functions------------------------

%%%%%%%%%%%%%%%%%
%%% LocalHide %%%
%%%%%%%%%%%%%%%%%
function LocalHide(hSrc,event,f)
% Hide dialog
awtinvoke(f,'hide');


%%%%%%%%%%%%%%%%%%
%%% LocalClose %%%
%%%%%%%%%%%%%%%%%%
function LocalClose(hSrc,event,f)
% Hide dialog
awtinvoke(f,'hide');
f.dispose


%%%%%%%%%%%%%%%%%%%%%
%%% LocalConfigCB %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalConfigCB(hSrc,event,f)
% Handles change in configuration
if f.isVisible && f.isMaximized
   s = get(f,'UserData');
   if s.DesignSelect.getSelectedIndex<=0
      % Update table contents
      LocalRefresh([],[],f);  
   end
end

%%%%%%%%%%%%%%%%%%%%%
%%% LocalEditCell %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalEditCell(hSrc,event,f)
% Edit export name
s = get(f,'UserData');
t = s.Table;
CBdata = hSrc.ValueChangedCallbackData; % callback data
row = CBdata.getRow;
col = CBdata.getColumn;

% Check if new name is a valid variable name
NewName = t.getCellData(row,col);
if isvarname(NewName)
    % Replace name in model list
    s.ModelList(row+1).ExportAs = strrep(NewName,' ','');
    set(f,'UserData',s)
else
    % Revert to old name
    t.setCellData(row,col,CBdata.getPreviousValue);
end

    
%%%%%%%%%%%%%%%%%%%%
%%% LocalRefresh %%%
%%%%%%%%%%%%%%%%%%%%
function LocalRefresh(hSrc,event,Frame)
% Refresh export list
s = get(Frame,'UserData');
if ~isa(s.LoopData,'sisodata.loopdata')
    % Protect against race condition when SISO Tool is closed
    return
end

% Update list of designs
NewDesigns = [{sprintf('(current)')} ; get(s.LoopData.History,{'Name'})];
PopUp = s.DesignSelect;
SelectedDesign = min(max(0,PopUp.getSelectedIndex),length(NewDesigns)-1);
if ~isequal(NewDesigns,s.DesignNames)
   % Update popup menu
   PopUp.removeAll;
   for ct = 1:length(NewDesigns)
      PopUp.add(sprintf(NewDesigns{ct}));
   end
   PopUp.select(SelectedDesign);
   PopUp.repaint;
   s.DesignNames = NewDesigns;
end

% Get new model list
NewModelList = LocalExportList(s.LoopData,SelectedDesign);
if ~isequal(s.ModelList,NewModelList)
   % Update table contents
   if ~isempty(s.ModelList)
      % Inherit export names for non modified components
      NewModelList = LocalInherit(NewModelList,s.ModelList);
   end
   s.ModelList = NewModelList;
   
   % Adjust table size
   t = s.Table;
   td = t.getData;
   nrows = t.getTableSize.height;
   nmodels = size(NewModelList,1);
   if nmodels>nrows
      td.addRows(nrows,nmodels-nrows);
   end
   
   % Update table content
   for ctrow=1:nmodels
      td.setData(ctrow-1,0,NewModelList(ctrow).Description);
      td.setData(ctrow-1,1,NewModelList(ctrow).ExportAs);
   end
   for ctrow=nmodels:t.getTableSize.height-1
      td.setData(ctrow,0,'');
      td.setData(ctrow,1,'');
   end
end

% Store modified data
set(Frame,'UserData',s)


%%%%%%%%%%%%%%%%%%%
%%% LocalExport %%%
%%%%%%%%%%%%%%%%%%%
function LocalExport(hSrc,event,Frame,Target);
% Exports selected models
s = get(Frame,'UserData');
ModelList = s.ModelList;
LoopData = s.LoopData;

% Get selection
t = s.Table;
Selection = 1+double(t.getSelectedRows);
Selection(Selection>size(ModelList,1)) = [];  % ignore blank line selections
numSel = length(Selection);
if numSel==0
   warndlg('You have not specified which models to export.','Export Warning','modal');
   return
end

% Get export names and models
ModelInfo = cell(numSel,2);  % {ExportName ModelData}
ModelInfo(:,1) = {ModelList(Selection).ExportAs}';
if s.DesignSelect.getSelectedIndex<=0
   % Current design
   for ct=1:numSel
      [sysnom,sys] = LoopData.getmodel(ModelList(Selection(ct)).LoopTransfer);
      if isempty(sys)
          ModelInfo{ct,2} = sysnom;
      else
          ModelInfo{ct,2} = sys;
      end
   end
else
   % Saved design
   for ct=1:numSel
      ModelInfo{ct,2} = ModelList(Selection(ct)).Value;
   end
end

% Export
try
    switch Target
    case 'd'
        % Export to disk
        if ~isempty(s.MatFile)
            fname = s.MatFile; 
        else
            fname = sprintf('%s.mat',s.LoopData.Name);
        end
        [fname,p] = uiputfile(fname,'Export to Disk');
        if ischar(fname),
            [fname,r] = strtok(fname,'.');
            fname = fullfile(p,[fname '.mat']);
            s.MatFile = fname;
            set(Frame,'UserData',s);
            Protected_File_Name = fname;
            for ct=1:numSel
                eval(sprintf('%s = ModelInfo{%d,2};',ModelInfo{ct,1},ct));
            end    
            save(Protected_File_Name,ModelInfo{:,1});
        end
        
    case 'w',
        %---Callback from the Export to Workspace button
        w = evalin('base','whos');
        VarNames = {w.name};
        
        % Ask for confirmation if workspace contains variables with the same names 
        if any(ismember(ModelInfo(:,1),VarNames)) & strcmpi(questdlg(...
                {'At least one of the variables you are exporting'
                'already exists in the workspace.'
                ' ';
                'Exporting will overwrite the existing variables.'
                ' '
                'Do you want to continue?'},...
                'Variable Name Conflict','Yes','No','No'),'no')
            % Abort
            return
        end
        
        for ct=1:numSel
            assignin('base',ModelInfo{ct,1},ModelInfo{ct,2});
        end
    end
    awtinvoke(Frame,'hide');
catch ME
    errordlg(ltipack.utStripErrorHeader(ME.message),'Export Error');
end



%--------------------------Utility Functions------------------------


%%%%%%%%%%%%%%%%%%%%
%%% LocalInherit %%%
%%%%%%%%%%%%%%%%%%%%
function NewList = LocalInherit(NewList,OldList)
% Inherits export names from old list when model name is the same
[junk,ia,ib] = intersect({NewList.Description},{OldList.Description});
for ct=1:length(ia)
    % Loop over components
    NewList(ia(ct)).ExportAs = OldList(ib(ct)).ExportAs;
end
    

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalExportList %%%
%%%%%%%%%%%%%%%%%%%%%%%
function ModelList = LocalExportList(LoopData,SelectedDesign)
% Constructs export list
if SelectedDesign==0
   % Exporting from current design
   LoopTF = LoopData.LoopView; % all loop transfers
   ntf = length(LoopTF);
   
   % Sort to put G and C components first
   Types = get(LoopTF,{'Type'});
   isCG = strcmp(Types,'G') | strcmp(Types,'C');
   LoopTF = [LoopTF(isCG) ; LoopTF(~isCG)];
   nCG = sum(isCG);
   
   % Build display list
   ModelList = struct('Description',cell(ntf+1,1),'ExportAs',[],'LoopTransfer',[]);
   for ct=1:ntf
      ltf = LoopTF(ct);
      ModelList(ct).Description = ltf.Description;
      if ct<=nCG
         switch ltf.Type
            case 'C'
               C = LoopData.C(ltf.Index);
               if isempty(C.Variable)
                  ModelList(ct).ExportAs = C.Identifier;
               else
                  ModelList(ct).ExportAs = C.Variable;
               end
            case 'G'
               G = LoopData.Plant.G(ltf.Index);
               if isempty(G.Variable)
                  ModelList(ct).ExportAs = G.Identifier;
               else
                  ModelList(ct).ExportAs = G.Variable;
               end
         end
      else
         % Plant or compensator component
         ModelList(ct).ExportAs = ltf.ExportAs;
      end
      ModelList(ct).LoopTransfer = ltf;
   end
   
   % MIMO closed-loop system
   ModelList(ntf+1).Description = 'MIMO Closed Loop';
   ModelList(ntf+1).ExportAs = 'T';
   tcl = sisodata.looptransfer;
   tcl.Type = 'Tss';
   ModelList(ntf+1).LoopTransfer = tcl;
   
else
   % Exporting from saved designs
   Design = LoopData.History(SelectedDesign);
   LoopTF = Design.getLoopView;
   Types = get(LoopTF,{'Type'});
   LoopG = LoopTF(strcmp(Types,'G'));
   nf = length(LoopG);  
   LoopC = LoopTF(strcmp(Types,'C'));
   nt = length(LoopC);  
   ModelList = struct('Description',cell(nt+nf,1),'ExportAs',[],'Value',[]);
   for ct=1:nt
      Cid = Design.Tuned{LoopC(ct).Index};
      C = Design.(Cid);               
      ModelList(ct).Description = LoopC(ct).Description;
      if isempty(C.Variable)
         ModelList(ct).ExportAs = Cid;
      else
         ModelList(ct).ExportAs = C.Variable;
      end
      ModelList(ct).Value = C.Value;
   end
   for ct=1:nf
      Gid = Design.Fixed{LoopG(ct).Index};
      G = Design.(Gid);               
      ModelList(ct+nt).Description = LoopG(ct).Description;
      if isempty(G.Variable)
         ModelList(ct+nt).ExportAs = Gid;
      else
         ModelList(ct+nt).ExportAs = G.Variable;
      end
      ModelList(ct+nt).Value = G.Value;
   end
end
   
   
%--------------------------Rendering Functions------------------------


%%%%%%%%%%%%%%%%%%%%
%%% LocalAddList %%%
%%%%%%%%%%%%%%%%%%%%
function s = LocalBuildDialog(s,MainPanel,this)
% Adds Export List panel
import com.mathworks.mwt.*;
import java.awt.*;
Prefs = s.Preferences;

% Design selection panel in (1,1) position
P1 = MWPanel(MWBorderLayout);
P1.setInsets(Insets(0,0,10,0));% top,left,bottom,right
MainPanel.add(P1);
% Label
Label1 = MWLabel(sprintf(' Select design:  '));
Label1.setFont(s.Preferences.JavaFontP);
P1.add(Label1,MWBorderLayout.WEST);
% Popup
Choice = MWChoice;
Choice.setFont(Prefs.JavaFontP);
hc = handle(Choice, 'callbackproperties');
set(hc,'ItemStateChangedCallback',@(es,ed) LocalRefresh(es,ed,s.Frame));
P1.add(Choice,MWBorderLayout.CENTER);
s.DesignSelect = Choice;

% Blank in (1,2) position
Blank1 = MWLabel(sprintf(' '));      
MainPanel.add(Blank1);

% Select model label in (2,1) position
Label2 = MWLabel(sprintf(' Select models to export:'));
Label2.setFont(s.Preferences.JavaFontP);
MainPanel.add(Label2);

% Blank area in (2,2) position
Blank2 = MWLabel(sprintf(' '));      
MainPanel.add(Blank2);

% Table view in (3,1) position
Table = MWTable(20,2);
Table.setPreferredTableSize(11,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);
Table.setColumnHeaderData(0,sprintf('Component'));
Table.setColumnHeaderData(1,sprintf('Export As'));
Table.setColumnWidth(0,150);
Table.setColumnWidth(1,140);
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));
Table.setColumnStyle(0,Cstyle);
Cstyle = table.Style(table.Style.EDITABLE);
Cstyle.setEditable(1);
Table.setColumnStyle(1,Cstyle);
Table.setAutoExpandColumn(2);
Table.getRowOptions.setHeaderVisible(0);
Topt = Table.getSelectionOptions;
Topt.setMode(3);      % complex
Topt.setSelectBy(1);  % by row
hc = handle(Table, 'callbackproperties');
set(hc,'ValueChangedCallback',@(es,ed) LocalEditCell(es,ed,s.Frame));
s.Table = Table;
MainPanel.add(Table);

% Buttons
% Main panel
P2 = MWPanel(MWBorderLayout);
P2.setInsets(Insets(20,8,20,0)); % top,left,bottom,right
MainPanel.add(P2);
GL = GridLayout(2,1,0,5);
BP1 = MWPanel(GL);
BP2 = MWPanel(GL);
P2.add(BP1,MWBorderLayout.NORTH);
P2.add(BP2,MWBorderLayout.SOUTH);

% Buttons
B1 = MWButton(sprintf('  Export to Workspace  '));  
B1.setFont(s.Preferences.JavaFontP);
hc = handle(B1, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) LocalExport(es,ed,s.Frame,'w'));
B2 = MWButton(sprintf('Export to Disk ...'));       
B2.setFont(s.Preferences.JavaFontP);
hc = handle(B2, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) LocalExport(es,ed,s.Frame,'d'));
B3 = MWButton(sprintf('Cancel'));  
B3.setFont(s.Preferences.JavaFontP);
hc = handle(B3, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) LocalHide(es,ed,s.Frame));
B4 = MWButton(sprintf('Help'));       
B4.setFont(s.Preferences.JavaFontP);
hc = handle(B4, 'callbackproperties');
set(hc,'ActionPerformedCallback',@(es,ed) ctrlguihelp('sisoexportdialog'));

% Connect components
BP1.add(B1);
BP1.add(B2);
BP2.add(B3);
BP2.add(B4);

s.Handles = {MainPanel;P1;P2;BP1;BP2;B1;B2;B3;B4;Label1;Label2;Blank1;Blank2};

function s = build(this)
%BUILD  Builds new constraint dialog

%   Authors: P. Gahinet
%   Revised: A. Stothert, converted to MJcomponents
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2010/03/26 17:49:51 $

%Import packages
import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.control.util.*;
import com.mathworks.toolbox.control.plotconstr.*;

% Preferences
Prefs = cstprefs.tbxprefs;

% Frame
Frame = awtcreate('com.mathworks.toolbox.control.plotconstr.FrameWithDone',...
   'Ljava.lang.String;',ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNewDlgNewDesignRequirement'));
awtinvoke(Frame.getContentPane(),'setLayout(Ljava.awt.LayoutManager;)',java.awt.BorderLayout(0,0));
awtinvoke(Frame,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Frame,'setName(Ljava.lang.String;)',java.lang.String('frmNewRequirement'));
awtinvoke(Frame,'setResizable(Z)',true)
l = handle(Frame,'callbackproperties');
l.WindowClosingCallback = {@localHide this};

% Constraint Panel
TypePanel = MJPanel(java.awt.BorderLayout(0,0));
awtinvoke(TypePanel,'setBorder(Ljavax.swing.border.Border;)', BorderFactory.createEmptyBorder(8,5,8,5) );
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',TypePanel,java.awt.BorderLayout.NORTH);

%Constraint text and combo box
TypeText = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNewDlgDesignRequirementType'));
awtinvoke(TypeText,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(TypePanel,'add(Ljava.awt.Component;Ljava.lang.Object;)',TypeText,java.awt.BorderLayout.WEST);
TypeSelect = MJComboBoxForLongStrings;
awtinvoke(TypeSelect,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(TypeSelect,'setName(Ljava.lang.String;)',java.lang.String('cmbType'));
awtinvoke(TypePanel,'add(Ljava.awt.Component;Ljava.lang.Object;)',TypeSelect,java.awt.BorderLayout.CENTER);
set(handle(TypeSelect, 'callbackproperties'),'ItemStateChangedCallback',{@localSetType this}); %Creates hg wrapper for TypeSelect! Needed as we use the UserData property
    
% Parameter frame
ParamBox = MJPanel(java.awt.BorderLayout(10,0));
awtinvoke(ParamBox,'setBorder(Ljavax.swing.border.Border;)',...
   BorderFactory.createTitledBorder(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNewDlgDesignRequirementParameters')) )
awtinvoke(ParamBox,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);

% Button panel
ButtonPanel = MJPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,5,0));
awtinvoke(ButtonPanel,'setBorder(Ljavax.swing.border.Border;)', BorderFactory.createEmptyBorder(2,0,3,0) );
%---OK
OK = MJButton(sprintf('OK')); 
awtinvoke(OK,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(OK,'setName(Ljava.lang.String;)',java.lang.String('btnOK'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',OK);
l = handle(OK,'callbackproperties');
l.ActionPerformedCallback = {@localAddConstr this};
%---Cancel
Cancel = MJButton(sprintf('Cancel'));
awtinvoke(Cancel,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Cancel,'setName(Ljava.lang.String;)',java.lang.String('btnCancel'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',Cancel);
l = handle(Cancel,'callbackproperties');
l.ActionPerformedCallback = {@localHide this};
%---Help
Help = MJButton(sprintf('Help'));
awtinvoke(Help,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Help,'setName(Ljava.lang.String;)',java.lang.String('btnHelp'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',Help);
l = handle(Help,'callbackproperties');
l.ActionPerformedCallback = {@localHelp this 'constraintnewdlg'};
% Put GUI together
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',ParamBox,java.awt.BorderLayout.CENTER);
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',ButtonPanel,java.awt.BorderLayout.SOUTH);

% Store Handles
s = struct(...
	'Frame',Frame,...
	'ParamBox',ParamBox,...
	'TypeSelect',TypeSelect,...
	'Handles',{{TypePanel TypeText ButtonPanel OK Cancel Help}});
end

%% Manage dialog close action
function localHide(~,~,this)
% Hides dialog
this.close;
end

%% Manage OK button action
function localAddConstr(~,~,this)
% Add constraint to client list (includes rendering)
Client = this.Client;
Constr = this.Constraint;

% Hide New Constraint dialog (decouples it from constraint)
this.close;

if isa(Client,'sltoolboxdatanodes.RequirementsFolderNode') || ...
      isa(Client, 'checkpack.absCheckVisual')
   %New dialog called from Model Explorer. 
   Client.addconstr(Constr)
   return
end

if ~isempty(Constr)
   % Start recording
   T = ctrluis.ftransaction(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNewDlgAddRequirement'));
      
   %Construct graphical view for the requirement
   PlotAxes = getaxes(Client.Axes);
   
   if isa(Client,'sisogui.grapheditor')
      sisodb = Client.up;
      hC = Constr.Requirement.getView(Client);
      hC.PatchColor = sisodb.Preferences.RequirementColor;
   elseif isa(Client,'resppack.respplot')
      hC = Constr.Requirement.getView(Client);
      hC.PatchColor = Client.Options.RequirementColor;
   else
      hC = Constr.Requirement.getView(PlotAxes(1));
   end
   
   %Special case handling for dampingratio constraints
   if isa(Constr,'editconstr.DampingRatio')
       hC.Format = Constr.Type;
   end
   
   % Create copy (ensures Undo Add works properly, especially wrt connect)
   OrigConstr = struct(...
      'Type', class(hC), ...
      'Parent', hC.Elements.Parent, ...
      'PatchColor', hC.PatchColor, ...
      'Data', hC.save);
   T.Redo = {@localRedoAdd Client OrigConstr};
   T.Undo = {@localUndoAdd hC};

   % Add to client list (takes care of rendering)
   Client.addconstr(hC);
   % Mark constraint as selected
   hC.Selected = 'on';
   % Commit and stack transaction
   hC.EventManager.record(T);
   % Notify client listeners that new requirement added
   ed = plotconstr.constreventdata(Client,'RequirementAdded');
   ed.Data = hC;
   Client.send('RequirementAdded',ed);
end
end

%% Manage select type combobox action
function localSetType(eventSrc,eventData,this)
% Select constraint type
if( isequal(eventData.getStateChange,java.awt.event.ItemEvent.SELECTED))
   %New combo box selection made
   ud = this.List;
   idx = get(eventSrc,'SelectedIndex')+1;
   if (idx > 0 && idx <= size(ud,1)) && ~isempty(this.Constraint)
      this.settype(ud{idx,1});
   end
end
end

%% Manage help button action
function localHelp(~,~,this,topic)
%Display edit help

mapfile = this.Constraint.HelpData.MapFile;
try
   helpview([docroot mapfile],topic)
catch E %#ok<NASGU>
   errordlg(ctrlMsgUtils.message('Controllib:graphicalrequirements:errHelpPage',mapfile, topic))
end
end

%% Undo 'add constraint' function for transaction handler 
function localUndoAdd(Constr)
%Local undo method for constraint add.

Constr.Selected = 'off';  %Forces delete of whole constraint
Constr.delete
end

%% Redo 'add constraint' function for transaction handler
function localRedoAdd(Client, ConstrData)
%Local redo method for add constraint

Constr = feval(ConstrData.Type,...
   'Parent',     ConstrData.Parent, ...
   'PatchColor', ConstrData.PatchColor);
Constr.load(ConstrData.Data);
Client.addconstr(Constr);
Constr.Selected = 'on';
end

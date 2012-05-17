function s = build(this)
%BUILD  Builds edit constraint dialog.

%   Authors: P. Gahinet, A. Stothert
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:30:59 $

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
   'Ljava.lang.String;',ctrlMsgUtils.message('Controllib:graphicalrequirements:lblEdtDlgEditDesignRequirement'));
awtinvoke(Frame.getContentPane(),'setLayout(Ljava.awt.LayoutManager;)',java.awt.BorderLayout(0,0));
awtinvoke(Frame,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Frame,...
   'setName(Ljava.lang.String;)',...
   java.lang.String('frmEditRequirement'));
awtinvoke(Frame,'setResizable(Z)',true)
l = handle(Frame,'callbackproperties');
l.WindowClosingCallback = {@localHide this};

% Constraint Type
TypePanel = MJPanel(java.awt.BorderLayout(10,0));
awtinvoke(TypePanel,'setBorder(Ljavax.swing.border.Border;)', BorderFactory.createEmptyBorder(8,5,11,3) );
TypeText = MJLabel(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblEdtDlgDesignRequirement'));
awtinvoke(TypeText,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(TypePanel,'add(Ljava.awt.Component;Ljava.lang.Object;)',TypeText,java.awt.BorderLayout.WEST);
ConstrSelect = MJComboBoxForLongStrings;
awtinvoke(ConstrSelect,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(ConstrSelect,'setName(Ljava.lang.String;)',java.lang.String('cmbRequirement'));
awtinvoke(TypePanel,'add(Ljava.awt.Component;Ljava.lang.Object;)',ConstrSelect,java.awt.BorderLayout.CENTER);
l = handle(ConstrSelect,'callbackproperties');
l.ItemStateChangedCallback = {@localSetConstr this};
    
% Parameter frame
ParamBox = MJPanel(java.awt.BorderLayout(10,0));
awtinvoke(ParamBox,'setBorder(Ljavax.swing.border.Border;)',...
   BorderFactory.createTitledBorder(ctrlMsgUtils.message('Controllib:graphicalrequirements:lblNewDlgDesignRequirementParameters')) )
awtinvoke(ParamBox,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);

% Button panel
ButtonPanel = MJPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,5,0));
awtinvoke(ButtonPanel,'setBorder(Ljavax.swing.border.Border;)', BorderFactory.createEmptyBorder(2,0,3,0) );
%---OK
OK = MJButton(sprintf('Close'));    
awtinvoke(OK,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(OK,'setName(Ljava.lang.String;)',java.lang.String('btnOK'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',OK);
l = handle(OK,'callbackproperties');
l.ActionPerformedCallback = {@localHide this};
%---Help
Help = MJButton(sprintf('Help'));
awtinvoke(Help,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Help,'setName(Ljava.lang.String;)',java.lang.String('btnHelp'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',Help);
l = handle(Help,'callbackproperties');
l.ActionPerformedCallback = {@localHelp this 'sisoconstraintedit'};

% Put GUI together
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',TypePanel,java.awt.BorderLayout.NORTH);
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',ParamBox,java.awt.BorderLayout.CENTER);
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',ButtonPanel,java.awt.BorderLayout.SOUTH);

% Store Handles
s = struct('Frame', Frame, ...
	   'ParamBox', ParamBox, ...
	   'TypeSelect', ConstrSelect, ...
	   'Handles', {{TypePanel TypeText ButtonPanel OK Help}});
end
   
%% Manage close dialog action
function localHide(~,~,this)
% Hides dialog
this.close;
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

%% Manage Select Constraint combobox action
function localSetConstr(PopUp, eventData, h)
if( isequal(eventData.getStateChange,java.awt.event.ItemEvent.SELECTED))
   %New constraint selected
   if ~isempty(h.ConstraintList)
      List = h.ConstraintList;
      index = get(PopUp, 'SelectedIndex') + 1;
      h.target(List(index));
      %Set frame done state to true, only used for testing
      h.Handles.Frame.setDone(true)
   end
end
end
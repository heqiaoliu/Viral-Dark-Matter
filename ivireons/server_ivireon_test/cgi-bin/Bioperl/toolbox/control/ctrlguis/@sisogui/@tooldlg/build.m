function s = build(this)
%BUILD  Builds edit constraint dialog

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised: A.Stothert, converted to MJcomponents
%   Copyright 1986-2009 The MathWorks, Inc. 
%   $Revision: 1.6.4.9 $ $Date: 2009/02/06 14:16:33 $

%Import packages
import java.awt.*;
import javax.swing.* ;
import javax.swing.border.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.control.util.*;
import com.mathworks.toolbox.control.plotconstr.*;

% Definitions & Preferences
Prefs  = cstprefs.tbxprefs;
GL_11  = java.awt.GridLayout(1,1,0,3);

% Main Frame
Frame = awtcreate('com.mathworks.toolbox.control.plotconstr.FrameWithDone', ...
   'Ljava.lang.String;', sprintf('Edit Design Requirements'));
awtinvoke(Frame.getContentPane(),'setLayout(Ljava.awt.LayoutManager;)',java.awt.BorderLayout(0,0));
awtinvoke(Frame,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Frame,...
   'setName(Ljava.lang.String;)',...
   java.lang.String('frmEditRequirement'));
awtinvoke(Frame,'setResizable(Z)',true);
l = handle(Frame,'callbackproperties');
l.WindowClosingCallback = {@localHide this};

% Constraint Panel
P1 = MJPanel(java.awt.BorderLayout(0,0));
awtinvoke(P1,'setBorder(Ljavax.swing.border.Border;)', BorderFactory.createEmptyBorder(8,5,8,5) );
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',P1, java.awt.BorderLayout.NORTH);

% Editor/Constraint text
P2 = MJPanel(GL_11);
T1 = MJLabel(sprintf('Design requirement: '));
awtinvoke(T1,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP)
awtinvoke(P2,'add(Ljava.awt.Component;)',T1);
awtinvoke(P1,'add(Ljava.awt.Component;Ljava.lang.Object;)',P2, java.awt.BorderLayout.WEST);

% Editor/Constraint drop-down list
% P3 = MWPanel(GL_21);
P3 = MJPanel(GL_11);
EditorSelect = MJComboBox;
ConstrSelect = MJComboBoxForLongStrings;
awtinvoke(ConstrSelect,...
   'setName(Ljava.lang.String;)',...
   java.lang.String('cmbRequirement'));
awtinvoke(ConstrSelect,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(P3,'add(Ljava.awt.Component;)',ConstrSelect);
l = handle(ConstrSelect,'callbackproperties');
l.ItemStateChangedCallback = {@localSetConstr this};
l = handle(ConstrSelect,'callbackproperties');
l.FocusGainedCallback = {@localRefreshConstr this};
awtinvoke(P1,'add(Ljava.awt.Component;Ljava.lang.Object;)',P3, java.awt.BorderLayout.CENTER);

% Parameter frame
ParamBox = MJPanel(java.awt.BorderLayout(10,0));
awtinvoke(ParamBox,'setBorder(Ljavax.swing.border.Border;)',BorderFactory.createTitledBorder(sprintf('Design requirement parameters')) )
awtinvoke(ParamBox,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',ParamBox, java.awt.BorderLayout.CENTER);

% Button panel
ButtonPanel = MJPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,5,0));
awtinvoke(ButtonPanel,'setBorder(Ljavax.swing.border.Border;)', BorderFactory.createEmptyBorder(2,0,3,0) );
awtinvoke(Frame.getContentPane(),'add(Ljava.awt.Component;Ljava.lang.Object;)',ButtonPanel, java.awt.BorderLayout.SOUTH);
% Close button
Close = MJButton(sprintf('Close'));
awtinvoke(Close,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Close,'setName(Ljava.lang.String;)',java.lang.String('btnOK'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',Close);
l = handle(Close,'callbackproperties');
l.ActionPerformedCallback = {@localHide this};
% Help button
Help = MJButton(sprintf('Help'));
awtinvoke(Help,'setFont(Ljava.awt.Font;)',Prefs.JavaFontP);
awtinvoke(Help,...
   'setName(Ljava.lang.String;)',...
   java.lang.String('btnHelp'));
awtinvoke(ButtonPanel,'add(Ljava.awt.Component;)',Help);
l = handle(Help,'callbackproperties');
l.ActionPerformedCallback = @localHelp;
 
% Store Handles
s = struct('Frame', Frame, ...
	   'ParamBox', ParamBox, ...
	   'ConstrSelect', ConstrSelect, ...
	   'EditorSelect', EditorSelect, ...
	   'Handles', {{P1 P2 P3 ButtonPanel T1 Close Help}});

%% Manage dialog close action
function localHide(eventSrc,eventData,this)
this.close;

%% Manage Select Constraint combobox action
function localSetConstr(eventSrc, eventData, this)
if( isequal(eventData.getStateChange,java.awt.event.ItemEvent.SELECTED))
   %New constraint selected
   List = this.ConstraintList;
   index = min(get(eventSrc, 'SelectedIndex') + 1,numel(List));
   this.target(this.Container, List(index));
end

%% Manage focus gained on combobox
function localRefreshConstr(eventSrc,eventData,this)

this.ConstraintList = this.ConstraintList(isvalid(this.ConstraintList));
this.refresh('Constraints')

%% Manage help button callback
function localHelp(eventSrc,eventData)
ctrlguihelp('sisoconstraintedit');
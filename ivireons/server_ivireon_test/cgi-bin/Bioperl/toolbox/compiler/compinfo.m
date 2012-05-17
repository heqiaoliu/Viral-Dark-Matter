function compinfo(componentname, wrap)
%COMPINFO Component information dialog

error(nargchk(1,2,nargin, 'struct'));

%If component info dialog is already, show it
infof = getappdata(0,'CompInfo');
if ~isempty(infof)
    infof.dispose;
end

global wrapper;
if nargin==1
    wrapper='';
else
    wrapper=wrap;
end

%Get raw component information
ci = componentinfo(componentname);
if isempty(ci)
  errordlg(sprintf('No information found for component: %s ',componentname))
  return
end

%Create revision numbers
revnums = cell(length(ci),1);
for i = 1:length(ci)
  revnums{i} = [num2str(ci(i).MajorRev) '.' num2str(ci(i).MinorRev)];
end
  
%imports
import java.awt.*;
import javax.swing.*;
import javax.swing.tree.*;
import javax.swing.border.*;

%Build dialog with component information
[dfp,mfp,bspc,bhgt,bwid] = spacingparams;

%Create base frame
infof = JFrame(['Component - ' componentname]);
imic = javax.swing.ImageIcon(fullfile(matlabroot,'toolbox/matlab/icons/matlabicon.gif'));
im = imic.getImage;
infof.setIconImage(im);
infof.setName('ComponentInformationDialog');
set(infof,'WindowClosingCallback', {@closecompinfo, infof})
p = get(0,'DefaultFigurePosition');
top = p(4)-2*bhgt-bspc;
rgt = 8*bspc+5*bwid;
infof.setBounds(p(1),p(2),rgt,top);

%Base panel
BasePanel = JPanel;
BasePanel.setLayout(BorderLayout(bspc,bspc));
%BasePanel.setBorder(LineBorder(java.awt.Color(0,0,0)))
setproperties(BasePanel);
infof.getContentPane.add(BasePanel);

%Tree Panel
TreePanel = JPanel;
TreePanel.setLayout(BorderLayout(bspc,bspc));
setproperties(TreePanel);
BasePanel.add(TreePanel,BorderLayout.NORTH);

%Tree viewer
top = DefaultMutableTreeNode(['Name - ' upper(componentname)]);
tree = DefaultTreeModel(top);
ui.ProjectTree = JTree(tree);
setproperties(ui.ProjectTree);

%Add tree information

%Revision, etc information
Versions = DefaultMutableTreeNode('Version');
for i = 1:length(revnums)
  
  %Revision numbers
  Revnum = DefaultMutableTreeNode(revnums{i});
  
  %ID information
  TypeLibrary = DefaultMutableTreeNode(['Type Library: ' ci(i).TypeLib]);
  LibID = DefaultMutableTreeNode(['Library ID: ' ci(i).LIBID]);
  FileName = DefaultMutableTreeNode(['File Name: ' ci(i).FileName]);
  Revnum.add(TypeLibrary)
  Revnum.add(LibID)
  Revnum.add(FileName)
  
  %Class information
  Class = DefaultMutableTreeNode('Classes');
  numclasses = length(ci(i).CoClasses);
  for j = 1:numclasses
    
    ClassName = DefaultMutableTreeNode(['Name: ' ci(i).CoClasses(j).Name]);
    ClassID = DefaultMutableTreeNode(['Class ID: ' ci(i).CoClasses(j).CLSID]);
    ProgID = DefaultMutableTreeNode(['Program ID: ' ci(i).CoClasses(j).ProgID]);
    InProcServ = DefaultMutableTreeNode(['In Process Server: ' ci(i).CoClasses(j).InprocServer32]);
    ClassName.add(ClassID)
    ClassName.add(ProgID)
    ClassName.add(InProcServ)
    
    %Methods information
    Methods = DefaultMutableTreeNode('Methods');
    nummethods = length(ci(i).CoClasses(j).Methods);
    for k = 1:nummethods
      methM = DefaultMutableTreeNode(ci(i).CoClasses(j).Methods(k).M);
      Methods.add(methM);
    end
    ClassName.add(Methods)
    
    %Properties information
    Properties = DefaultMutableTreeNode('Properties');
    numprops = length(ci(i).CoClasses(j).Properties);
    for m = 1:numprops
      prop = DefaultMutableTreeNode(ci(i).CoClasses(j).Properties{m});
      Properties.add(prop);
    end
    ClassName.add(Properties)
    
    %Events information
    Events = DefaultMutableTreeNode('Events');
    numevents = length(ci(i).CoClasses(j).Events);
    for n = 1:numevents
      evnt = DefaultMutableTreeNode(ci(i).CoClasses(j).Events(n).M);
      Events.add(evnt);
    end
    ClassName.add(Events)
    
    Class.add(ClassName)
    
  end
 
  %Interface information
  Interfaces = DefaultMutableTreeNode('Interfaces');
  for j = 1:length(ci(i).Interfaces)
     IntName = DefaultMutableTreeNode(['Name: ' ci(i).Interfaces(j).Name]);
     IntID = DefaultMutableTreeNode(['Interface ID: ' ci(i).Interfaces(j).IID]);
     Interfaces.add(IntName)
     Interfaces.add(IntID)
  end
  Revnum.add(Class)
  Revnum.add(Interfaces)
  Versions.add(Revnum)
end
top.add(Versions)

%Make tree scrollable
ui.TreeScrollPane = JScrollPane;
ui.TreeScrollPane.getViewport.add(ui.ProjectTree);
TreePanel.add(ui.TreeScrollPane,BorderLayout.CENTER);
ui.ProjectTree.expandRow(1)

%Panel for Help and Close buttons
CompInfoBottomPanel = JPanel;
CompInfoBottomPanel.setLayout(GridLayout(1,3,bspc,bspc));
setproperties(CompInfoBottomPanel);
BasePanel.add(CompInfoBottomPanel,BorderLayout.SOUTH);

%Help button
ui.HelpButton = JButton(sprintf('Help'));
setproperties(ui.HelpButton)
set(ui.HelpButton,'ActionPerformedCallback',{@helpcompinfo,infof})
CompInfoBottomPanel.add(ui.HelpButton);

%Creating padding objects
BlankLabel = JLabel;
setproperties(BlankLabel);
CompInfoBottomPanel.add(BlankLabel);

%Close button
ui.CloseButton = JButton(sprintf('Close'));
setproperties(ui.CloseButton)
set(ui.CloseButton,'ActionPerformedCallback',{@closecompinfo, infof})
CompInfoBottomPanel.add(ui.CloseButton);

infof.show
setappdata(0,'CompInfo',infof)   %Store handle in case project or parent dialog gets closed

function [dfp,mfp,bspc,bhgt,bwid] = spacingparams()
%SPACINGPARAMS Dialog ui spacing parameters.

dfp = get(0,'DefaultFigurePosition');
mfp = [560 420];    %Reference width and height
bspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
bhgt = 20/mfp(2) * dfp(4);
bwid = 80/mfp(1) * dfp(3);

function setproperties(textobj)
%SETTEXTPROPERTIES sets the font, size, color, etc of text of the given object

%imports
import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;

%Set default properties
uiFontName = get(0,'Defaultuicontrolfontname');
uiFontSize = 12;
uiFontColor = get(0,'Defaultuicontrolforegroundcolor');
uiBackGround = get(0,'Defaultuicontrolbackgroundcolor');

textobj.setFont(Font(uiFontName,0,uiFontSize))
set(textobj,'Foreground',uiFontColor)
objtype = class(textobj);

%Set background
switch objtype
  case {'javax.swing.JTextArea','javax.swing.JTree','javax.swing.JTextField','javax.swing.JList'}
    %leave background unchanged
  otherwise
    set(textobj,'Background',uiBackGround)
end

%Set border
switch objtype
  case {'javax.swing.JButton'}
    textobj.setBorder(BevelBorder(0));
  case {'javax.swing.JTextArea','javax.swing.JTree','javax.swing.JList'}
    textobj.setBorder(BevelBorder(1));
end


function closecompinfo(obj,evd,f)
%CLOSECOMPINFO Close component information dialog.
rmappdata(0,'CompInfo')   %Remove the handle for the frame.
f.dispose


function helpcompinfo(obj,evd,f)
%HELPCOMPINFO Component info help.
global wrapper;

mapfile = [docroot '\toolbox\dotnetbuilder\dotnetbuilder.map'];
if strcmpi(wrapper, 'excel') || ...
           ~exist(mapfile, 'file') 
    mapfile = [docroot '\toolbox\matlabxl\matlabxl.map'];
end
if( ~exist(mapfile,'file') )
    error('Compiler:noDOC',...
          ['Could not locate MATLAB Builder NE or '...
           'MATLAB Builder EX documentation. ',...
           'Check if you DOCROOT is set correctly.']);
end

mapentry = 'component_info';
helpview(mapfile,mapentry, 'CSHelpWindow')




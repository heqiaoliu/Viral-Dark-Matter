function dlgstruct = annotationddg(h, name) %#ok
% ANNOTATIONDDG Dynamic dialog for Simulink Annotation type objects.

% To lauch this dialog in MATLAB, use:
%    >> vdp             % load a model
%    Right click on an annotation and select "Annotation Properties..."

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.9 $

  clickDesc.Name = [DAStudio.message('Simulink:dialog:AnnotationClickDescNamePartOne'), 10, ...
                    DAStudio.message('Simulink:dialog:AnnotationClickDescNamePartTwo')];
  clickDesc.Type = 'text';
  clickDesc.WordWrap = true;
  clickDesc.Tag = 'ClickDesc';

  useTextForClickFcn.Name    = DAStudio.message('Simulink:dialog:AnnotationUseTextForClickFcnName');
  useTextForClickFcn.Type    = 'checkbox';
  useTextForClickFcn.Tag     = 'useTextAsClickFcn';
  useTextForClickFcn.ObjectProperty    = 'UseDisplayTextAsClickCallback';
  useTextForClickFcn.MatlabMethod = 'annotationddg_cb';
  useTextForClickFcn.MatlabArgs = {'%dialog','doUseTextAsClickFcn'};
  
  
  clickFcnEdit.Name    = '';
  clickFcnEdit.Tag = 'clickFcnEdit';
  clickFcnEdit.Type    = 'editarea';
  clickFcnEdit.ObjectProperty    = 'ClickFcn';
  prevClickFcn = h.ClickFcn;
  clickFcnEdit.UserData = prevClickFcn;
  
  if (strcmp(h.UseDisplayTextAsClickCallback,'on'))
    clickFcnEdit.Enabled = 0;
  else
    clickFcnEdit.Enabled = 1;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % description container items
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  % description    
  desc.Name    = DAStudio.message('Simulink:dialog:AnnotationDescName');
  desc.Type            = 'text';
  desc.WordWrap        = true;
  desc.Tag            = 'TextDesc';
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % apearance container items
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  annText.Name = DAStudio.message('Simulink:dialog:AnnotationAnnTextName');
  annText.Type = 'editarea';
  annText.ObjectProperty = 'Text';
  annText.Tag = 'text';
  annText.RowSpan = [1 1];
  annText.ColSpan = [1 3];
  annText.MaximumSize = [5000 80];
  
  % This dummy widget (and the others below) are here to force the dialog
  % into refreshing when the property in question changes
  % The real widgets have some dialog-specific logic attached to them, and
  % are not connected directly to the UDD properties, so without the dummy widgets,
  % the dialog engine would not know it needed to refresh the dialog.

  dropShadow.Name = DAStudio.message('Simulink:dialog:AnnotationDropShadowName');
  dropShadow.Type = 'checkbox';
  dropShadow.Tag  = 'dropShadow';
  dropShadow.ObjectProperty = 'DropShadow';
  dropShadow.RowSpan = [2 2];
  dropShadow.ColSpan = [1 2];
  
  interpretMode.Name = DAStudio.message('Simulink:dialog:AnnotationTexModeName');
  interpretMode.Tag  = 'interpreter';
  interpretMode.Type = 'checkbox';
  if (strcmp(h.Interpreter, 'off'))
      interpretMode.Value = 0;
  else
      interpretMode.Value = 1;
  end
  interpretMode.RowSpan = [3 3];
  interpretMode.ColSpan = [1 2];
  
  interpretDummy.Type = 'edit';
  interpretDummy.ObjectProperty = 'Interpreter';
  interpretDummy.Visible = 0;
  interpretDummy.Tag = 'InterpretDummy';
  
  font.Name = DAStudio.message('Simulink:dialog:AnnotationFontName');
  font.Type = 'pushbutton';
  font.Tag  = 'font';
  font.ObjectMethod = 'showFontDialog';
  font.RowSpan = [4 4];
  font.ColSpan = [1 1];
     
  foreground.Name = DAStudio.message('Simulink:dialog:AnnotationForegroundName');
  foreground.Tag  = 'foreground';
  foreground.Type = 'combobox';
  foreground.Entries = colorNames();
  foreground.RowSpan = [2 2];
  foreground.ColSpan = [3 3];
  foreground.MatlabMethod = 'annotationddg_cb';
  foreground.MatlabArgs = {'%dialog','doForeground'};
  fgUserData.wasSet = false;
  foreground.UserData = fgUserData;
  foreground.Value = colorPropNameIndex(h.ForegroundColor);
  
  foregroundDummy.Type = 'edit';
  foregroundDummy.ObjectProperty = 'ForegroundColor';
  foregroundDummy.Visible = 0;
  
  background.Name = DAStudio.message('Simulink:dialog:AnnotationBackgroundName');
  background.Tag  = 'background';
  background.Type = 'combobox';
  background.Entries = colorNames();
  background.RowSpan = [3 3];
  background.ColSpan = [3 3];
  background.MatlabMethod = 'annotationddg_cb';
  background.MatlabArgs = {'%dialog','doBackground'};
  bgUserData.wasSet = false;
  background.UserData = bgUserData;
  background.Value = colorPropNameIndex(h.BackgroundColor);
  
  backgroundDummy.Type = 'edit';
  backgroundDummy.ObjectProperty = 'BackgroundColor';
  backgroundDummy.Visible = 0;
  backgroundDummy.Tag = 'BackgroundDummy';

  alignment.Name = DAStudio.message('Simulink:dialog:AnnotationAlignmentName');
  alignment.Tag  = 'alignment';
  alignment.Type = 'combobox';
  alignment.Entries = {'Left', 'Center', 'Right'};
  alignment.RowSpan = [4 4];
  alignment.ColSpan = [3 3];
  alignment.Value = alignmentPropNameIndex(h.HorizontalAlignment);
  
  alignDummy.Type = 'edit';
  alignDummy.ObjectProperty = 'HorizontalAlignment';
  alignDummy.Visible = 0;
  alignDummy.Tag = 'AlignDummy';

  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Top level containers
  %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Description container
  description.Type    = 'group';
  description.Name    = DAStudio.message('Simulink:dialog:AnnotationDescriptionName');
  description.Flat    = false;
  description.Items   = {desc};
  description.ToolTip = DAStudio.message('Simulink:dialog:AnnotationDescriptionToolTip');
  description.RowSpan = [1 1];
  description.Tag    = 'Description';
  
  appearanceGroup.Type    = 'group';
  appearanceGroup.Name    = DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupName');
  appearanceGroup.Flat    = false;
  appearanceGroup.Items   = {annText, dropShadow, interpretMode, font, foreground, background, alignment, interpretDummy, foregroundDummy, backgroundDummy, alignDummy};
  appearanceGroup.ToolTip = DAStudio.message('Simulink:dialog:AnnotationAppearanceGroupToolTip');
  appearanceGroup.LayoutGrid = [4 3];
  appearanceGroup.ColStretch = [0 1 1];
  appearanceGroup.RowSpan = [2 2];
  appearanceGroup.Tag    = 'AppearanceGroup';
  
  activeGroup.Type    = 'group';
  activeGroup.Name    = DAStudio.message('Simulink:dialog:AnnotationActiveGroupName');
  activeGroup.Flat    = false;
  activeGroup.Items   = {clickDesc, useTextForClickFcn, clickFcnEdit};
  activeGroup.ToolTip = DAStudio.message('Simulink:dialog:AnnotationActiveGroupToolTip');
  activeGroup.RowSpan = [3 3];
  activeGroup.Tag    = 'ActiveGroup';
  
  
  %%%%%%%%%%%%%%%%%%%%%%%
  % Main dialog
  %%%%%%%%%%%%%%%%%%%%%%%
  
  title = DAStudio.message('Simulink:dialog:AnnotationTitlePartial', strtok(h.Name, char(10)));
  dlgstruct.DialogTitle = title;
  dlgstruct.HelpMethod = 'helpview';
  dlgstruct.HelpArgs =  {[docroot '/mapfiles/simulink.map'], 'annotation_props_dlg'};
  dlgstruct.LayoutGrid = [3 1];
  dlgstruct.RowStretch = [0 0 1];
  dlgstruct.ColStretch = [1];
  dlgstruct.PreApplyCallback = 'annotationddg_cb';
  dlgstruct.PreApplyArgs = {'%dialog','doApply'};
  dlgstruct.MinimalApply = true;
  dlgstruct.Items = {description, appearanceGroup, activeGroup};
  dlgstruct.DialogTag        = name;
  
  
  
function names = colorNames()
    names = {'Custom', 'Black', 'White', 'Red', 'Green', 'Blue', 'Yellow', 'Magenta', 'Cyan', 'Gray', 'Orange', 'Light Blue', 'Dark Green'};
  
% Color constants (derived from ui_types.h)    
function index = colorPropNameIndex(name)
index = 0; % custom
switch name
    case 'black'
        index = 1;
    case 'white'
        index = 2;
    case 'red'
        index = 3;
    case 'green'
        index = 4;
    case 'blue'
        index = 5;
    case 'yellow'
        index = 6;
    case 'magenta'
        index = 7;
    case 'cyan'
        index = 8;
    case 'gray'
        index = 9;
    case 'orange'
        index = 10;
    case 'lightBlue'
        index = 11;
    case 'darkGreen'
        index = 12;
end
  
% Alignment constants    
function index = alignmentPropNameIndex(name)
index = 0;
switch name
    case 'left'
        index = 0;
    case 'center'
        index = 1;
    case 'right'
        index = 2;
end
  

% Latexxx LaTeX feature turned off 
% Interpret constants     
% function index = interpretPropNameIndex(name)
% index = 0;
% switch name
%     case 'off'
%         index = 0;
%     case 'tex'
%         index = 1;
%     case 'latex'
%         index = 2;
% end
  

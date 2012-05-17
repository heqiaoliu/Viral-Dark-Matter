function result = createFigureDefaultMenubar(fig,deploy)
%CREATEFIGUREDEFAULTMENUBAR Create default menus.
%
%  FIGUREDEFAULTMENUBAR(F) creates the default figure menus on figure F.
%
%  If the figure handle F is not specified, 
%  FIGUREDEFAULTMENUBAR operates on the current figure(GCF).
%
%  FIGUREDEFAULTMENUBAR(F,true) creates the default menus 
%  on figure F for a deployment-only figure
%
%  If the deploy is not specified, FIGUREDEFAULTMENUBAR operates in normal mode.
%
%  H = FIGUREDEFAULTMENUBAR(...) returns the handles to the new figure children.

%  Copyright 2009-2010 The MathWorks, Inc.


if nargin==1, deploy = false; end

%  '>&New Figure^N',      '',                       SHARED_NEW_CALLBACK,
%  %ToDo

%   Menu String        Deploy   Tag                       Callback
menus= {
  '&File',               1,  'figMenuFile',            'filemenufcn FilePost'
  '>&New^N',             1,  'figMenuUpdateFileNew',   'filemenufcn(gcbf,''UpdateFileNew'')'
  '>>&Script^N'          0,  'figMenuNewCodeFile',     'filemenufcn(gcbf,''NewCodeFile'')'
  '>>&Figure'            1,  '',                       SHARED_NEW_CALLBACK
  '>>&Model'             0,  'figMenuFileNewModel',    'filemenufcn(gcbf,''NewModel'')'
  '>>&Variable'          0,  'figMenuFileNewVariable', 'filemenufcn(gcbf,''NewVariable'')'
  '>>&GUI'               0,  'figMenuNewGUI',          'filemenufcn(gcbf,''NewGUI'')'
  '>&Open...^O',         1,  '',                       SHARED_OPEN_CALLBACK
  '>&Close^W',           1,  'figMenuFileClose',       'filemenufcn(gcbf,''FileClose'')'
  '>-----',              1,  '',                       '%-----'
  '>&Save^S',            1,  'figMenuFileSave',        SHARED_SAVE_CALLBACK
  '>Save &As...',        1,  'figMenuFileSaveAs',      'filemenufcn(gcbf,''FileSaveAs'')'
  '>Generate Code...',   0,  'figMenuGenerateCode',    'filemenufcn(gcbf,''GenerateCode'')'
  '>-----',              1,  '',                       '%-----'
  '>&Import Data...',    0,  'figMenuFileImportData',  'filemenufcn(gcbf,''FileImportData'')'
  '>Save &Workspace As...',0,'figMenuFileSaveWorkspaceAs', 'filemenufcn(gcbf,''FileSaveWS'')'
  '>-----',              0,  '',                       '%-----'
  '>Pre&ferences...',    0,  'figMenuFilePreferences', 'filemenufcn(gcbf,''FilePreferences'')'
  '>-----',              0,  '',                       '%-----'
  '>Expo&rt Setup...',   1,  'figMenuFileExportSetup', 'filemenufcn(gcbf,''FileExportSetup'')'
  '>Print Pre&view...',  1,  'figMenuFilePrintPreview','filemenufcn(gcbf,''FilePrintPreview'')'
  '>&Print...^P',        1,  '',                       SHARED_PRINT_CALLBACK
  '>-----',              0,  '',                       '%-----'
  '>&Exit MATLAB',       0,  'figMenuFileExitMatlab',  'filemenufcn(gcbf,''FileExitMatlab'')'

  ...

  '&Edit',               0,  'figMenuEdit',            'editmenufcn(gcbf,''EditPost'')'
  '>&Undo^Z'             0,  'figMenuEditUndo',        'editmenufcn(gcbf,''EditUndo'')'
  '>&Redo^Y'             0,  'figMenuEditRedo',        ''
  '>-----',              0,  '',                       '%-----'
  '>Cu&t^X',             0,  'figMenuEditCut',         'editmenufcn(gcbf,''EditCut'')'
  '>&Copy^C',            0,  'figMenuEditCopy',        'editmenufcn(gcbf,''EditCopy'')'
  '>&Paste^V',           0,  'figMenuEditPaste',       'editmenufcn(gcbf,''EditPaste'')'
  '>Clea&r Clipboard',   0,  'figMenuEditClear',       'editmenufcn(gcbf,''EditClear'')'
  '>Delete',             0,  'figMenuEditDelete',      'editmenufcn(gcbf,''EditDelete'')'
  '>-----',              0,  '',                       '%-----'
  '>&Select All^A',      0,  'figMenuEditSelectAll',   'editmenufcn(gcbf,''EditSelectAll'')'
  '>-----',              0,  '',                       '%-----' % Removed Pin
  '>Copy &Figure',       0,  'figMenuEditCopyFigure',  'editmenufcn(gcbf,''EditCopyFigure'')'
  '>Copy &Options...',   0,  'figMenuEditCopyOptions', 'editmenufcn(gcbf,''EditCopyOptions'')'
  '>-----',              0,  '',                       '%-----'
  '>F&igure Properties...', 0, ...
                         'figMenuEditGCF',         'editmenufcn(gcbf,''EditFigureProperties'')'
  '>&Axes Properties...', 0, ...
                         'figMenuEditGCA',         'editmenufcn(gcbf,''EditAxesProperties'')'
  '>Current Ob&ject Properties...', 0, ...
                         'figMenuEditGCO',         'editmenufcn(gcbf,''EditObjectProperties'')'
  '>Color&map...',       0, 'figMenuEditColormap',    'editmenufcn(gcbf,''EditColormap'')'
  '>-----',              0, '',                       '%-----'
  '>&Find Files...',     0, 'figMenuEditFindFiles',   'editmenufcn(gcbf,''EditFindFiles'')'
  '>-----',              0, '',                       '%-----'
  '>Clear &Figure',      0, 'figMenuEditClearFigure', 'editmenufcn(gcbf,''EditClearFigure'')'
  '>Clear &Command Window', 0, 'figMenuEditClearCmdWindow','editmenufcn(gcbf,''EditClearCommandWindow'')'
  '>Clear &Command History',0, 'figMenuEditClearCmdHistory','editmenufcn(gcbf,''EditClearCommandHistory'')'
  '>Clear &Workspace',   0,    'figMenuEditClearWorkspace', 'editmenufcn(gcbf,''EditClearWorkspace'')'
  ...

  '&View',               0,  'figMenuView',             'viewmenufcn ViewPost'
  '>&Figure Toolbar',    0,  'figMenuFigureToolbar',    'viewmenufcn FigureToolbar'
  '>&Camera Toolbar',    0,  'figMenuCameraToolbar',    'viewmenufcn CameraToolbar'
  '>&Plot Edit Toolbar', 0,  'figMenuPloteditToolbar',  'viewmenufcn PloteditToolbar'
  '>-----',              0,  '',                        '%-----'
  '>Figure Palette',     0,  'figMenuFigurePalette',    'viewmenufcn FigurePalette'
  '>Plot Browser' ,      0,  'figMenuPlotBrowser',      'viewmenufcn PlotBrowser'
  '>Property Editor',    0,  'figMenuPropertyEditor',   'viewmenufcn PropertyEditor'

  ...

  '&Insert',             0,  'figMenuInsert',          'insertmenufcn InsertPost'
  '>&X Label',           0,  'figMenuInsertXLabel',    'insertmenufcn Xlabel'
  '>&Y Label',           0,  'figMenuInsertYLabel',    'insertmenufcn Ylabel'
  '>&Z Label',           0,  'figMenuInsertZLabel',    'insertmenufcn Zlabel'
  '>&Title',             0,  'figMenuInsertTitle',     'insertmenufcn Title'
  '>-----',              0,  '',                       '%-----'
  '>&Legend',            0,  'figMenuInsertLegend',    'insertmenufcn Legend'
  '>&Colorbar',          0,  'figMenuInsertColorbar',  'insertmenufcn Colorbar'
  '>-----',              0,  '',                       '%-----'
  '>Li&ne',              0,  'figMenuInsertLine',      'insertmenufcn Line'
  '>A&rrow',             0,  'figMenuInsertArrow',     'insertmenufcn Arrow'
  '>T&ext Arrow',        0,  'figMenuInsertTextArrow', 'insertmenufcn TextArrow'
  '>Dou&ble Arrow',      0,  'figMenuInsertArrow2',    'insertmenufcn DoubleArrow'
  '>TextB&ox',           0,  'figMenuInsertTextbox',   'insertmenufcn Textbox'
  '>Rectan&gle',         0,  'figMenuInsertRectangle', 'insertmenufcn Rectangle'
  '>Elli&pse',           0,  'figMenuInsertEllipse',   'insertmenufcn Ellipse'
  '>-----',              0,  '',                       '%-----'
  '>&Axes',              0,  'figMenuInsertAxes',      'insertmenufcn Axes'
  '>L&ight',             0,  'figMenuInsertLight',     'insertmenufcn Light'

  ...

   '&Tools',                        0,  'figMenuTools',           'toolsmenufcn ToolsPost'
  '>&Edit Plot',                    0,  'figMenuToolsPlotedit',   'toolsmenufcn PlotEdit'
  '>-----',                         0,  '',                       '%-----'
  '>&Zoom In',                      0,  'figMenuZoomIn',          'toolsmenufcn ZoomIn'
  '>Zoom &Out',                     0,  'figMenuZoomOut',         'toolsmenufcn ZoomOut'
  '>&Pan',                          0,  'figMenuPan',             'toolsmenufcn Pan'
  '>&Rotate 3D',                    0,  'figMenuRotate3D',        'toolsmenufcn Rotate'
  '>D&ata Cursor',                  0,  'figMenuDatatip',         'toolsmenufcn Datatip'
  '>&Brush',                        0,  'figBrush',               'toolsmenufcn Brush'
  '>&Link',                         0,  'figLinked',              'toolsmenufcn Linked'
  '>Reset View',                    0,  'figMenuResetView',       'toolsmenufcn ResetView'
  '>Options',                       0,  'figMenuOptions',         'toolsmenufcn Options'
  '>>Unconstrained Zoom'            0,  'figMenuOptionsXYZoom',   'toolsmenufcn ZoomXY'
  '>>Horizontal Zoom'               0,  'figMenuOptionsXZoom',    'toolsmenufcn ZoomX'
  '>>Vertical Zoom'                 0,  'figMenuOptionsYZoom',    'toolsmenufcn ZoomY'
  '>>-----',                        0,  '',                       '%-----'
  '>>Unconstrained Pan '            0,  'figMenuOptionsXYPan',    'toolsmenufcn PanXY'
  '>>Horizontal Pan'                0,  'figMenuOptionsXPan',     'toolsmenufcn PanX'
  '>>Vertical Pan'                  0,  'figMenuOptionsYPan',     'toolsmenufcn PanY'
  '>>-----',                        0,  '',                       '%-----'
  '>>Display Cursor as Datatip'     0,  'figMenuOptionsDatatip',  'toolsmenufcn DatatipStyle'
  '>>Display Cursor in Window'      0,  'figMenuOptionsDataBar',  'toolsmenufcn DataBarStyle'
  '>-----',                         0,  '',                       '%-----'
  '>Pi&n to Axes',                  0,  'figMenuEditPinning',     'toolsmenufcn EditPinning'
  '>Snap To &Layout Grid',          0,  'figMenuSnapToGrid',      'toolsmenufcn ToggleSnapToGrid'
  '>View Layout Gr&id',             0,  'figMenuViewGrid',        'toolsmenufcn ToggleViewGrid'
  '>-----',                         0,  '',                       '%-----'
  '>&Smart Align and Distribute',   0,  'figMenuToolsAlignDistributeSmart',...
                                                                  'toolsmenufcn AlignDistributeSmart'
  '>Align Distrib&ute Tool ...',    0,  'figMenuToolsAlignDistributeTool',...
                                                                  'toolsmenufcn AlignDistributeTool'
  '>Ali&gn',                        0,  'figMenuToolsAlign',      'toolsmenufcn InitAlign'
  '>>Left Edges',                   0,  'figMenuToolsAlignLeft',  'toolsmenufcn AlignLeft'
  '>>Centers (X)',                  0,  'figMenuToolsAlignCenter','toolsmenufcn AlignCenter'
  '>>Right Edges',                  0,  'figMenuToolsAlignRight', 'toolsmenufcn AlignRight'
  '>>Top Edges',                    0,  'figMenuToolsAlignTop',   'toolsmenufcn AlignTop'
  '>>Middles (Y)',                  0,  'figMenuToolsAlignMiddle','toolsmenufcn AlignMiddle'
  '>>Bottom Edges',                 0,  'figMenuToolsAlignBottom','toolsmenufcn AlignBottom'
  '>Distri&bute',                   0,  'figMenuToolsAlign',      'toolsmenufcn InitAlignDistribute'
  '>>Vertical Adjacent Edges',      0,  'figMenuToolsDistributeVAdj',...
                                                                  'toolsmenufcn DistributeVAdj'
  '>>Vertical Top Edges',           0,  'figMenuToolsDistributeVTop',...
                                                                  'toolsmenufcn DistributeVTop'
  '>>Vertical Middles',             0,  'figMenuToolsDistributeVMid',...
                                                                  'toolsmenufcn DistributeVMid'
  '>>Vertical Bottom Edges',        0,  'figMenuToolsDistributeVBot',...
                                                                  'toolsmenufcn DistributeVBot'
  '>>Horizontal Adjacent Edges',    0,  'figMenuToolsDistributeHAdj',...
                                                                  'toolsmenufcn DistributeHAdj'
  '>>Horizontal Left Edges',        0,  'figMenuToolsDistributeHLeft',...
                                                                  'toolsmenufcn DistributeHLeft'
  '>>Horizontal Centers',           0,  'figMenuToolsDistributeHCent',...
                                                                  'toolsmenufcn DistributeHCent'
  '>>Horizontal Right Edges',       0,  'figMenuToolsDistributeHRight',...
                                                                  'toolsmenufcn DistributeHRight'
  '>B&rushing',                     0,  'figDataManagerBrushTools','toolsmenufcn InitBrush'  
  '>>Replace with',                 0,  'figDataManagerBrush',     'toolsmenufcn InitBrushReplace' 
  '>>>NaNs',                        0,  'figDataManagerReplaceNaN',{@datamanager.dataEdit 'replace' NaN}
  '>>>Constant...',                 0,  'figDataManagerReplaceConst',{@datamanager.dataEdit 'replace'}
  '>>Remove brushed',               0,  'figDataManagerRemove',   {@datamanager.dataEdit 'remove' false} 
  '>>Remove unbrushed',             0,  'figDataManagerRemoveUnbr',{@datamanager.dataEdit 'remove' true}   
  '>>Create new variable...',       0,  'figDataManagerNewVar',   {@datamanager.newvar}
  '>>-----',                        0,  '',                       '%-----'
  '>>Paste Data to Command Line',   0,  'figDataManagerPaste',    {@datamanager.paste}
  '>>-----',                        0,  '',                       '%-----'
  '>>Copy to clipboard',            0,  'figDataManagerCopy',     {@datamanager.copySelection} 
  '>-----',                         0,  '',                       '%-----'
  '>Basic &Fitting',                0,  'figMenuToolsBFDS',       'toolsmenufcn BasicFitting'
  '>&Data Statistics',              0,  'figMenuToolsBFDS',       'toolsmenufcn DataStatistics'

  ...

  '&Window',             0,  'figMenuWindow',           'winmenu(gcbo)'
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''
  '>blank',              0,  '',                        ''

  ...

  '&Help',                        0,  'figMenuHelp',          'helpmenufcn(gcbf,''HelpmenuPost'')'
  '>&Graphics Help',              0,  'figMenuHelpGraphics',  'helpmenufcn(gcbf,''HelpGraphics'')'
  '>-----',                       0,  '',                     '%-----'
  '>&Plotting Tools',             0,  'figMenuHelpPlottingTools',...
                                                              'helpmenufcn(gcbf,''HelpPlottingTools'')'
  '>&Annotating Graphs',          0,  'figMenuHelpAnnotatingGraphs',...
                                                              'helpmenufcn(gcbf,''HelpAnnotatingGraphs'')'
  '>Printing and &Exporting',     0,  'figMenuHelpPrintingExport',...
                                                              'helpmenufcn(gcbf,''HelpPrintingExport'')'
  '>-----',                       0,  '',                     '%-----'
  '>&Web Resources',              0,  'figMenuWeb',           'webmenufcn WebmenuPost'
  '>>The &MathWorks Web Site',    0,  'figMenuWebMathWorksHome',...
                                                              'webmenufcn MathWorksHome'
  '>>M&y MathWorks Account',      0,  'figMenuWebStudentAccount',...
                                                              'webmenufcn Login'
  '>>&Products & Services',       0,  'figMenuWebProducts',...
                                                              'webmenufcn Products'
  '>>&Support',                   0,  'figMenuWebTechSupport','webmenufcn TechSupport'
  '>>T&raining',                  0,  'figMenuWebTraining',   'webmenufcn Training'
  '>>Student FA&Q',               0,  'figMenuWebStudentFAQ', 'webmenufcn StudentFAQ'
  '>>St&udent Center',            0,  'figMenuWebStudentCenter', 'webmenufcn StudentCenter'
  '>>Purchase &Add-On Products'   0,  'figMenuWebStore',      'webmenufcn WebStore'
  '>>MathWorks &Account',         0,  'figMenuWebLogin',      'webmenufcn Login'
  '>>-----',                      0,  '',                     '%-----'
  '>>MATLAB &Central',            0,  'figMenuWebMATLABCentral',...
                                                              'webmenufcn MATLABCentral'
  '>>MATLAB &File Exchange',      0,  'figMenuWebFileExchange',...
                                                              'webmenufcn FileExchange'
  '>>MATLAB News&group Access',   0,  'figMenuWebNewsgroupAccess',...
                                                              'webmenufcn NewsgroupAccess'
  '>>MATLAB &Newsletters',        0,  'figMenuWebNewsletters','webmenufcn Newsletters'
  '>Get P&roduct Trials',         0,  'figMenuGetTrials',     'webmenufcn Trials'
  '>&Check for Updates',          0,  'figMenuHelpUpdates',   'webmenufcn CheckUpdates'
  '>Online Tutorials',            0,  'figMenuTutorials',     '%-----'
  '>>MATLAB Tutorials',           0,  'figMenuTutorialsMATLAB','helpmenufcn(gcbf,''HelpMLTutorials'')'
  '>>Simulink Tutorials',         0,  'figMenuTutorialsSimulink','helpmenufcn(gcbf,''HelpSLTutorials'')'
  '>-----',                       0,  '',                     '%-----'
  '>&Demos',                      0,  'figMenuDemos',         'helpmenufcn(gcbf,''HelpDemos'')'
  '>-----',                       0,  '',                     '%-----'
  '>&Check Activation Status',    0,  'figMenuHelpActivation','helpmenufcn(gcbf,''HelpActivation'')'
  '>&Terms of Use',               0,  'figMenuHelpTerms',     'helpmenufcn(gcbf,''HelpTerms'')'
  '>Pate&nts',                    0,  'figMenuHelpPatens',    'helpmenufcn(gcbf,''HelpPatents'')'
  '>-----',                       0,  '',                     '%-----'
  '>&About MATLAB',               0,  'figMenuHelpAbout',     'helpmenufcn(gcbf,''HelpAbout'')'
};

% Deal with menus with function handle callbacks
I = find(~cellfun('isclass',menus(:,4),'char'));
fcnHcallbacks = menus(I,4);
fcnHTags = menus(I,3);
menus(I,4) = {''};
h = makemenu(fig,char(menus{:,1}),char(menus{:,4}),char(menus{:,3}));
for k=1:length(I)
    mobj = findobj(h,'Tag',fcnHTags{k});
    if ~isempty(mobj)
        set(mobj,'Callback',fcnHcallbacks{k});
    end
end

wmenu = findobj(h,'tag','figMenuWindow');
set(allchild(wmenu), 'Visible', 'off');

if ~deploy
  % Special Case: The Desktop menu is created here instead of the makemenu
  % structure because we need a CreateFcn for the Desktop menu.
  menupos = get(wmenu, 'Position');
  h(end+1) =  uimenu(fig,     'Label',        '&Desktop', ...
                     'Position',     menupos, ...
                     'Callback',     'desktopmenufcn(gcbo, ''DesktopMenuPopulate'')', ...
                     'Tag',          'figMenuDesktop' , ...
                     'RequireJavaFigures',     'On');
else
  onoff = {'off','on'};

  % strip out separators since they don't have handles
  inds = [menus{:,2}];
  b = cellfun('isempty',strfind(menus(:,1),'---'));
  inds(~b) = [];

  onoff = onoff(inds+1);
  set(h,{'Visible'},onoff(:));
end

% Hide 'Exit MATLAB" menu item if figure is not docked.
%filemenu = findobj(h,'tag','figMenuFile');
%set(filemenu,'Callback','filemenufcn(gcbf,''FileMenuUpdate'')');

% Hide 'New Model' if simulink is not available

% disable cut, copy, paste, clear, selectall initially
set(findobj(h,'tag','figMenuEditCut'),'enable','off');
set(findobj(h,'tag','figMenuEditCopy'),'enable','off');
set(findobj(h,'tag','figMenuEditPaste'),'enable','off');
set(findobj(h,'tag','figMenuEditClear'),'enable','off');
set(findobj(h,'tag','figMenuEditSelectAll'),'enable','off');

%HGSAVE expects only the top-level handles
result = findobj(h,'flat','parent',fig);

set(h,allOptions);

% Make sure that the handle list returned is in the correct order w.r.t.
% the Desktop menu.
dtmenu = findobj(result,'tag','figMenuDesktop');
if ~isempty(dtmenu)
    wmenuindex = find(ismember(result, wmenu));
    result(wmenuindex+1:end) = result(wmenuindex:end-1);
    result(wmenuindex) = dtmenu;
end

result = flipud(result);

% Undo/Redo are disabled by default
hMenuUndo = findall(fig,'tag','figMenuEditUndo');
hMenuRedo = findall(fig,'tag','figMenuEditRedo');
set([hMenuUndo,hMenuRedo],'Enable','off');

function s = SHARED_NEW_CALLBACK
s = 'filemenufcn(gcbf,''FileNew'')';

function s = SHARED_OPEN_CALLBACK
s = 'filemenufcn(gcbf,''FileOpen'')';

function s = SHARED_SAVE_CALLBACK
s = 'filemenufcn(gcbf,''FileSave'')';

function s = SHARED_PRINT_CALLBACK
s = 'printdlg(gcbf)';

function s = allOptions
s = struct('Serializable',  'off',...
    'HandleVisibility',   'off');


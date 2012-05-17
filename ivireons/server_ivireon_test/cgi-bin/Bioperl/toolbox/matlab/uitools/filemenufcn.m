function filemenufcn(hfig, cmd)
%FILEMENUFCN Implements part of the figure file menu.
%  FILEMENUFCN(CMD) invokes file menu command CMD on figure GCBF.
%  FILEMENUFCN(H, CMD) invokes file menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    FileClose
%    FileExportSetup
%    FileNew
%    FileOpen
%    FilePageSetup
%    FilePreferences
%    FilePrintPreview
%    FilePrintSetup
%    FileSave
%    FileSaveAs

%    FileExport - merged into FileSaveAs
%    FilePost - internal use only

%  Copyright 1984-2009 The MathWorks, Inc.
%  $Revision: 1.17.4.24 $  $Date: 2010/05/20 02:29:55 $

error(nargchk(1,2,nargin));

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

hfig = double(hfig);
switch cmd
    case 'FilePost'
        localPost(hfig)
    case 'UpdateFileNew'
        localUpdateNewMenu(hfig)
    case 'FileNew'
        localNewFigure(hfig)       
    case 'NewGUI'
        guide
    case 'NewVariable'
        localNewVariable(hfig);
    case 'NewModel'
        % Availability of simulink is verified in 'UpdateFileNew'
        open_system(new_system);
    case 'NewCodeFile'
        editorservices.new;
    case 'FileOpen'
        uiopen figure
    case 'FileClose'
        close(hfig)
    case 'FileSave'
        localSave(hfig)
    case 'FileSaveAs'
        localSaveExport(hfig)
    case 'GenerateCode'
        makemcode(hfig,'Output','-editor');
    case 'FileImportData'
        uiimport('-file')
    case 'FileSaveWS'
        localFileSaveWS(hfig);
    case 'FileExport'
        localSaveExport(hfig)
    case 'FileExportSetup'
        exportsetupdlg(hfig)
    case 'FilePreferences'
        preferences
    case 'FilePageSetup'
        pagesetupdlg(hfig)
    case 'FilePrintSetup'
        printdlg -setup
    case 'FilePrintPreview'
        printpreview(hfig)
    case 'FileExitMatlab'
        exit
end

% --------------------------------------------------------------------
function  [jframe] = localGetJavaFrame(hfig)
% Get java frame for figure window

jframe = [];

% store the last warning thrown
[ lastWarnMsg lastWarnId ] = lastwarn;

% disable the warning when using the 'JavaFrame' property
% this is a temporary solution
oldJFWarning = warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jpeer = get(hfig,'JavaFrame');
warning(oldJFWarning.state, 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

% restore the last warning thrown
lastwarn(lastWarnMsg, lastWarnId);

if ~isempty(jpeer)
   jcanvas = jpeer.getAxisComponent; 
   jframe = javax.swing.SwingUtilities.getWindowAncestor(jcanvas);
end

% --------------------------------------------------------------------
function  localFileSaveWS(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getSaveWorkspaceAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

% --------------------------------------------------------------------
function  localNewVariable(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getNewVariableAction;    
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

% --------------------------------------------------------------------
function  localUpdateNewMenu(hfig)

% If no simulink, hide 'New Model' menu
res = which(fullfile(matlabroot,'toolbox/simulink/simulink/open_system'));
h = findall(hfig,'type','uimenu','Tag','figMenuFileNewModel');
if isempty(res)
    set(h,'Visible','off')
else
    set(h,'Visible','on');
end

% --------------------------------------------------------------------
function localPost(hfig)
   
filemenuchildren = findall(allchild(hfig),'type','uimenu','Tag','figMenuFile');

filemenuprefs = findall(filemenuchildren,'Tag','figMenuFilePreferences');
filemenuexit = findall(filemenuchildren,'Tag','figMenuFileExitMatlab');

% Hide callbacks that require a java frame
if (usejava('awt') ~= 1)
    set(findall(filemenuchildren,'tag','figMenuFileSaveWorkspaceAs'),'visible','off');
    set(findall(filemenuchildren,'tag','figMenuFileNewVariable'),'visible','off');      
end

if ismac
    % If on Mac, hide items already in the MATLAB menu
    set(filemenuprefs,'Visible','off');
    set(filemenuexit, 'Visible','off');
else
    % If figure is not docked, hide 'Exit MATLAB' menu
    if strcmp(get(hfig,'WindowStyle'),'docked')
        set(filemenuexit,'Visible','on');
    else
        set(filemenuexit,'Visible','off');
    end
    
    % hide java dependent items if java is not supported 
    if ~usejava('MWT')
        % Hide File -> Preferences
        set(filemenuprefs,'visible','off'); 
    end
end

% --------------------------------------------------------------------
function localNewFigure(hfig)

% Create a new figure replicating the WindowStyle from source figure.
figure('WindowStyle', get(hfig, 'WindowStyle'));

% --------------------------------------------------------------------
function localSave(hfig)
filename=get(hfig,'filename');
if isempty(filename)
  filemenufcn(hfig,'FileSaveAs');
else
  types = localExportTypes;
  typevalue = getappdata(hfig,LASTEXPORTEDASTYPE);
  if isempty(typevalue)
      % This is here for backwards compatibility: if there is no last
      % exported as type in the figure's appdata, use the extension
      [p, f, ext] = fileparts(filename);                                    %#ok
      typevalue = localGetTypeFromExtension(ext);
  end
  localSaveExportHelper(hfig, filename, types, typevalue);
end       

% --------------------------------------------------------------------
function success = localSaveExportHelper(hfig, filename, types, typevalue)

success = false;
setappdata(hfig,LASTEXPORTEDASTYPE,typevalue);
try
  if strcmp(types{typevalue,4},'fig')
    saveas(hfig,filename);
  else
    style = localGetStyle(hfig);
    hgexport(hfig,filename,style,'Format',types{typevalue,4});
  end
  set(hfig,'filename',filename);
  success = true;
catch ex
  uiwait(errordlg(ex.message,'Error Saving Figure','modal'));
end

% --------------------------------------------------------------------
function str = LASTEXPORTEDASTYPE
str = 'FileMenuFcnLastExportedAsType';

% --------------------------------------------------------------------
function [types,filter] = localGetTypes(type_id)
types = localExportTypes;

% since the file selection dialog does not allow us to pre-select which
% filter to use, we will always put the default one at the top of the
% list. 
%
% DO NOT CHANGE THIS BEHAVIOR WITHOUT LOOKING AT THE FUNCTION BELOW:
% getOriginalTypeValueFromLocalTypeValue().  IT UNDOES THE WORK OF THIS
% FUNCTION!
types = [types(type_id,:); types(1:type_id-1,:); types(type_id+1:end,:)];
filter = types(:,1:2);

% --------------------------------------------------------------------
function type_id = getOriginalTypeValueFromLocalTypeValue(localTypeValue, lastExportTypeValue)
% See localGetTypes function: when displaying the save dialog, the last
% exported as type is brought to the top of the list, thus changing the
% positions of many type values in the list.  This function converts the
% local type value back to the original type value by undoing the index
% change.
if (localTypeValue == 1)
    % If the local type value is the first item in the list, then it is
    % the last exported as type
    type_id = lastExportTypeValue;
elseif (localTypeValue <= lastExportTypeValue)
    % If the local type value is not the last exported as type, but is
    % indexed before the lastExportTypeValue, then it has been bumped
    % forward one position in the list to make room for the last exported
    % as type at the top of the list.  Subtract 1 to get the original
    % value.
    type_id = localTypeValue - 1;
else
    % Otherwise, the local type value is some index beyond where all of the
    % changes happened, meaning that this index is the same in the local
    % list as it was in the original list.  Keep it the same.
    type_id = localTypeValue;
end

% --------------------------------------------------------------------
function [filename, EXT] = localGetFilename(hfig,default_ext)

filename=get(hfig,'filename');

[PATH,FILENAME,EXT] = fileparts(filename);

if isempty(FILENAME)
    FILENAME = 'untitled';
end
if isempty(EXT)
    EXT = default_ext;
end

filename=[FILENAME EXT];

if ~isempty(PATH)
    filename = fullfile(PATH, filename);
end

% --------------------------------------------------------------------
function localSaveExport(hfig)
persistent dlgshown;

if ~isempty(dlgshown)
    return;
end

typesorig = localExportTypes;
lastexporttypevalue = localGetDefaultType(hfig, typesorig);
lastexport_ext = typesorig{lastexporttypevalue,3};

[filename, default_ext] = localGetFilename(hfig,lastexport_ext);        %#ok
[types,filter] = localGetTypes(lastexporttypevalue);

% uiputfile on unix will allow saving an empty file name, make sure we get
% a real one.
newfile='';
while isempty(newfile)
    dlgshown = true;
    [newfile, newpath, typevalue] = uiputfile(filter, 'Save As',filename);
    dlgshown = [];
end

if newfile == 0
    % user pressed cancel
    return;
end

% make sure a reasonable extension is used
[p,f,ext] = fileparts(newfile);                                         %#ok
if isempty(ext)
  ext = types{typevalue,3};
  newfile = [newfile ext];
end

filename=fullfile(newpath,newfile);
typevalueorig = getOriginalTypeValueFromLocalTypeValue(typevalue, lastexporttypevalue);

localSaveExportHelper(hfig, filename, typesorig, typevalueorig);
setappdata(0,LASTEXPORTEDASTYPE,typevalueorig);

% --------------------------------------------------------------------
function list=localExportTypes

% build the list dynamically from printtables.m
[a,opt,ext,d,e,output,name]=printtables;                                %#ok

% only use those marked as export types (rather than print types)
% and also have a descriptive name
valid=strcmp(output,'X') & ~strcmp(name,'') & ~strcmp(d, 'QT'); 
name = name(valid);
ext  = ext(valid);
opt  = opt(valid);

% remove eps formats except for the first one
iseps = strncmp(name,'EPS',3);
inds = find(iseps);
name(inds(2:end),:) = [];
ext(inds(2:end),:) = [];
opt(inds(2:end),:) = [];

for i=1:length(ext)
    ext{i} = ['.' ext{i}];
end
star_ext = ext;
for i=1:length(ext)
    star_ext{i} = ['*' ext{i}];
end
description = name;
for i=1:length(name)
    description{i} = [name{i} ' (*' ext{i} ')'];
end

% add fig file support to front of list
star_ext = {'*.fig',star_ext{:}};
description = {'MATLAB Figure (*.fig)',description{:}};
ext = {'.fig',ext{:}};
opt = {'fig',opt{:}};

[description,sortind] = sort(description);
star_ext = star_ext(sortind);
ext = ext(sortind);
opt = opt(sortind);

list = [star_ext(:), description(:), ext(:), opt(:)];

% --------------------------------------------------------------------
function style = localGetStyle(hfig)
style = getappdata(hfig,'Exportsetup');
if isempty(style)
  try
    style = hgexport('readstyle','Default');
  catch
    style = hgexport('factorystyle');
  end
end

% --------------------------------------------------------------------
function type_id = localGetDefaultType(hFig, types)
% First, check if the figure has a default type
type_id = getappdata(hFig,LASTEXPORTEDASTYPE);
if isempty(type_id)
    % Next, check if the app has a default type
    type_id = getappdata(0,LASTEXPORTEDASTYPE);
    if isempty(type_id)
        % No default types: default to fig
        typeformats = types(:,4);
        type_id = find(strcmp(typeformats,'fig'));
    end
end

% --------------------------------------------------------------------
function type_id = localGetTypeFromExtension(ext)
types = localExportTypes;
typeextensions = types(:,3);
type_ids = find(strcmp(typeextensions,ext));
type_id = type_ids(1);

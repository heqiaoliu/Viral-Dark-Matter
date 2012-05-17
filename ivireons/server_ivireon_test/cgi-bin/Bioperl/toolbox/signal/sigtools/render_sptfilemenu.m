function hfile = render_sptfilemenu(hFig)
%RENDER_SPTFILEMENU Render a Signal Processing Toolbox "File" menu.
%   HFILE = RENDER_SPTFILEMENU(HFIG) creates a "File" menu in the first position
%   on a figure whose handle is HFIG and return the handles to all the menu items.

%   Author(s): V.Pellissier
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2008/04/21 16:31:00 $ 

strs = {xlate('&File'), ...
        xlate('&Export...'), ...
        xlate('Pre&ferences...'), ...
        xlate('Pa&ge Setup...'), ...
        xlate('Print Set&up...'), ...
        xlate('Print Pre&view...'), ...
        xlate('&Print...'), ...
        xlate('&Close')};

% Use copied code from FILEMENUFCN to remove .FIG as an export option.
cbs = {'', ...
    {@localSaveExport, hFig}, ...
    'preferences;', ...
    'pagesetupdlg(gcbf);', ...
    'printdlg(''-setup'', gcbf);', ...
    'printpreview(gcbf);', ...
    'printdlg(gcbf);', ...
    'close(gcbf)'};

tags = {'file', ...
    'export', ...
    'preferences', ...
    'pagesetup', ...
    'printsetup', ...
    'printpreview', ...
    'print', ...
    'close'};

sep = {'off', ...
    'off', ...
    'on', ...
    'on', ...
    'off', ...
    'off', ...
    'off', ...
    'on'};

accel = {'', ...
    '', ...
    '', ...
    '', ...
    '', ...
    '', ...
    'P', ...
    'W'};

hfile = addmenu(hFig,1,strs,cbs,tags,sep,accel);

% -------------------------------------------------------------------------
function localSaveExport(hcbo, eventData, hfig)

typesorig = localExportTypes;
lastexporttypevalue = localGetDefaultType(hfig, typesorig);
lastexport_ext = typesorig{lastexporttypevalue,3};

[filename, default_ext] = localGetFilename(hfig,lastexport_ext);        %#ok
[types,filter] = localGetTypes(lastexporttypevalue);

% uiputfile on unix will allow saving an empty file name, make sure we get
% a real one.
newfile='';
while isempty(newfile)
    [newfile, newpath, typevalue] = uiputfile(filter, 'Save As',filename);
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
valid=strcmp(output,'X') & ~strcmp(name,'');
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

[description,sortind] = sort(description);
star_ext = star_ext(sortind);
ext = ext(sortind);
opt = opt(sortind);

list = [star_ext(:), description(:), ext(:), opt(:)];

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
function str = LASTEXPORTEDASTYPE
str = 'FileMenuFcnLastExportedAsType';

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
        type_id = find(strcmp(typeformats,'bitmap'));
    end
end

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
catch ME
  uiwait(errordlg(ME.message,'Error Saving Figure','modal'));
end

% --------------------------------------------------------------------
function style = localGetStyle(hfig)
style = getappdata(hfig,'Exportsetup');
if isempty(style)
  try
    style = hgexport('readstyle','Default');
  catch ME %#ok<NASGU> 
    style = hgexport('factorystyle');
  end
end

% [EOF]

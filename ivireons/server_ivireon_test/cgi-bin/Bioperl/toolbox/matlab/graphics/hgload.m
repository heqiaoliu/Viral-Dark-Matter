function [h, OldProps] = hgload(filename, varargin)
% HGLOAD  Loads Handle Graphics object from a file.
%
% H = HGLOAD('filename') loads handle graphics objects from the .fig
% file specified by 'filename,' and returns handles to the top-level
% objects. If 'filename' contains no extension, then the extension
% '.fig' is added.
%
% [H, OLD_PROPS] = HGLOAD(..., PROPERTIES) overrides the properties on
% the top-level objects stored in the .fig file with the values in
% PROPERTIES, and returns their previous values.  PROPERTIES must be a
% structure whose field names are property names, containing the
% desired property values.  OLD_PROPS are returned as a cell array the
% same length as H, containing the previous values of the overridden
% properties on each object.  Each cell contains a structure whose
% field names are property names, containing the original value of
% each property for that top-level object. Any property specified in
% PROPERTIES but not present on a top-level object in the file is
% not included in the returned structure of original values.
%
% HGLOAD(..., 'all') overrides the default behavior of excluding
% non-serializable objects saved in the file from being reloaded.
% Items such as the default toolbars and default menus are marked as
% non-serializable, and even if contained in the FIG-file, are
% normally not reloaded, because they are loaded from separate files
% at figure creation time.  This allows for revisioning of the default
% menus and toolbars without affecting existing FIG-files. Passing
% 'all' to HGLOAD insures that any non-serializable objects contained
% in the file are also reloaded. The default behavior of HGSAVE is to
% exclude non-serializable objects from the file at save time, and
% that can be overridden using the 'all' flag with HGSAVE.
% HGLOAD(..., 'all') produces a warning and the option will be removed in a
% future release.

% See also HGSAVE, HANDLE2STRUCT, STRUCT2HANDLE.

%   Copyright 1984-2010 The MathWorks, Inc.
%   D. Foti  11/10/97

% Add a .fig extension if we need to
[filePath,file,fileExt]=fileparts(filename);
if isempty(fileExt) || strcmp(fileExt, '.') % see hgsave.m
  filename = fullfile(filePath, [file , fileExt, '.fig']);
end

% Find the full path to the file.
fullpath = localFindFile(filename);

% Parse the optional input arguments
[LoadAll, OverrideProps] = localParseOptions(varargin);

% Put in place a recursion detection that prevents loading this file again.
% This can happen if a CreateFcn causes another hgload. Note that the
% unused guard variable here is required since it is keeping an onCleanup
% in scope.
Guard = localCheckRecursion(fullpath);  %#ok<NASGU>  

% Inspect file contents to determine fig format and the variables to load.
[FigVersion, FigData, VerNum] = localLoadFile(filename);

% Convert to HG objects
if ~feature('HGUsingMatlabClasses')
    % Warn if the user passed in the 'all' flag
    if LoadAll
        warning( id('DeprecatedOption'), ...
            'The ''all'' option to hgload will be removed in a future release.');
    end
    
    [h, OldProps] = hgloadStructDbl(FigData, fullpath, VerNum, LoadAll, OverrideProps);
    
else
    if LoadAll
        warning( id('DeprecatedOption'), ...
            'The ''all'' option to hgload has been removed.');
    end
    
    if FigVersion<3
        % Load from a structure
        h = hgloadStructClass(FigData);
    else
        % The loaded data is a vector of objects
        h = FigData;
    end
    
    % Common post-load actions for classes
    OldProps = localPostClassActions(h, fullpath, OverrideProps);
    
end
end    



function str = id(str)
str = ['MATLAB:hgload:' str];
end


function fullpath = localFindFile(filename)
% Find the full path to a file.

fullpath = which(filename);
if isempty(fullpath)
    fullpath = filename;
end

end


function [LoadAll, Props] = localParseOptions(args)
% Parse the optional inputs

% Default values
LoadAll = false;
Props = [];

for n = 1:length(args)
    opt = args{n};
    if strcmpi(opt, 'all')
        LoadAll = true;
        
    elseif isstruct(opt)
        % Merge the values into the current set of override property values
        if isempty(Props)
            Props = opt;
        else
            fields = fieldnames(opt);
            for m = 1:numel(fields);
                Props.(fields{m}) = opt.(fields{m});
            end
        end
   
    else
        % Error on any unrecognised option
        if ischar(opt)
            E = MException(id('InvalidOption'), ...
            'Invalid option: %s.', opt);
        else
            E = MException(id('InvalidOption'), ...
                'Optional input arguments must be strings or structs.' );    
        end
        E.throwAsCaller();
    end
end
end


function Remover = localCheckRecursion(filename)
persistent LoadingStack
if isempty(LoadingStack)
    LoadingStack = {};
end

% Check whether the specified file is already in the loading stack
if any(strcmp(filename, LoadingStack))
    error(id('RecursionDetected'), ...
        'Recursion occurs when loading %s.', filename);
end

% Add the file to the end of the stack
LoadingStack{end+1} = filename;

% Create a cleanup task that will take the file off the stack
Remover = onCleanup(@()nRemove(filename));

    function nRemove(filename)
        Match = strcmp(filename, LoadingStack);
        if any(Match)
            LoadingStack(Match) = [];
        end
    end
end


function [FigVersion, FigData, VerNum] = localLoadFile(filename)
% Determine the figure file format and use the correct variables from it.

AllVars = load(filename, '-mat');
AllVarNames = fieldnames(AllVars);

vars_hgS = regexp(AllVarNames, '^hgS.*', 'once', 'match');
vars_hgS = vars_hgS(~cellfun(@isempty, vars_hgS));

vars_hgO = regexp(AllVarNames, '^hgO.*', 'once', 'match');
vars_hgO = vars_hgO(~cellfun(@isempty, vars_hgO));


% Fig format version
FigVersion = -1;

VarToLoad = '';
if length(vars_hgS)==1
    % Version 2 files should have an hgS variable.
    FigVersion = 2;
    VarToLoad = vars_hgS{1};
    
    if length(vars_hgO)==1
        % Version 3 files should have an hgS and an hgO.  In this case use
        % the hgO.
        FigVersion = 3;
        VarToLoad = vars_hgO{1};
    end
end

if FigVersion==-1
    E = MException(id('InvalidFigFile'),'Invalid Figure file format.');
    E.throwAsCaller();
end

% Check the version that saved the file and warn the user if required
VerNum = localGetSaveVersion(VarToLoad);
VerStr = localGetSaveVersionString(VerNum);

if FigVersion > 2 && ~feature('HGUsingMatlabClasses')
    error(id('FileVersion'),...
        ['File %s contains objects that have been saved in a future version ' ...
        '(%s or later) of MATLAB.  To load the file in this version it must ' ...
        'be saved using a compatibility flag in hgsave.'], ...
        filename, VerStr);
    
elseif (VerNum > 70000 && ~feature('HGUsingMatlabClasses')) ...
        || VerNum >80000
    warning(id('FileVersion'),...
        'Figure file created with a newer version (%s or later) of MATLAB',...
        VerStr);
end

FigData = AllVars.(VarToLoad);
end


function VerNum = localGetSaveVersion(varname)
% Parse the saved version from a variable name string

VerString = regexp(varname, '_(.*)$', 'once', 'tokens');
VerNum = str2double(VerString{1});
end


function VerStr = localGetSaveVersionString(VerNum)
% Convert the saved version number to a 3-numeral version string, X.Y.Z.
Major = fix(VerNum/10000);
Minor = fix((VerNum-Major*10000)/100);
Rev = fix((VerNum-Major*10000-Minor*100));
VerStr = sprintf('%d.%d.%d', Major, Minor, Rev);
end


function OldProps = localPostClassActions(h, FileName, OverrideProps)
% Post-load actions that are common to loading when classes are enabled
%
%  * Set FileName property
%  * Determine an appropriate parent
%  * Set other properties that are specified as override values.

% All of the actions result in extra properties to set.  This cell array of
% structures holds the properties to set for each new object.
Props = cell(size(h));
Props(:) = {[]};
OldProps = Props;

% Add the FileName for figure objects
IsFig = ishghandle(h, 'figure');
Props(IsFig) = {struct('FileName', FileName)};

for n = 1:numel(h)
    % Look for an appropriate parent
    Props{n} = localGetParent(h(n), Props{n});
    
    if ~isempty(OverrideProps)
        % Work out which override properties work with each object class.
        [Props{n}, OldProps{n}] = localCheckProperties(h(n), Props{n}, OverrideProps);
    end
end

% Set all the new properties on each object.  This loop must be done after
% the previous one to ensure that all properties are found before new
% objects are connected into the existing hierarchy
for n = 1:numel(h)
    if ~isempty(Props{n})        
        set(h(n), Props{n});
    end
end

end


function Props = localGetParent(h, Props)
% Insert a parent entry for objects that have a sensible default parent

hP = [];
if isempty(get(h, 'Parent'))
    if isa(h, 'matlab.ui.Figure')
        hP = handle(0);
    elseif isa(h, 'matlab.ui.container.Toolbar')
        hP = gcf;
    elseif isa(h, 'ui.UIToolMixin')
        hP = gctb;
    elseif isa(h, 'matlab.ui.control.Component') ...
            || isa(h, 'matlab.graphics.mixin.UIParentable') ...
            || isa(h, 'matlab.graphics.mixin.OverlayParentable') 
        hP = gcf;
    elseif isa(h, 'matlab.graphics.mixin.AxesParentable')
        hP = gca;
    end
end
if ~isempty(hP)
    Props.Parent = hP;
    
    % Re-set parent mode after Parent so that it isn't changed from auto to
    % manual.
    Props.ParentMode = h.ParentMode;
end
end


function tb = gctb
% Find the first uitoolbar in the current figure, creating one if necessary

tb = findobj(gcf,'type','uitoolbar');
if ~isempty(tb)
    tb = tb(1);
else
    tb = uitoolbar;
end
end


function [Props, OldProps] = localCheckProperties(h, Props, OverrideProps)
% Insert override properties that are valid properties for the given
% object.
OldProps = [];
OverrideNames = fieldnames(OverrideProps);
for n = 1:length(OverrideNames)
    if isprop(h, OverrideNames{n})
        % Return the current property value if it has been altered
        if strcmp(get(h, [OverrideNames{n} 'Mode']), 'manual')
            OldProps.(OverrideNames{n}) = get(h, OverrideNames{n});
        end  
        
        Props.(OverrideNames{n}) = OverrideProps.(OverrideNames{n});
    end
end
end

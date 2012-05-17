function [pictureList, codeOutput, errorStatus] = takepicture( ...
    fileName, baseImageName, imageCount, imHeight, imWidth, method, imageType)
%TAKEPICTURE	Run file, take snapshot, save image
%   TAKEPICTURE(fileName, baseImageName, imageCount, imHeight, imWidth, method, imageType)
%
% INPUTS:
%   fileName - either a file name or a cell array of code to evaluate
%   baseImageName - the root to save all images, something like D:\Work\html\foo
%   imageCount - the number of images created so far
%     If imageCount is empty, save one image at most with the name fileName.
%   imHeight - restrict images to this height ([] means don't adjust)
%   imWidth - restrict images to this width ([] means don't adjust)
%   method - use this to capture the figures, like "print" or "getframe"
%   imageType - the image file format, like 'png'.
%
% OUTPUTS:
%   pictureList - the images this code created
%   codeOutput - the commaind line spew
%   errorStatus - did the code error?
%
%   See also PUBLISH, SNAPSHOT.

% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.1.6.14 $  $Date: 2008/03/17 22:12:50 $

% Ned Gulley, Feb 2001

% Argument parsing.
if nargin < 4
    imHeight = [];
end
if nargin < 5
    imWidth = [];
end
if nargin < 6
    method = 'print';
end
if nargin < 7
    imageType = 'png';
end

% Initialize some variables.
hasSimulink = exist('is_simulink_loaded') && is_simulink_loaded;
pictureList = {};
systemsToSnap = {};

% Capture information about current figures and systems
oldFigures = captureFigures;
if hasSimulink
    oldSystems = captureSystems;
end

% Run the code
warnState = warning('off','backtrace');
try
    if iscell(fileName)
        % This is coming from EVALMXDOM and is a chunk of code to EVAL.
        codeOutput = evalc('feature(''hotlinks'',0); evalin(''base'',[fileName{:}])');
    else
        % This is coming from SNAPSHOT and is a file to run.
        codeOutput = evalc('feature(''hotlinks'',0); evalin(''base'',fileName)');
    end
    errorStatus = false;
catch anError
    codeOutput = anError.message;
    errorStatus = true;
end
drawnow
warning(warnState);

% Apply any "backspace" characters.
while true
    codeOutputSize = numel(codeOutput);
    codeOutput = regexprep(codeOutput,('([^\b])\b'),'');
    if codeOutputSize == numel(codeOutput)
        break
    end
end

% Compare the original state to the new state to get a list of
% figures and systems that need snapping
figuresToSnap = compareFigures(oldFigures);
if hasSimulink
    systemsToSnap = compareSystems(oldSystems);
end

% If just snapshotting this file, we want exactly one image taken.
if isempty(imageCount)
    if isempty(systemsToSnap)
        if isempty(figuresToSnap)
            % Nothing to snap.
        else
            % Only figures, use the first one.
            figuresToSnap = figuresToSnap(1);
        end
    else
        % Favor models over figures.  We've got at least one Simulink model, so
        % just use the first one and ignore the figures (if any).
        systemsToSnap = systemsToSnap(1);
        figuresToSnap = [];
    end
end

if hasSimulink
    % Take a snapshot of each system.
    for systemNumber = 1:length(systemsToSnap)
        s = systemsToSnap{systemNumber};
        imgFileName = getImageName(baseImageName,pictureList,imageType,imageCount);
        snapSystem(s,imageType,imgFileName,imHeight,imWidth)
        pictureList{end+1} = imgFileName;
    end
end

% Take a snapsot of the each changed figure.
for figuresToSnapCount = 1:length(figuresToSnap)
    f = figuresToSnap(figuresToSnapCount);
    imgFileName = getImageName(baseImageName,pictureList,imageType,imageCount);
    snapFigure(f,method,imgFileName,imageType,imHeight,imWidth)
    pictureList{end+1} = imgFileName;
end

%===============================================================================
function oldOpenSystems = captureSystems

if getpref('PUBLISH','SnapChangedModels',false)
    openSystemList = findopensystems;
    oldOpenSystems = struct('name',{});
    for iOpenSystemList = 1:length(openSystemList)
        sys = openSystemList{iOpenSystemList};
        oldObjectList = find_system(sys,'SearchDepth',1);
        oldProperties = {};
        for iOldObjectList = 1:length(oldObjectList)
            oldProperties{iOldObjectList} = ...
                get_all_params(oldObjectList{iOldObjectList});
        end
        oldOpenSystems(iOpenSystemList).name = sys;
        oldOpenSystems(iOpenSystemList).objectList = oldObjectList;
        oldOpenSystems(iOpenSystemList).properties = oldProperties;
    end
else
    oldOpenSystems = findopensystems;
end

%===============================================================================
function systemsToSnap = compareSystems(oldOpenSystems)

if getpref('PUBLISH','SnapChangedModels',false)
    % Detect if there are any newly opened or modified systems to capture.
    systemsToSnap = {};
    debug = false;

    % Capture the new state
    openSystemList = findopensystems;
    for iOpenSystemList = 1:length(openSystemList)
        sys = openSystemList{iOpenSystemList};
        pos = strmatch(sys,{oldOpenSystems.name},'exact');
        if isempty(pos)
            systemsToSnap{end+1} = sys;
            if debug
                disp(['New system.  Snapping "' num2str(sys) '".'])
            end
        else
            oldObjectList = oldOpenSystems(pos).objectList;
            oldProperties = oldOpenSystems(pos).properties;
            newObjectList = find_system(sys,'SearchDepth',1);
            systemChanged = false;
            if isequal(oldObjectList,newObjectList)
                for i = 1:length(oldObjectList)
                    newProperties = get_all_params(newObjectList{i});
                    if ~isequalwithequalnans(oldProperties{i},newProperties)
                        systemChanged = true;
                        if debug
                            disp(['Property changed.  Snapping "' num2str(sys) '".'])
                            oldValues = oldProperties{i};
                            newValues = newProperties;
                            structdiff(oldValues,newValues)
                        end
                        break
                    end
                end
            else
                systemChanged = true;
                if debug
                    disp(['Object list changed.  Snapping "' num2str(sys) '".'])
                    removed = setdiff(oldObjectList,newObjectList);
                    if ~isempty(removed)
                        disp('Removed objects:')
                        disp(removed)
                    end
                    new = get(setdiff(newObjectList,oldObjectList),'type');
                    if ~isempty(new)
                        disp('New objects:')
                        disp(new)
                    end
                end
            end
            % Tally the systems that are different from the baseline
            if systemChanged
                systemsToSnap{end+1} = sys;
            end
        end
    end
else
    % Detect if there are any newly opened systems to capture.
    systemsToSnap = setdiff(findopensystems,oldOpenSystems);
end

%===============================================================================
function imgFileName = getImageName(baseImageName,pictureList,imageType,imageCount)

% Determine the image extension from the imageFormat, e.g. "jpeg" = "jpg".
[null,printTable(:,1),printTable(:,2)] = printtables;
lookup = strmatch(imageType,printTable(:,1),'exact');
if ~isempty(lookup)
    imageType = printTable{lookup,2};
end

if isempty(imageCount)
    % Coming from SNAPSHOT.
    imgFileName = sprintf('%s.%s',baseImageName,imageType);
else
    % Coming from EVALMXDOM.
    imgFileName = sprintf('%s_%02.f.%s', ...
        baseImageName,length(pictureList)+1+imageCount,imageType);
end

%===============================================================================
function snapSystem(s,imageType,imgFileName,imHeight,imWidth)

% Bring it to the front.
open_system(s)

% Look for ActiveX blocks and give them a chance to render themselves.
axblks = find_system(s,'SearchDepth',1,'MaskType','ActiveX Block','inBlock','on');
if ~isempty(axblks)
    pause(3)
end

% Print it.
simulinkSupportedBitmaps = {'bmp','tiff','jpeg','png','hdf','pcx','xwd','ras','pbm','pgm','ppm','pnm'};
switch imageType
    case [simulinkSupportedBitmaps getVectorFormats]
        % Save state.
        origDirty = get_param(bdroot(s),'Dirty');
        origLock = get_param(bdroot(s),'Lock');
        origPaperOrientation = get_param(s,'PaperOrientation');

        % Print.
        set_param(bdroot(s),'Lock','off');
        set_param(s,'PaperOrientation','portrait');
        print(['-s' s],['-d' imageType],imgFileName);

        % Restore state.
        set_param(s,'PaperOrientation',origPaperOrientation)
        set_param(bdroot(s),'Dirty',origDirty);
        set_param(bdroot(s),'Lock',origLock);

    otherwise
        error('MATLAB:takepicture:Unsupported', ...
            'The "%s" format is not supported for Simulink models.', ...
            imageType);
end
resizeIfNecessary(imgFileName,imageType,imWidth,imHeight)

%===============================================================================
function snapFigure(f,method,imgFileName,imageType,imHeight,imWidth)
switch method
    case 'getframe'
        % Bring the figure to the front.
        set(0,'ShowHiddenHandles','on');
        figure(f);
        set(0,'ShowHiddenHandles','off');
        
        % Snap the image.
        myFrame = getframe(f);
        writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);

    case 'print'
        % Reconfigure the figure for better printing.
        params = {'InvertHardcopy','PaperOrientation','Units','PaperPositionMode'};
        tempValues = {'off','portrait','pixels','auto'};
        origValues = get(f,params);
        set(f,params,tempValues);

        if strcmp(get(f,'Tag'),'SFCHART')
            % Get information about the Stateflow chart.
            sfid = get(f, 'UserData');
            sfobj = idToHandle(sfroot, sfid);
            model = sfobj.Machine.Name;

            % Capture original Stateflow settings.
            origDirty = get_param(model,'Dirty');
            sfParams = {'PaperPosition','PaperOrientation','PaperPositionMode'};
            origSfValues = get(sfobj,sfParams);

            % Set up paper properties to match the editor.
            set(sfobj,sfParams,get(f,sfParams))
            
            % Make the diagram big so we can resize it down to the size we
            % want later.
            set(sfobj,'PaperPosition',get(sfobj,'PaperPosition').*10)

            % Print the diagram.
            sfprint(sfid,imageType,imgFileName)

            % Restore original Stateflow settings.
            set(sfobj,sfParams,origSfValues)
            set_param(model,'Dirty',origDirty);

            % Setup the file to be resized to screen resolution.
            figurePosition = get(f,'Position');
            toolbarWidth = 38;
            scrollbarWidth = 18;
            chartWidth = figurePosition(3)-toolbarWidth-scrollbarWidth;
            if isempty(imWidth) || (imWidth > chartWidth)
                imWidth = chartWidth;
            end

        else
            % Print a normal figure.
            printOptions = {['-d' imageType]};
            switch imageType
                case getVectorFormats
                    % Use the default resolution.
                otherwise
                    % Print at screen resolution.
                    printOptions{end+1} = '-r0';
            end
            print(f,printOptions{:},imgFileName);

        end
        
        % Restore the figure.
        set(f,params,origValues);

        resizeIfNecessary(imgFileName,imageType,imWidth,imHeight)
        
    case 'antialiased'
        params = {'InvertHardcopy','PaperOrientation','PaperPositionMode'};
        tempValues = {'off','portrait','auto'};
        origValues = get(f,params);
        tempPng = [tempname '.png'];
        set(f,params,tempValues);
        print(f,'-dpng',tempPng);
        set(f,params,origValues);
        [myFrame.cdata,myFrame.colormap] = imread(tempPng);
        delete(tempPng);

        % We printed it large so we can resize it back down and it will be
        % anti-aliased.
        x = myFrame.cdata;
        map = myFrame.colormap;

        [height,width,unused] = size(x); %#ok<NASGU> Removing 3rd argument changes behavior of SIZE.
        if ~isempty(map)
            % Convert indexed images to RGB before resizing.
            x = ind2rgb(x,map);
            map = [];
        end
        % Compute how much we should scale it back down.
        imWidth = get(f,'position')*[0;0;1;0];
        height = height*(imWidth/width);
        if isequal(class(x),'double')
            x = uint8(floor(x*255));
        end
        x = make_thumbnail(x,floor([height imWidth]));

        myFrame.cdata = x;
        myFrame.map = map;

        writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);

    otherwise
        % We should never get here.
        error('MATLAB:takepicture:NoMethod','Unknown method "%s".',method)

end

%===============================================================================
function resizeIfNecessary(imgFileName,imageType,imWidth,imHeight)
% Resize the image.
if ~isempty(imHeight) || ~isempty(imWidth)
    switch imageType
        case getVectorFormats
            % Skip it.  PUBLISH throws a warning about this case.
        otherwise
            [myFrame.cdata,myFrame.colormap] = imread(imgFileName);
            writeImage(imgFileName,imageType,myFrame,imHeight,imWidth);
    end
end

%===============================================================================
function writeImage(imgFileName,imageType,myFrame,imHeight,imWidth)

x = myFrame.cdata;
map = myFrame.colormap;

[height,width,null] = size(x);  %#ok<NASGU> Removing 3rd argument changes behavior of SIZE.
if ~isempty(imHeight) && (height > imHeight) || ...
        ~isempty(imWidth) && (width > imWidth)
    if ~isempty(map)
        % Convert indexed images to RGB before resizing.
        x = ind2rgb(x,map);
        map = [];
    end
    if ~isempty(imHeight) && (height > imHeight)
        width = width*(imHeight/height);
        height = imHeight;
    end
    if ~isempty(imWidth) && (width > imWidth)
        height = height*(imWidth/width);
        width = imWidth;
    end
    if isequal(class(x),'double')
        x = uint8(floor(x*255));
    end
    x = make_thumbnail(x,floor([height width]));
end

if isempty(map)
    imwrite(x,imgFileName,imageType);
else
    imwrite(x,map,imgFileName,imageType);
end


%===============================================================================
function parameterList = get_all_params(sys)

parameterList = get_param(sys,'ObjectParameters');
fields = fieldnames(parameterList);
for i = 1:length(fields)
    field = fields{i};
    switch field
        case 'Jacobian'
            % This throws a warning.
            parameterList.(field) = [];
        case {'EvaledLifeSpan','CompiledSampleTime','ModifiedDate'}
            % Simply simulating sets this.
            parameterList.(field) = [];
        otherwise
            firstAttrib = parameterList.(field).Attributes{1};
            switch firstAttrib
                case 'write-only'
                    parameterList.(field) = [];
                otherwise
                    parameterList.(field) = get_param(sys,field);
            end
    end
end

%===============================================================================
function structdiff(s1,s2)
n1 = inputname(1);
n2 = inputname(2);
f1 = fieldnames(s1);
f2 = fieldnames(s2);

for i = 1:length(f1);
    if isempty(strmatch(f1{i},f2))
        disp(sprintf('Only in %s: %s',n1,f1{i}));
    end
end

for i = 1:length(f2);
    if isempty(strmatch(f2{i},f1))
        disp(sprintf('Only in %s: %s',n2,f2{i}));
    end
end

for i = 1:length(f1);
    if ~isempty(strmatch(f1{i},f2))
        v1 = s1.(f1{i});
        v2 = s2.(f1{i});
        if ~isequalwithequalnans(v1,v2)
            disp(sprintf('In %s, %s = ',n1,f1{i}));
            disp(v1);
            disp(sprintf('In %s, %s = ',n2,f1{i}));
            disp(v2);
        end
    end
end

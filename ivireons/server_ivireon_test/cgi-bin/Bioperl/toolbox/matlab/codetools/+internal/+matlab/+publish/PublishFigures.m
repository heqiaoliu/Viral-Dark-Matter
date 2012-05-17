classdef PublishFigures < internal.matlab.publish.PublishExtension
% Copyright 1984-2010 The MathWorks, Inc.

    properties
        savedState = [];
        plugins = [];
    end
    
    methods
        
        function obj = PublishFigures(options)
            obj = obj@internal.matlab.publish.PublishExtension(options);

            obj.plugins(1).check = @(f)strcmp(get(f,'Tag'),'SFCHART');
            obj.plugins(1).classname = 'internal.matlab.publish.PublishStateflowCharts';
            obj.plugins(1).instance = [];
            
            obj.plugins(2).check = @(f)( ...
                ~isempty(license('inuse','virtual_reality_toolbox')) && ...
                ~isempty(which('vr.figure')) && ...
                ~isempty(vr.figure.fromHGFigure(f)));
            obj.plugins(2).classname = 'internal.matlab.publish.PublishSimulink3DAnimationViewers';
            obj.plugins(2).instance = [];

            obj.plugins(3).check = @(f)(isfield(get(f,'UserData'),'PM_VIS_FigVisObj'));
            obj.plugins(3).classname = 'internal.simmechanics.publish.PublishSimMechanicsVisualizations';
            obj.plugins(3).instance = [];
            
            obj.plugins(4).check = @(f)isa(get(f,'UserData'),'Aero.Animation');
            obj.plugins(4).classname = 'internal.aero.publish.PublishAeroAnimationFigures';
            obj.plugins(4).instance = [];

            obj.plugins(5).check = @(f)strcmp(get(f,'Tag'),'spcui_scope_framework');
            obj.plugins(5).classname = 'internal.mwtools.publish.PublishSpcuiScopes';
            obj.plugins(5).instance = [];

            obj.savedState = internal.matlab.publish.captureFigures;
        end
        
        function enteringCell(obj,~)
            obj.savedState = internal.matlab.publish.captureFigures;
        end
        
        function newFiles = leavingCell(obj,~)
            % Determine which figures need a snapshot.
            newFigures = internal.matlab.publish.captureFigures;
            figuresToSnap = internal.matlab.publish.compareFigures(obj.savedState, newFigures);

            % Take a snapshot of the each figure that needs it.
            newFiles = cell(size(figuresToSnap));
            for figuresToSnapCount = 1:numel(figuresToSnap)
                f = figuresToSnap(figuresToSnapCount);

                % Check to see if this is a special type of figure.
                for i = 1:numel(obj.plugins)
                    handled = false;
                    if obj.plugins(i).check(f) && ...
                            exist(obj.plugins(i).classname,'class') == 8                            
                        if isempty(obj.plugins(i).instance)
                            obj.plugins(i).instance = feval(obj.plugins(i).classname,obj.options);
                        end
                        imgFilename = obj.plugins(i).instance.snapFigure(f,obj.options.filenameGenerator(),obj.options);
                        handled = true;
                        break
                    end
                end
                
                % Handle regular figures.
                if ~handled
                    imgFilename = obj.snapFigure(f,obj.options.filenameGenerator(),obj.options);
                end
                
                % Add to list of figures.
                newFiles{figuresToSnapCount} = imgFilename;

            end
            
            % Update SNAPNOW's view of the current state of figures.
            % Since the process of printing can change certain properties,
            % capture the just-printed figures to prevent extra snaps.
            newFiguresRecaptured = internal.matlab.publish.captureFigures(figuresToSnap);
            [~,index] = ismember(figuresToSnap, newFigures.id);
            newFigures.data(index) = newFiguresRecaptured.data;
            obj.savedState = newFigures;

        end
        
    end
    
    methods(Static)

        function imgFilename = snapFigure(f,imgNoExt,opts)
            % Nail down the figure snap method.
            method = opts.figureSnapMethod;
            if strcmp(method,'entireGUIWindow')
                % If we only want to capture the whole window for GUIs, use
                % HandleVisibility to determine what is a GUI and what isn't.
                if strcmp(get(f,'HandleVisibility'),'on')
                    method = 'print';
                else
                    method = 'entireFigureWindow';
                end
            end
            
            % Nail down the image format.
            if isempty(opts.imageFormat)
                imageFormat = internal.matlab.publish.getDefaultImageFormat(opts.format,method);
            else
                imageFormat = opts.imageFormat;
            end
            
            % Nail down the image filename.
            imgFilename = internal.matlab.publish.getPrintOutputFilename(imgNoExt,imageFormat);
            
            % Dispatch.
            switch method
                case {'print','getframe','entireFigureWindow','antialiased'}
                    feval([method 'Snap'],f,imgFilename,imageFormat,opts);
                otherwise
                    % We should never get here.
                    error('MATLAB:takepicture:NoMethod','Unknown method "%s".',method)
            end
        end

    end
    
end

%===============================================================================
function entireFigureWindowSnap(f,imgFilename,imageFormat,opts) %#ok<DEFNU> Dynamically dispatched from snapFigure.

if (exist('addWindowDecorations','file') == 2)
    % Go through the MathWorks-internal screen-insensitve code path.

    % Capture figure contents.
    tempPng = [tempname '.png'];
    printSnap(f,tempPng,'png',struct('maxWidth',[],'maxHeight',[]),'off');
    inside = imread(tempPng);
    delete(tempPng)

    % Add decorations.
    myFrame = addWindowDecorations(f,inside,0);

else
    % Force figure to update in order to get proper OuterPosition.
    drawnow
    % Calculate capture coordinates relative to lower-left of client area.
    oldUnits = get(f,'Units');
    set(f,'Units','pixels');
    outerPosition = get(f,'OuterPosition');
    innerPosition = get(f,'Position');
    offset = [innerPosition(1:2) outerPosition(1:2)-innerPosition(1:2)];
    % There are some problems in getframe and the definition
    % of inner/outer positions, hence the fudge factor.  The
    % proper fudge factor is platform and window manager dependent.
    fudge = [1 1 -4 -4];
    getframeArgs = {outerPosition - offset + fudge};
    set(f,'Units',oldUnits);
    % Just grab the whole window from the screen.
    myFrame = snapIt(f,getframeArgs);
end

% Finally, write out the image file.
internal.matlab.publish.writeImage(imgFilename,imageFormat,myFrame,opts.maxHeight,opts.maxWidth);

end

%===============================================================================
function getframeSnap(f,imgFilename,imageFormat,opts) %#ok<DEFNU> Dynamically dispatched from snapFigure.

myFrame = snapIt(f,{});

% Finally, write out the image file.
internal.matlab.publish.writeImage(imgFilename,imageFormat,myFrame,opts.maxHeight,opts.maxWidth);

end

%===============================================================================
function myFrame = snapIt(f,getframeArgs)
% Bring the figure to the front and snap it.
set(0,'ShowHiddenHandles','on');
figure(f);
drawnow
set(0,'ShowHiddenHandles','off');
drawnow
try
    myFrame = getframe(f,getframeArgs{:});
catch e
    % GETFRAME can error if the figure is off the screen.
    warning(e.identifier,e.message)
    myFrame.cdata = 255*ones(10,10,3,'uint8');
    myFrame.colormap = [];
end
end

%===============================================================================
function printSnap(f,imgFilename,imageFormat,opts,invertHardcopy) % Dynamically dispatched from snapFigure.
if nargin < 5
    invertHardcopy = get(f,'InvertHardcopy');
end

% Reconfigure the figure for better printing.
params = {'PaperOrientation','Units','PaperPositionMode','InvertHardcopy'};
tempValues = {'portrait','pixels','auto',invertHardcopy};
origValues = get(f,params);
set(f,params,tempValues);

imWidth = opts.maxWidth;
imHeight = opts.maxHeight;

% Print a normal figure.
printOptions = {['-d' imageFormat]};
switch imageFormat
    case internal.matlab.publish.getVectorFormats()
        % Use the default resolution.
    otherwise
        % Print at screen resolution.
        printOptions{end+1} = '-r0';
end
print(f,printOptions{:},imgFilename);


% Restore the figure.
set(f,params,origValues);

internal.matlab.publish.resizeIfNecessary(imgFilename,imageFormat,imWidth,imHeight)
end

%===============================================================================
function antialiasedSnap(f,imgFilename,imageFormat,opts) %#ok<DEFNU> Dynamically dispatched from snapFigure.
imHeight = opts.maxHeight;

params = {'PaperOrientation','PaperPositionMode'};
tempValues = {'portrait','auto'};
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

[height,width,~] = size(x); % Removing 3rd argument changes behavior of SIZE.
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
x = internal.matlab.publish.make_thumbnail(x,floor([height imWidth]));

myFrame.cdata = x;
myFrame.map = map;

internal.matlab.publish.writeImage(imgFilename,imageFormat,myFrame,imHeight,imWidth);
end
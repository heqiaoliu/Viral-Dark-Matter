classdef PublishSimulinkSystems < internal.matlab.publish.PublishExtension
% Copyright 1984-2009 The MathWorks, Inc.

    properties
        savedState = [];
    end
    
    methods
        
        function obj = PublishSimulinkSystems(options)
            obj = obj@internal.matlab.publish.PublishExtension(options);
            % Sometimes leavingCell will be called before enteringCell is
            % ever called, like when a cell loads Simulink for the first
            % time in a MATLAB session.
            obj.savedState.id = {};
            obj.savedState.data = [];
        end
       
        function enteringCell(obj,~)
            obj.savedState = captureSystems;
        end
        
        function newFiles = leavingCell(obj,~)   
            % Determine which systems need a snapshot.
            newSystems = captureSystems;
            systemsToSnap = internal.matlab.publish.compareFigures(obj.savedState, newSystems);
            
            % Take a snapshot of each system that needs it.
            newFiles = cell(size(systemsToSnap));
            for systemNumber = 1:length(systemsToSnap)
                s = systemsToSnap{systemNumber};
                imgFilename = snapSystem(s,obj.options.filenameGenerator(),obj.options);
                newFiles{systemNumber} = imgFilename;
            end
            
            % Update SNAPNOW's view of the current state of systems.
            obj.savedState = newSystems;
        end
        
    end
end    

%===============================================================================
function oldOpenSystems = captureSystems
openSystemList = findopensystems;
oldOpenSystems.id = openSystemList(:)';
oldOpenSystems.data = zeros(size(oldOpenSystems.id));
end

%===============================================================================
function sys = findopensystems
%FINDOPENSYSTEMS - Returns the names of open Simulink systems
%
% sys = findopensystems
%
% sys is a cell array of strings giving the full paths of any
% open (i.e. visible) Simulink systems.

% We need to look for block diagrams and subsystems separately.
bd = find_system('SearchDepth',0,'Open','on');
% Specify the block type so that we don't accidentally pick up
% Scope blocks, or any other type of block which as an "Open" parameter.
ss = find_system('LookUnderMasks','on','BlockType','SubSystem','Open','on');
sys = [ bd(:) ; ss(:) ];
end

%===============================================================================
function imgFilename = snapSystem(s,imgNoExt,opts)

% Nail down the image format.
if isempty(opts.imageFormat)
    imageFormat = internal.matlab.publish.getDefaultImageFormat(opts.format,'print');
else
    imageFormat = opts.imageFormat;
end

% Nail down the image filename.
imgFilename = internal.matlab.publish.getPrintOutputFilename(imgNoExt,imageFormat);

% Bring it to the front.
open_system(s)

% Look for ActiveX blocks and give them a chance to render themselves.
axblks = find_system(s,'SearchDepth',1,'MaskType','ActiveX Block','inBlock','on');
if ~isempty(axblks)
    pause(3)
end

% Print it.
simulinkSupportedBitmaps = {'bmp','tiff','jpeg','png','hdf','pcx','xwd','ras','pbm','pgm','ppm','pnm'};
switch imageFormat
    case [simulinkSupportedBitmaps internal.matlab.publish.getVectorFormats()]
        % Save state.
        origDirty = get_param(bdroot(s),'Dirty');
        origLock = get_param(bdroot(s),'Lock');
        origPaperOrientation = get_param(s,'PaperOrientation');
        origPaperPositionMode = get_param(s,'PaperPositionMode');
        
        % Print.
        set_param(bdroot(s),'Lock','off');
        set_param(s,'PaperOrientation','portrait');
        set_param(s,'PaperPositionMode','auto');
        print(['-s' s],['-d' imageFormat],imgFilename);
        
        % Restore state.
        set_param(s,'PaperOrientation',origPaperOrientation)
        set_param(s,'PaperPositionMode',origPaperPositionMode)
        set_param(bdroot(s),'Dirty',origDirty);
        set_param(bdroot(s),'Lock',origLock);
        
    otherwise
        error('MATLAB:takepicture:Unsupported', ...
            'The "%s" format is not supported for Simulink models.', ...
            imageFormat);
end
internal.matlab.publish.resizeIfNecessary(imgFilename,imageFormat,opts.maxWidth,opts.maxHeight)
end


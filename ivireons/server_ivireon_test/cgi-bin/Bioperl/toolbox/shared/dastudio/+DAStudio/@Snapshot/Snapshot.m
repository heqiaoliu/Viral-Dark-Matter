classdef Snapshot < handle
    
    % Copyright 2010 The Mathworks, Inc
    
    properties
        Source          = [];
        Format          = 'png';
        FileName        = 'untitled.png';
        Orientation     = 'portrait';

        SizeMode        = 'scaled';
        Zoom            = 100;
        Units           = 'inches';
        MaxSize         = [10 10];
        FixedSize       = [10 10];
        IsTight         = true;  % applies only when SizeMode is fixed
        IsExpandToFit   = true;  % applies when IsTight is false
        
        ViewMode         = 'full';
        % Note: SF positions are [x1 y1 w h]!!  SL positions are [x1 y1 x2 y2] 
        ViewExtents      = []; %[x1 y1 w h].  
                
        FrameFile        = 'sldefaultframe.fig';
        AddFrame         = false;

        AddCallouts = false;
        CalloutList = '%<auto>';
        
        WhiteSpace   = [1/4 1/4 1/4 1/4];
        CalloutSpace = 1/2;
        
    end
    
    properties (SetAccess = 'private')
        Portal = [];
        
        RuntimeViewExtents = [];
        RuntimeSize = [];
        RuntimeMargins = [];
        RuntimeOrientation = '';
        RuntimeAddCallouts = [];
        RuntimeCalloutList = [];
        RuntimeCalloutPointers = [];

        RuntimeScale = [];
        RuntimeOffset = [];
        RuntimeRotation = 0;
    end

    properties (GetAccess = 'private', SetAccess = 'private')
        IsDeletePortal = false;
    end
    
    methods
        function this = Snapshot(varargin)
            for i = 1:2:nargin
                this.(varargin{i}) = varargin{i+1};
            end
        end

        function delete(this)
            if (this.IsDeletePortal && isa(this.Portal,'Portal.Portal'))
                delete(this.Portal);
            end
        end
        
        function set.Source(this, newObject)
            obj = this.resolveObject(newObject); %#ok<MCSUP>
            if (isa(obj, 'Simulink.SubSystem') ...
                && strcmpi(obj.MaskType, 'Stateflow'))
                obj = obj.find(...
                    '-isa', 'Stateflow.Chart', ...
                    '-or', ...
                    '-isa', 'Stateflow.LinkChart', ...
                    '-and', ...
                    'Path', obj.getFullName());
                this.Source = this.resolveObject(obj); %#ok<MCSUP>
            else
                this.Source = obj;
            end
            this.Portal.targetObject = obj; %#ok<MCSUP>
        end

        function set.Format(this, newFormat)
            
            switch newFormat
                case 'bmp16m'
                    % use 'native' bitmap drawing
                    newFormat = 'bmp';
                case 'png16m'
                    % use 'native' png drawing
                    newFormat = 'png';
                otherwise
                    %noop
            end
            
            this.Format = newFormat;
            
            fileExt = regexp(this.FileName, '\.([^\.]+$)', 'tokens', 'once'); %#ok<MCSUP>
            if (~isempty(fileExt) && ~strcmpi(fileExt, newFormat))
                this.FileName = regexprep(this.FileName, '([^\.]*$)', newFormat, 'once'); %#ok<MCSUP>
            end
        end

        function set.Orientation(this, newOrientation)
            newOrientation = lower(newOrientation);
            switch newOrientation
                case {'portrait', 'landscape', 'rotated', 'inherit', 'auto'}
                    this.Orientation = newOrientation;
                otherwise
                    error('DAStudio:Snapshot:UnexpectedOrientation', ...
                        'Unexpected orientation: %s [%s]', ...
                        newOrientation, ...
                        '{''portrait'', ''landscape'', ''rotated'', ''inherit'', ''auto''}');
            end
        end

        function set.SizeMode(this, newMode)
            newMode = lower(newMode);
            switch newMode
                case {'scaled', 'fixed', 'auto'}
                    this.SizeMode = newMode;
                otherwise
                    error('DAStudio:Snapshot:UnexpectedSizeMode', ...
                        'Unexpected mode: %s [%s]', ...
                        newMode, ...
                        '{''scaled'', ''fixed'', ''auto''}');
            end
        end

        function set.Units(this, newUnits)
            newUnits = lower(newUnits);
            switch newUnits
                case {'inches', 'centimeters', 'pixels', 'points'}
                    this.Units = newUnits;
                otherwise
                    error('DAStudio:Snapshot:UnexpectedUnits', ...
                        'Unexpected units: %s [%s]', ...
                        newUnits, ...
                        '{''inches'', ''centimeters'', ''pixels'', ''points''}');
            end
        end

        function set.Zoom(this, newZoom)
            if isnumeric(newZoom)
                if (newZoom > 0)
                    this.Zoom = newZoom;
                else
                    error('DAStudio:Snapshot:ZeroNegativeZoom', ...
                        'Zoom must be position and non-zero!');
                end
            else
                error('DAStudio:Snapshot:UnexpectedDatatype', ...
                    'Unexpected datatype %s.  Expected a numeric type', ...
                    class(newZoom));
            end
        end

        function set.MaxSize(this, newMaxSize)
            if (isnumeric(newMaxSize) ...
                && (length(newMaxSize) == 2) ...
                && (sum(newMaxSize > 0) == 2))
                this.MaxSize = newMaxSize;
            else
                error('DAStudio:Snapshot:InvalidMaxSize', 'Invalid max size');
            end
        end

        function set.FixedSize(this, newFixedSize)
            if (isnumeric(newFixedSize) ...
                && (length(newFixedSize) == 2) ...
                && (sum(newFixedSize > 0) == 2))
                this.FixedSize = newFixedSize;
            else
                error('DAStudio:Snapshot:InvalidFixedSize', 'Invalid fixed size');
            end
        end

        function set.FileName(this, newFileName)
            this.FileName = newFileName;
        end

        function set.ViewMode(this, newViewMode)
            newViewMode = lower(newViewMode);
            switch newViewMode
                case {'full', 'current', 'custom'}
                    this.ViewMode = newViewMode;
                otherwise
                    error('DAStudio:Snapshot:UnexpectedViewMode', ...
                        'Unexpected view mode: %s [%s]', ...
                        newMode, ...
                        '{''scaled'', ''fixed'', ''auto''}');
            end
        end

        function set.WhiteSpace(this, newWhiteSpace)
            wslen = length(newWhiteSpace);
            if (wslen == 4)
                this.WhiteSpace = newWhiteSpace;
            elseif (wslen == 1)
                this.WhiteSpace = repmat(newWhiteSpace, [1 4]);
            else
                error('DAStudio:Snapshot:InvalidWhiteSpace', ...
                    'Invalid white space!  Expecting an array of [top left bottom right].');
            end
        end
        
        function set.Portal(this, newPortal)
            if isa(newPortal, 'Portal.Portal')
                this.Portal = newPortal;
            else
                error('DAStudio:Snapshot:InvalidPortal', ...
                    'Invalid portal.  Unexpected object: [%s]', class(newPortal));
            end
        end
        
        function portal = get.Portal(this)
            if ~isa(this.Portal, 'Portal.Portal')
                this.Portal = Portal.Portal; %#ok
                this.Portal.units = 'pixels';
                this.Portal.minimumMargins.setToUniformValue(0);
                
                if (~isempty(this.Source) && ~isa(this.Source,'handle.handle'))
                    portal = this.Portal;
                    portal.targetObject = this.Source;
                end
                
                this.IsDeletePortal = true;
            end
            portal = this.Portal;
        end
        
        function portal = preview(this)
            this.renderToPortal();
            this.Portal.visibility = true;
            portal = this.Portal;
        end

        function execute(this)
            this.renderToPortal();
            portal = this.Portal;
            canvas = portal.getCanvas();

            if any(strcmpi(this.Format,{'ps','psc','ps2','eps','epsc',...
                    'eps2','epsc2','meta',}))
                % When we go through HG print pipeline, pixels are treated 
                % as points.  Adjust portal size so pixels are now points.
                scale = 72/get(0, 'ScreenPixelsPerInch');
            
                % Resize source layer
                pSize = copy(portal.Size);
                portal.Size = Portal.Point(pSize.x * scale, pSize.y * scale); %#ok
                margins = this.RuntimeMargins;
                newMargins.top = margins.top * scale;
                newMargins.left = margins.left * scale;
                newMargins.bottom = margins.bottom * scale;
                newMargins.right = margins.right * scale;
                portal.minimumMargins.clear;
                portal.minimumMargins.top    = newMargins.top;
                portal.minimumMargins.left   = newMargins.left;
                portal.minimumMargins.bottom = newMargins.bottom;
                portal.minimumMargins.right  = newMargins.right;

                % Resize frame layer
                layers = canvas.getLayers();
                glmodel = layers(2).getModel();
                scaleNode = glmodel.createScaleNode(scale,scale);
                glmodel.addNodeAtIndex(scaleNode,0);
                
                % PRINT!!!
                this.canvasPrint(canvas);
                
                % Recover
                portal.Size = pSize;
                portal.minimumMargins.clear;
                portal.minimumMargins.top    = margins.top;
                portal.minimumMargins.left   = margins.left;
                portal.minimumMargins.bottom = margins.bottom;
                portal.minimumMargins.right  = margins.right;
                glmodel.removeNodeAtIndex(0);
                
            else
                this.canvasPrint(canvas);
            end
        end

        disp(this)

        runtimeViewExtents = getRuntimeViewExtents(this) %#ok
        
        [runtimeSize, margins] = getRuntimeSize(this) %#ok
       
        runtimeOrientation = getRuntimeOrientation(this) %#ok
        
        runtimeCalloutList = getRuntimeCalloutList(this) %#ok
        
        function out = resolveObject(this, in)
            if iscell(in)
                in = in{1};
            end
            
            if isempty(in)
                out = [];
                
            elseif isa(in, 'Stateflow.LinkChart')
                % return reference chart 
                referenceBlock = get_param(in.Path, 'referenceblock');
                out = slroot.find('-isa','Stateflow.Chart', 'Path', referenceBlock);

            elseif (isa(in, 'Simulink.Object') || isa(in, 'Stateflow.Object'))
                out = in;
            
            elseif isnumeric(in) && ~ishandle(in)
                out = idToHandle(slroot, in);
            
            else
                try
                    out = get_param(in, 'Object');
                catch ME
                    if isa(this.Source, 'Simulink.BlockDiagram')
                        out = get_param([this.Source.Name '/' in], 'Object');

                    elseif isa(this.Source, 'Simulink.SubSystem')
                        out = get_param([this.Source.Path '/' in], 'Object');
                    
                    else
                        rethrow(ME);
                    end
                end
            end
        end

        function tf = isObjectVisible(this, obj)
            
            vE = this.RuntimeViewExtents;
            if isempty(vE)
                vE = this.getRuntimeViewExtents();
            end
            
            viewBox = vE.viewBox;
            objBox = this.getObjectPosition(obj);

            tf = (objBox(1) > viewBox(1)) && (objBox(2) > viewBox(2)) ...
                && ((objBox(1) + objBox(3)) < (viewBox(1) + viewBox(3))) ...
                && ((objBox(2) + objBox(4)) < (viewBox(2) + viewBox(4)));
        end

        function position = getObjectPosition(this, obj)
            obj = this.resolveObject(obj);
            if isa(obj, 'Stateflow.Object')
                if isa(obj, 'Stateflow.Transition')
                    objPos = obj.MidPoint;
                    position = [objPos(1)-1 objPos(2)-1 objPos(1)+1 objPos(2)+1];
                else
                    % Stateflow position [topLeft.x topLeft.y width height]
                    position = obj.Position;
                end
            elseif isa(obj, 'Simulink.Line')
                srcPort = obj.getSourcePort();
                if isempty(srcPort)
                    warning('DAStudio:Snapshot:getObjectPosition:LineNoSourcePort',...
                        'Can not determine position of a Simulink.Line when there is no source port.');
                    position = [];
                else
                    position = this.getLinePoints(srcPort.Line, {});
                end
            elseif isa(obj, 'Simulink.Segment')
                position = obj.Points;
                
            else
                % Simulink position [topLeft.x topLeft.y bottomRight.x bottomRight.y]
                pos = obj.Position;
                position = [pos(1:2) pos(3:4)-pos(1:2)];
            end
        end

        function portalPosition = getObjectPortalPosition(this, obj)
            obj = this.resolveObject(obj);
            pos = this.getObjectPosition(obj);
            portalPosition = this.convertToPortalPosition(pos);
        end

        function portalPosition = getObjectCalloutPortalPosition(this, obj)
            obj = this.resolveObject(obj);
            i = 0;
            portalPosition = [];
            nPointer = length(this.RuntimeCalloutPointers);
            while ((i < nPointer) && isempty(portalPosition))
                i = i + 1;
                if isequal(obj, this.RuntimeCalloutPointers{1, i})
                    portalPosition = this.RuntimeCalloutPointers{2, i};
                end
            end
        end
        
        function portalPosition = convertToPortalPosition(this, pos)
            
            % Get scale, offset and angle;
            offset   = this.RuntimeOffset;
            scale    = this.RuntimeScale;
            rotation = this.RuntimeRotation;
            imgSize  = this.RuntimeSize;
            
            % Check if we are rendered
            portalSize = [this.Portal.size.x this.Portal.size.y];
            if ~isequal(portalSize, this.RuntimeSize)
                error('DAStudio:Snapshot:NeedToBeRendered', ...
                    'Need to preview or execute before executing this method!');
            end

            if ~iscell(pos)
                portalPosition = this.translatePosition(pos, scale, offset, rotation, imgSize);
            else
                portalPosition = cell(size(pos));
                for i = 1:length(pos)
                    portalPosition{i} = this.translatePosition(pos{i}, scale, offset, rotation, imgSize);
                end
                
            end
        end
  
        function initRuntimeVariables(this)
            this.RuntimeCalloutPointers = []; %needs to be rendered
            this.RuntimeScale = [];
            this.RuntimeOffset = [];
            this.RuntimeRotation = 0;
            this.RuntimeOrientation = this.getRuntimeOrientation();
            this.RuntimeViewExtents = this.getRuntimeViewExtents();
            this.RuntimeCalloutList = this.getRuntimeCalloutList();
            this.RuntimeAddCallouts = ~isempty(this.RuntimeCalloutList);
            [this.RuntimeSize this.RuntimeMargins] = this.getRuntimeSize(); % uses all runtime variables
        end

        function clearRuntimeVariables(this)
            this.RuntimeCalloutPointers = [];
            this.RuntimeScale = [];
            this.RuntimeOffset = [];
            this.RuntimeRotation = 0;
            this.RuntimeOrientation = [];
            this.RuntimeViewExtents = [];
            this.RuntimeCalloutList = [];
            this.RuntimeAddCallouts = [];
            this.RuntimeMargins = [];
            this.RuntimeSize = [];
        end

    end
    
    methods (Static)
        
        function out = convertToPixels(in, units)
            switch units
                case 'points'
                    out = in .* get(0, 'ScreenPixelsPerInch')/72;
                case 'inches'
                    out = in .* get(0, 'ScreenPixelsPerInch');
                case 'centimeters'
                    out = in .* get(0, 'ScreenPixelsPerInch')/2.54;
                case 'pixels'
                    out = in;
                case 'mm'
                    out = in .* get(0, 'ScreenPixelsPerInch')/25.4;
                otherwise
                    error('DAStudio:Snapshot:UnexpectedUnits', ...
                        'Unexpected units %s!', units);
            end
        end
        
    end
    
    methods (Access = 'private')
        renderToPortal(this);
        
        function canvasPrint(this,canvas)
            canvas.print(...
                '', ...              % printer name
                this.Format, ...     % output format
                this.FileName, ...   % filename
                'usletter', ...      % paper type
                'portrait', ...      % paperOrientation, TODO, must be honored for non-QT
                0, ...               % dpi
                0, ...               % tight
                0, ...               % PostScriptAppend
                0, ...               % tiff preview
                0, ...               % PostScriptCMYK
                0 );                 % PostScriptLatin1
        end
        
        function points = getLinePoints(this, lineSeg, points)
            lineSeg = this.resolveObject(lineSeg);
            points{end+1} = lineSeg.Points;
            for lineChild = lineSeg.LineChildren(:)'
                points = this.getLinePoints(lineChild, points);
            end
        end
    end
    
    methods(Access = 'private', Static)
        
        function out = translatePosition(in, scale, offset, rotation, imgSize)
            n = size(in, 1);
            out = zeros(size(in));
            for i = 1:n
                out(i, 1) = scale*(in(i, 1)) + offset(1);
                out(i, 2) = scale*(in(i, 2)) + offset(2);
                
                if (length(in(i,:)) == 4)
                    out(i,3:4) = scale*in(3:4);
                end
                
                if (rotation ~= 0)
                    x = out(i,1);
                    y = out(i,2);
                    w = 0;
                    h = 0;

                    if (length(in(i,:)) == 4)
                        % flip w h
                        out(i,3:4) = fliplr(out(i,3:4));
                        w = out(i,3);
                        h = out(i,4);
                    end

                    if (rotation == pi/2)
                        out(i,1) = y; 
                        out(i,2) = imgSize(2) - x - h;

                    else % (rotation == 3/2 * pi);
                        out(i,1) = imgSize(1) - y - w;
                        out(i,2) = x;
                    end
                end
                
            end
        end
    end
end
 



function pj = render( pj, h )
%RENDER Method to draw a model or Figure on current page of a print job.
%   Figure or model is drawn in the output format specified by the device
%   option to PRINT. The Figure or model may be modified as required for
%   printing.
%
%   Ex:
%      pj = RENDER( pj, h ); %draw Figure/model h on output of PrintJob pj
%
%   See also PRINT, PREPARE.

%   Copyright 1984-2010 The MathWorks, Inc.

error( nargchk(2,2,nargin) )

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

% Verify h is not empty
if isempty(h)
    error( 'MATLAB:render:emptyHandle','Empty handle, Need a handle to a Figure or model.' )
end

% h could be a vector when printing with frames on old pipeline i.e. two
% handles, 1 for the object and 1 for the frame
for k = 1:length(h)
   if(~ishandle(h(k)))
       error( 'MATLAB:render:invalidHandle','Invalid handle, Need a valid handle to a Figure or model.');
   end
end

if ~pj.Active
    error('MATLAB:render:inactivePrintJob','PrintJob is not active')
end

pj.Error = 0;  %So caller knows there was an error
pj.Exception = [];

%Call different function if using the new pipeline
[IsSLorSF, obj] = LocalGetSLSFObject(h, pj);

% Significance of the "pj.Verbose" flag (as explained by Dennis Wilkinson):
% pj.Verbose: That's the magic "display the Windows print dialog" switch
% on print (i.e. print -v), and, IIRC, is only an issue if we're
% invoked from a command line. We end up coming through here twice:
% first with pj.Verbose=1, where we go down the old path, display the
% dialog, then call back in with pj.Verbose=0 and go down the new path.
if ( IsSLorSF && ~logical(pj.Verbose))

    %if (logical(pj.TiledPrint) || strcmp(LocalSLSFGet(obj,'PaperPositionMode'),'tiled')))

        if strcmp(LocalSLSFGet(obj,'PaperOrientation'),'rotated') && ...
                (logical(pj.TiledPrint) || strcmp(LocalSLSFGet(obj,'PaperPositionMode'),'tiled'))
            warning('slprint:TiledRotatedPrint','Ignoring rotation in tiled mode, using landscape instead');
            LocalSLSFSet(obj,'PaperOrientation','landscape');
            rotatePaperOrientation = true;
        else
            rotatePaperOrientation = false;
        end

        pj = LocalRender(pj, obj);

        if rotatePaperOrientation
            LocalSLSFSet(obj,'PaperOrientation','rotated');
        end

        return;
    %end

end % if (IsSLorSF)

%Call the output driver and render Figure/model to device, file, or
%clipboard. We report error in PrintJob flag, caller will error out (allows
%it to recover gracefully).
try

        %If writing out to PS for later conversion via GS to an image format,
        %true for either Simulink TIFF previews or for saving in pgm type formats,
        %must move the objects to the lower-left of the page so we can crop the image.
        if pj.GhostImage
            %Save all the current values of the 'paper' properties
            %Then move each object(s) PaperPosition to lower left
            %using points; saved a translation for every object on
            %the current page earlier.
            pp = cell(size(h));
            for i = 1:length(h)
                pp{i} = getpp(h(i));
                setset( h(i), 'paperunits', 'points' )
                if ~strcmp(pj.GhostDriver, 'pdfwrite')
                    % Change the paperposition if the output format is not
                    % PDF, since PDF is a format that supports margins
                    setset( h(i), 'paperposition', getget(h(i), ...
                        'paperposition')-[pj.GhostTranslation 0 0] )

                end

            end
        end

        %Create TIFF preview file
        tiffName = '';
        if pj.PostScriptPreview == pj.TiffPreview
            %Write out TIFF temp file for concatenating with EPS file later.
            eventualName = pj.FileName;
            pj.FileName = [tempname '.eps'];

            try
                tiffName = LocalWriteTiff( pj, h );
                wasErr = 0;
            catch ex
                wasErr = 1;
            end

            %Restore paper properties if using GS to create TIFF
            if pj.GhostImage
                for i = 1:length(h)
                    setpp( h(i), pp{i} )
                end
            end

            if wasErr
                rethrow(ex); %#ok
            end

            %Using GS only to create TIFF for SL, don't want to call it again later.
            pj.GhostDriver = '';
        end

        %Make argument cell array for calling HARDCOPY
        inputargs = LocalPrintJob2Arguments( pj, h );

        if pj.DebugMode
            fprintf('Printing handle: %d\n', inputargs{1})
            fprintf('Passing input args to hardcopy: ')
            fprintf('''%s'' ', inputargs{2:end})
            fprintf('\n')
        end

        %Create the output file
        try
            pj.Return = hardcopy( inputargs{:} );
            wasErr = 0;
        catch ex
            wasErr = 1;
        end

        %Restore paper properties now if using GS to create image output.
        if logical(pj.GhostImage) && (pj.PostScriptPreview ~= pj.TiffPreview)
            for i = 1:length(h)
                setpp( h(i), pp{i} )
            end
        end

        %If we had a problem with creating the EPS file, clean up
        %before erroring out.
        if wasErr
            if ~pj.DebugMode
                if exist(pj.FileName,'file'), delete(pj.FileName); end
                if exist(pj.GhostName,'file'), delete(pj.GhostName); end
                if exist(tiffName,'file'), delete(tiffName); end
            end
            rethrow(ex) %#ok
        end

        if (pj.PostScriptPreview == pj.TiffPreview) && ~isempty( tiffName )
            catpreview( pj, pj.FileName, tiffName, eventualName );
            pj.FileName = eventualName; %just in case
        end

    %Some output formats are generated by first creating ZBuffer via hardcopy
    %then using IMWRITE to output the image. The default extension of the specified
    %format is passed to IMWRITE in case user gave FileName a different ext.
    if strcmp( pj.DriverClass, 'IM')
        dims = size(pj.Return);
        if length(dims) ~=3 || dims(3) ~= 3
            error('MATLAB:render:badData','Bad data returned by HARDCOPY. Not calling IMWRITE.')
        else
            imwriteArgs = LocalCreateImwriteArgs( pj );

            if pj.DebugMode
                fprintf('Passing input args to IMWRITE: ')
                sArgs = cell2struct({imwriteArgs{2:2:end}}, {imwriteArgs{1:2:end}}, 2);
                disp(sArgs);
                fprintf('\n')
            end

            if strcmp('landscape', getget(h,'paperorientation') )
                pj.Return = cat( 3, rot90(pj.Return(:,:,1),1), rot90(pj.Return(:,:,2),1), rot90(pj.Return(:,:,3),1) );
            elseif strcmp('rotated', getget(h,'paperorientation') )
                pj.Return = cat( 3, rot90(pj.Return(:,:,1),-1), rot90(pj.Return(:,:,2),-1), rot90(pj.Return(:,:,3),-1) );
            end
            imwrite( pj.Return, pj.FileName, pj.DriverExt, imwriteArgs{:} );
            pj.Return = 0;
        end

    end

catch ex
    pj.Error = 1;
    pj.Exception = ex;
end
%--------------------------------------------------------------------------
function tiffName = LocalWriteTiff( pj, h )
% Creates a TIFF file for output object h
% For Figure use IMWRITE to create TIFF from zbuffer For Simulink models
% and for multiple objects create a PS file and uses GhostScript to create
% a TIFF file.

tiffName = [ tempname '.tif' ];
try
    if isfigure(h)
        imageDriver = LocalGetImageDriver(h, pj.Renderer);
        z = hardcopy( h, imageDriver, '-r150' );
        dims = size( z );
        if length(dims) ~=3 || dims(3) ~= 3
            error('MATLAB:render:badData','Bad data returned by HARDCOPY. Not calling IMWRITE.')
        end
        if strcmp('landscape', get(h,'paperorientation') )
            z = cat( 3, rot90(z(:,:,1),1), rot90(z(:,:,2),1), rot90(z(:,:,3),1) );
        elseif strcmp('rotated', getget(h,'paperorientation') )
            z = cat( 3, rot90(z(:,:,1),-1), rot90(z(:,:,2),-1), rot90(z(:,:,3),-1) );
        end
        imwrite( z, tiffName, 'tiff', 'Compression', 'packbits',...
            'Description', 'HG Figure Preview',...
            'Resolution',[150 150])
    else
        %If creating preview using GS, need to save 72dpi PS to temporary place
        hardcopy( h, pj.FileName, [ '-d' pj.Driver], '-r72');

        %We now have a temporary 72dpi EPS file, convert that to TIFF.
        pj.GhostName = tiffName;
        res = get(0,'screenpixelsperinch');
        pj.GhostExtent = (res/72).*pj.GhostExtent;
        pj = ghostscript( pj ); %#ok
    end
catch ex
    error('MATLAB:render:previewError','Could not create TIFF preview, error was:%s\n', ex.getReport('basic'))
end
%--------------------------------------------------------------------------
function imwriteArgs = LocalCreateImwriteArgs( pj )
%
% Create a cell-array of input arguments for IMWRITE
%

imwriteArgs = {};

%We will have extra arguments for when we call IMWRITE.
if strcmp(pj.DriverClass, 'IM' )
    if strncmp( pj.Driver, 'tiff', 4 )
        imwriteArgs{end+1} = 'Compression';
        if strcmp( pj.Driver, 'tiffnocompression')
            imwriteArgs{end+1} = 'none';
        else
            imwriteArgs{end+1} = 'packbits';
        end

        imwriteArgs{end+1} = 'Description';
        imwriteArgs{end+1} = 'MATLAB Handle Graphics';

        imwriteArgs{end+1} = 'Resolution';
        if pj.DPI == -1
            imwriteArgs{end+1} = 150;
        elseif pj.DPI == 0
            imwriteArgs{end+1} = get(0,'screenpixelsperinch');
        else
            imwriteArgs{end+1} = pj.DPI;
        end

    elseif strncmp( pj.Driver, 'jpeg', 4 )
        %Already checked that it is in acceptable format.
        imwriteArgs{end+1} = 'Quality';
        imwriteArgs{end+1} = sscanf(pj.Driver,'jpeg%d');
        if isempty( imwriteArgs{end} )
            %Default quality level
            imwriteArgs{end} = 75;
        end

    elseif strcmp( pj.Driver, 'png' )

        imwriteArgs{end+1} = 'CreationTime';
        imwriteArgs{end+1} = datestr(clock,0);

        imwriteArgs{end+1} = 'ResolutionUnit';
        imwriteArgs{end+1} = 'meter';

        if pj.DPI == -1
            dpi = 150;
        elseif pj.DPI == 0
            dpi = get(0,'screenpixelsperinch');
        else
            dpi = pj.DPI;
        end
        dpi = fix(dpi * 100.0 / 2.54 + 0.5);

        imwriteArgs{end+1} = 'XResolution';
        imwriteArgs{end+1} = dpi;

        imwriteArgs{end+1} = 'YResolution';
        imwriteArgs{end+1} = dpi;

        imwriteArgs{end+1} = 'Software';
        imwriteArgs{end+1} = 'MATLAB, The MathWorks, Inc.';
    end
end
%--------------------------------------------------------------------------
function inputargs = LocalPrintJob2Arguments( pj, h )
%
% Make Cell-array of input arguments for old hardcopy from PrintJob.
%

inputargs{1} = h;
inputargs{2} = pj.FileName;

%If asking internal driver to create a zbuffer image to call
%IMWRITE with, set driver argument accordingly.
if strcmp( pj.DriverClass, 'IM')
    inputargs{3} = LocalGetImageDriver(h, pj.Renderer);
else
    inputargs{3} = [ '-d' pj.Driver];
end

if pj.DPI ~= -1
    inputargs{end+1} = ['-r' num2str(pj.DPI)];
end
if ~pj.PostScriptTightBBox
    inputargs{end+1} = '-loose';
end
if pj.PostScriptCMYK
    inputargs{end+1} = '-cmyk';
end
if pj.PostScriptAppend
    inputargs{end+1} = '-append';
end
if ~pj.PostScriptLatin1
    inputargs{end+1} = '-adobecset';
end
if pj.Verbose == 1
    inputargs{end+1} = '-v';
end

if ispc && strncmp(pj.Driver, 'win', 3)
    if isfigure(h) && isempty(getprinttemplate(h))
        if ~pj.DriverColorSet
            inputargs{end+1} = '-wcolor';
        end
    end
end

% add _P option to hardcopy for Windows only
if ispc
    if strcmp( pj.PrinterName, '' )==0 % if printer is not empty send it on windows
        inputargs{end+1} = [ '-P' pj.PrinterName ];
    end
end
%--------------------------------------------------------------------------
function imageDriver = LocalGetImageDriver(h, renderer)
%
%
%
if isempty(renderer)
    renderer = get(h, 'Renderer');
end
if strcmp( renderer, 'painters' )
    renderer = 'zbuffer';
end
imageDriver = ['-d' renderer];
%--------------------------------------------------------------------------
function pj = LocalRender(pj,obj)
%
%
%

%Leave syntax highlighting on for now
oldBackgroundEnable = false;
oldSyntaxHilightEnable = false;
isStateflow = false;

if (isa(obj,'Stateflow.Object'))
   
    isStateflow = true;
    
    % cache existing BG and Syntax hiliting info.
    renderer = Stateflow.SFGLRCRenderer;
    oldBackgroundEnable = renderer.renderBackground;
    oldSyntaxHilightEnable = renderer.syntaxHighlighting;

    % turn off background color rendering if going to a printer
    if(isPrintingToPrinter(pj))
        renderer.renderBackground = false;
    end
    
    % turn on color printing for stateflow (sramaswa, Oct 3rd 2006)
    renderer.syntaxHighlighting = true;
end

try
    % Get print mode to use
    if pj.TiledPrint
        mode = 'tiled';
    elseif pj.FramePrint
        mode = 'frame';
    else
        mode = LocalSLSFGet(obj,'PaperPositionMode');
    end


    if ( strcmp(pj.Driver,'bitmap')...
            && ~logical(isStateflow)...
            && ~strcmp(mode,'tiled') )
        % non-tiled bitmap printing of Simulink is special in that it pays
        % attention to the current view of the model for the print extents
        % as the old implementation was a screen grab
        mode = 'bitmap';
    end

    switch mode
        case 'auto'
            pj = LocalRenderAuto(pj, obj);
        case 'manual'
            pj = LocalRenderManual(pj, obj);
        case 'tiled'
            pj = LocalRenderTiled(pj, obj);
        case 'frame'
            pj = LocalRenderFrame(pj, obj);
        case 'bitmap'
            pj = LocalRenderBitmap(pj, obj);
    end
catch ex
    if isStateflow
        renderer = Stateflow.SFGLRCRenderer;
        renderer.renderBackground = oldBackgroundEnable;
        renderer.syntaxHighlighting = oldSyntaxHilightEnable;
    end

    % reset any persistent frame info if printing with frames
    renderframe('reset');
    rethrow(ex);
end

if isStateflow
    renderer = Stateflow.SFGLRCRenderer;
    renderer.syntaxHighlighting = oldSyntaxHilightEnable;
    renderer.renderBackground = oldBackgroundEnable;
end

if ( pj.PrintOutput && ~strcmp( pj.FileName, '' ) )
    % we've been going directly to the printer by calling print
    % internally, so don't let the caller try to ship to the printer
    % again
    pj.PrintOutput = 0;
end

if ( strcmp( pj.Driver, 'hpgl' ) )
    % HPGL wants to post-process, but it wants to post-process a file
    % that we never created, because of the tile numbering scheme.
    % Because we printed recursively, all the tiles were
    % post-processed, and since it's not safe to post-process a file
    % multiple times, we just clear out the file name here, and have
    % modified hpgl.m such that a blank file name triggers an early
    % exit.
    pj.FileName = '';
end

if ( pj.GhostDriver )
    % same basic issue with recursive printing that requires
    % GhostScript - we've already sent the right data to Ghostscript
    % to begin with. Just clear out the GhostDriver field.
    pj.GhostDriver = 0;
end
%--------------------------------------------------------------------------
function isPdfWrite = LocalIsDriverPDFWrite(pj)

 isPdfWrite = strcmpi(pj.GhostDriver,'pdfwrite');
%--------------------------------------------------------------------------
function pj = LocalRenderAuto(pj, obj)
%
% Render for PaperPositionMode = Auto
%

if(~strcmp(pj.GhostDriver,'') && ~LocalIsDriverPDFWrite(pj) && all( pj.GhostTranslation ~= [0 0] ))
    pj = LocalRenderManual(pj, obj);
    return;
end

portal = Portal.Portal;
portal.units = 'Pixels';

inSFViewMode = LocalInSFCurrentViewMode(obj);
isStateflow = isa(obj,'Stateflow.Object');
isTight = isDriverTight(pj);
% Note. SVG goes through almost the same code path as QT
isSVG = strcmpi(pj.Driver,'svg'); 
usesQt = WillRasterizeWithQt(pj);
% pointsPerInch = 72;
% pointsToPixels = get(0,'ScreenPixelsPerInch')/pointsPerInch;

% save the old PaperUnits, since we really want to deal with points
oldPaperUnits = LocalSLSFGet(obj,'PaperUnits');
LocalSLSFSet(obj,'PaperUnits','points');
paperOrientation = LocalSLSFGet(obj,'PaperOrientation');
paperSize = LocalSLSFGet(obj,'PaperSize');

% "normalize" the paper size to be the size we want our portal. This
% means for "portrait" mode printing we want to be taller than we are
% wide, and for "landscape" mode wider than we are tall
% This is corner case since PaperSize always honors the PaperOrientation
% type. Since the code was there in the first place, I will leave it as of
% now. (sramaswa, 04/08)
wantPortalSize = paperSize;
if (( (wantPortalSize(2) > wantPortalSize(1)) && strcmpi(paperOrientation,'landscape') ) || ...
    ( (wantPortalSize(1) > wantPortalSize(2)) && strcmpi(paperOrientation,'portrait')   ))
    tmp = wantPortalSize(1);
    wantPortalSize(1) = wantPortalSize(2);
    wantPortalSize(2) = tmp;
end

% portalOrientation determines whether the portal is actually rotated.
% When we print to the printer, we don't actually rotated the portal
% because that is handle by the printer code.  However, when we print
% to file, we need to rotate the portal to get a rotated image file.  This
% variable is used to set the portal viewExtents.
portalOrientation = 'portrait';
portal.size = Portal.Point(wantPortalSize(1),wantPortalSize(2));
isToFile = (isTight && usesQt) || isSVG;
if isToFile
    if strcmpi(paperOrientation,'landscape')
        set(Simulink.SLGLRCRenderer,'rotation',pi/2);
        if isStateflow
            set(Stateflow.SFGLRCRenderer,'rotation',pi/2);
        end
        portalOrientation = 'landscape';
        % Not needed since we use targetExtent to get the correct size
        %paperPosition([4,3]) = paperPosition([3,4]);
    elseif strcmpi(paperOrientation,'rotated')
        set(Simulink.SLGLRCRenderer,'rotation',-pi/2);
        if isStateflow
            set(Stateflow.SFGLRCRenderer,'rotation',-pi/2);
        end
        portalOrientation = 'rotated';
        % Not needed since we use targetExtent to get the correct size
        %paperPosition([4,3]) = paperPosition([3,4]);
    end
end

% Now, we can aim the portal at our model.
portal.targetObject = obj;
set(Simulink.SLGLRCRenderer,'rotation',0);
if isStateflow
    set(Stateflow.SFGLRCRenderer,'rotation',0);
end

pointsPerInch = 72;
halfInchInPoints = 0.5*pointsPerInch;

targetExtents = portal.targetObjectExtents;
targetWidth = targetExtents.width;
targetHeight = targetExtents.height;

% To the printer for both Simulink and Stateflow (Not Zoomed)
if ~isTight && ~inSFViewMode
    % Determine margins so target object is scaled at 100%
    margin.left = (portal.size.x - targetWidth)/2;
    margin.top = (portal.size.y - targetHeight)/2;
    margin.right = margin.left;
    margin.bottom = margin.top;

    if ((margin.left > halfInchInPoints) && (margin.top > halfInchInPoints))
        % Object fits at 100%.
        portal.minimumMargins.left = margin.left;
        portal.minimumMargins.top = margin.top;
        portal.minimumMargins.right = margin.right;
        portal.minimumMargins.bottom = margin.bottom;
    else
        % Object does not fit, resized to fit with some padding.
        portal.minimumMargins.setToUniformValue(halfInchInPoints);
    end

% To the printer for Stateflow (Zoomed)
elseif ~isTight && inSFViewMode
    % In SF Zoom mode.  Just zoom to the entire paper size
    portal.minimumMargins.setToUniformValue(halfInchInPoints);

    % Adjust the portal view extent
    LocalSetSFCurrentView(portal,obj,portalOrientation);

% To Image file for Stateflow (Zoomed)
elseif isTight && inSFViewMode
    % Get view dimensions
    viewLimits = LocalGetSFViewLimits(obj);
    if strcmpi(portalOrientation,'portrait')
        viewWidth = viewLimits(2) - viewLimits(1);
        viewHeight = viewLimits(4) - viewLimits(3);
    else
        viewWidth = viewLimits(4) - viewLimits(3);
        viewHeight = viewLimits(2) - viewLimits(1);
    end

    % Set margin to zero to avoid hanging draw objects
    portal.minimumMargins.setToUniformValue(0);

    % Scale to the editor view
    zoomFactor = 1/LocalGetSFObjZoomFactor(obj);
    
    % Account for SF editor displayed in points.
    zoomFactor = zoomFactor * LocalGetScreenPixelsPerPoint;
    portal.size = Portal.Point(viewWidth*zoomFactor,viewHeight*zoomFactor);

    % Adjust the portal view extent
    LocalSetSFCurrentView(portal,obj,portalOrientation);

% To Image file for Simulink & Stateflow (Not Zoomed)
else %isTight && ~inSFViewMode (default view)
    % Add some padding
    padding = 5;
    portal.minimumMargins.setToUniformValue(padding);

    % Not using paperPosition because fitPortalByFactor can handle both SL and SF
    % Note: Should we convert from Pixels to Points?
    % When the portal outputs to a printer, the portal screen units are 
    % interepreted as "points" even though the portal unit is "pixels".  When 
    % the portal is outputted to a file, the portal units are treated as pixels.
    %
    % portal.fitPortalByFactor(pointsToPixels);
    if ((portal.targetObjectExtents.width > 0) && (portal.targetObjectExtents.height > 0))
        % Portal has a maximum dimension limit of 5000 pixels.
        maxSize = 5000; 
        
        if strcmpi(pj.Driver,'meta')
            % Work around for g392424.  Meta images must fit on to screen
            screenSize = get(0,'ScreenSize');
            minScreenSize = min(screenSize(3:4));
            maxFigSize = minScreenSize*72/get(0,'ScreenPixelsPerInch');
            if (maxFigSize < 5000)
                maxSize = maxFigSize;
            end
        end
        
        LocalAdjustPortalSizeForImageFormats(portal, padding, maxSize);
    end
end

% If we're running the student version, add an annotation to the portal
if (isstudent() && WillRasterizeWithQt(pj))
    AddStudentAnnotationToPortal(portal);
end

g = portal.getCanvas();

pj = LocalRenderCanvas(pj, g, obj, 0);

LocalSLSFSet(obj,'PaperUnits',oldPaperUnits);
%--------------------------------------------------------------------------
function pj = LocalRenderManual(pj,obj)
%
% Render for PaperPositionMode = Manual
%

% pointsPerInch = 72;
% pointsToPixels = get(0,'ScreenPixelsPerInch')/pointsPerInch;

inSFViewMode = LocalInSFCurrentViewMode(obj);
isStateflow = isa(obj,'Stateflow.Object');
isTight = isDriverTight(pj);
% Note. SVG goes through almost the same code path as QT
isSVG = strcmpi(pj.Driver,'svg');
usesQt = WillRasterizeWithQt(pj);

portal = Portal.Portal;
portal.units = 'Pixels';

% Save the old PaperUnits, since we really want to deal with points
oldPaperUnits =LocalSLSFGet(obj,'PaperUnits');
LocalSLSFSet(obj,'PaperUnits','points');
paperOrientation = LocalSLSFGet(obj,'PaperOrientation');
paperSize = LocalSLSFGet(obj,'PaperSize');
paperPosition = LocalSLSFGet(obj,'PaperPosition');

% Deal with ghostscript translation
if ( ~(strcmp(pj.GhostDriver,'')) && ~LocalIsDriverPDFWrite(pj) && all( pj.GhostTranslation ~= [0 0] ) )
    paperPosition(1:2) = paperPosition(1:2) - pj.GhostTranslation;
end

% "normalize" the paper size to be the size we want our portal. This
% means for "portrait" mode printing we want to be taller than we are
% wide, and for "landscape" mode wider than we are tall.
% This is corner case since PaperSize always honors the PaperOrientation
% type. Since the code was there in the first place, I will leave it as of
% now. (sramaswa, 04/08)
if (( (paperSize(2) > paperSize(1)) && strcmpi(paperOrientation,'landscape') ) || ...
    ( (paperSize(1) > paperSize(2)) && strcmpi(paperOrientation,'portrait')   ))
    tmp = paperSize(1);
    paperSize(1) = paperSize(2);
    paperSize(2) = tmp;
end

% portalOrientation determines whether the portal is actually rotated.
% When we print to the printer, we don't actually rotated the portal
% because that is handle by the printer code.  However, when we print
% to file, we need to rotate the portal to get a rotated image file.  This
% variable is used to set the portal viewExtents.
portalOrientation = 'portrait';
isToFile = (isTight && usesQt) || isSVG; 
if isToFile
    if strcmpi(paperOrientation,'landscape')
        set(Simulink.SLGLRCRenderer,'rotation',pi/2);
        if isStateflow
            set(Stateflow.SFGLRCRenderer,'rotation',pi/2);
        end
        portalOrientation = 'landscape';
        % Needed.  We need to account for the rotation
        paperPosition([4,3]) = paperPosition([3,4]);

    elseif strcmpi(paperOrientation,'rotated')
        set(Simulink.SLGLRCRenderer,'rotation',-pi/2);
        if isStateflow
            set(Stateflow.SFGLRCRenderer,'rotation',-pi/2);
        end
        portalOrientation = 'rotated';
        % Needed.  We need to account for the rotation
        paperPosition([4,3]) = paperPosition([3,4]);
    end
end

% now, we can aim the portal at our model.Simulink systems needs some
% margin adjustments. But for stateflow, use the existing default margins
% provided by the portal !!
portal.targetObject = obj;
set(Simulink.SLGLRCRenderer,'rotation',0);
if isStateflow
    set(Stateflow.SFGLRCRenderer,'rotation',0);
end

% To Printer for both Simulink and Stateflow
if ~isTight
    % size the portal as expected. Let it draw in pixels.
    portal.size = Portal.Point(paperSize(1), paperSize(2));

    % Get model paper position. Note that paper position will be in HG Coords.
    % Bottom left on HG coordinate system where y-axis goes upward will be top left
    % on portal coordinate system where the y-axis goes down.
    sysRect = [paperPosition(1), ...
        paperSize(2) - paperPosition(2) - paperPosition(4), ...
        paperPosition(3), ...
        paperPosition(4)];

    % Set margins to enclose sysRect
    portal.minimumMargins.left = sysRect(1);
    portal.minimumMargins.top = sysRect(2);
    portal.minimumMargins.right = paperSize(1) - sysRect(1) - sysRect(3);
    portal.minimumMargins.bottom = paperSize(2) - sysRect(2) - sysRect(4);

    if inSFViewMode
        % Adjust the portal view extent
        LocalSetSFCurrentView(portal,obj,portalOrientation);
    end

%     % Debug code
%     glrcCanvas = portal.getCanvas;
%     glrcLayers = glrcCanvas.getLayers;
%     glrcModel = glrcLayers(2).getModel;
%     glrcModel.addNode(glrcModel.createRectNode(sysRect(1),sysRect(2),sysRect(3),sysRect(4)));

else
    % Set portal size to match paper position
    % Note: Should we convert from Pixels to Points?
    % When the portal outputs to a printer, the portal screen units are 
    % interepreted as "points" even though the portal unit is "pixels".  When 
    % the portal is outputted to a file, the portal units are treated as pixels.
    %
    % portal.size = Portal.Point(pointsToPixels*paperPosition(3), ...
    %     pointsToPixels*paperPosition(4)); 
    portal.size = Portal.Point(paperPosition(3), paperPosition(4));

    margins = 5;
    if inSFViewMode
        % Set margin to zero to avoid hanging draw objects
        margins = 0;

        % Adjust the portal view extent
        LocalSetSFCurrentView(portal,obj,portalOrientation);
    end

    portal.minimumMargins.setToUniformValue(margins);
    portal.size = Portal.Point( ...
        portal.size.x - portal.actualMargins.left - portal.actualMargins.right + margins, ...
        portal.size.y - portal.actualMargins.top - portal.actualMargins.bottom + margins);
end

% If we're running the student version, add an annotation to the portal
if (isstudent() && WillRasterizeWithQt(pj))
    AddStudentAnnotationToPortal(portal);
end

g = portal.getCanvas();
pj = LocalRenderCanvas(pj, g, obj, 0);

LocalSLSFSet(obj,'PaperUnits',oldPaperUnits);
%--------------------------------------------------------------------------
function pj = LocalRenderFrame(pj,obj)
%
% Render for printing with frames
%

oldPaperUnits = LocalSLSFGet(obj,'PaperUnits');

[portal obj] = renderframe('render',obj);

% If we're running the student version, add an annotation to the portal
if (isstudent() && WillRasterizeWithQt(pj))
    AddStudentAnnotationToPortal(portal);
end

g = portal.getCanvas();
pj = LocalRenderCanvas(pj, g, obj, 0);

LocalSLSFSet(obj,'PaperUnits',oldPaperUnits);
%--------------------------------------------------------------------------
function pj = LocalRenderTiled(pj, obj)
%
% Render for PaperPositionMode = Tiled
%

portal = Portal.Portal;

% save the old PaperUnits, since we really want to deal with points
oldPaperUnits = LocalSLSFGet(obj,'PaperUnits');
LocalSLSFSet(obj,'PaperUnits','points');

paperOrientation = LocalSLSFGet(obj,'PaperOrientation');
paperSize = LocalSLSFGet(obj,'PaperSize');
pageScale = LocalSLSFGet(obj,'TiledPageScale');
tilePageMargins = LocalSLSFGet(obj,'TiledPaperMargins');

pageScale = pageScale * 96.0 /72.0;

% "normalize" the paper size to be the size we want our portal. This
% means for "portrait" mode printing we want to be taller than we are
% wide, and for "landscape" mode wider than we are tall.
% This is corner case since PaperSize always honors the PaperOrientation
% type. Since the code was there in the first place, I will leave it as of
% now. (sramaswa, 04/08)
wantPortalSize = paperSize;
if (( (wantPortalSize(2) > wantPortalSize(1)) && strcmpi(paperOrientation,'landscape') ) || ...
        ( (wantPortalSize(1) > wantPortalSize(2)) && strcmpi(paperOrientation,'portrait')))
    tmp = wantPortalSize(1);
    wantPortalSize(1) = wantPortalSize(2);
    wantPortalSize(2) = tmp;
end

% size the portal as expected. Let it draw in pixels.
portal.units = 'Pixels';
portal.size.x = wantPortalSize(1);
portal.size.y = wantPortalSize(2);

% and add in minmum margins
portal.minimumMargins.left = tilePageMargins(1);
portal.minimumMargins.top = tilePageMargins(2);
portal.minimumMargins.right = tilePageMargins(3);
portal.minimumMargins.bottom = tilePageMargins(4);

% If we're running the student version, add an annotation to the portal
if (isstudent() && WillRasterizeWithQt(pj))
    AddStudentAnnotationToPortal(portal);
end

pageWidth = portal.size.x - portal.minimumMargins.left - portal.minimumMargins.right;
pageHeight = portal.size.y - portal.minimumMargins.top - portal.minimumMargins.bottom;
tileWidth = pageWidth * pageScale;
tileHeight = pageHeight * pageScale;

% now, we can aim the portal at our model
portal.targetObject = obj;

% compute width and height including 0,0
srcExtents = portal.targetObjectExtents;
srcWidth = srcExtents.width + srcExtents.topLeftPt.x;
srcHeight = srcExtents.height + srcExtents.topLeftPt.y;

numTilesWide = ceil( srcWidth / tileWidth );
numTilesHigh = ceil( srcHeight / tileHeight );

% and loop over the pages. For now, we're not really printing, we're
% just creating figure windows per-tile
pageNum = 0;
for yi = 0:(numTilesHigh-1)
    for xi = 0:(numTilesWide-1)
        pageNum = pageNum + 1;
        if (pageNum >= pj.FromPage) && (pageNum <= pj.ToPage)
            topLeft = Portal.Point;
            botRight = Portal.Point;

            topLeft.x = xi * tileWidth;
            topLeft.y = yi * tileHeight;
            botRight.x = topLeft.x + tileWidth;
            botRight.y = topLeft.y + tileHeight;

            portal.viewExtents.clear();
            portal.viewExtents.unionPt( topLeft );
            portal.viewExtents.unionPt( botRight );

            g = portal.getCanvas();
            %f = g.renderToFigure();
            %set(f,'Visible','on');
            pj = LocalRenderCanvas(pj, g, obj, pageNum);
        end
    end
end

LocalSLSFSet(obj,'PaperUnits',oldPaperUnits);
%--------------------------------------------------------------------------
function pj = LocalRenderBitmap(pj, obj)
% Render the print job as a bitmap file containing the viewable extent
% of the model in the current view, ignoring PaperPosition et al.
% Since we use the 'Location' param to cook this out, it is worth
% making note of a platform difference: Windows excludes the scrollbar
% area from this rectangle, while Unixes (X11) does not. This keeps the
% behavior consistent with the old -dbitmap behavior on Windows. On
% Unixes/Mac OS, -dbitmap wasn't previously supported, so the
% difference isn't an issue there. This is apparently a long-standing
% difference in handle graphics.

loc = get(obj,'Location');
zoomFactor = get(obj,'ZoomFactor');
if ( ischar(zoomFactor) ) % sometimes, it just is
    zoomFactor = str2double(zoomFactor);
end
zoomFactor = zoomFactor / 100;
scrollOffset = get(obj,'ScrollBarOffset');

% calculate the viewable extent
top = scrollOffset(2)/zoomFactor;
left = scrollOffset(1)/zoomFactor;
width= loc(3)-loc(1);
height = loc(4)-loc(2);

bottom = top + ( height/zoomFactor );
right = left + ( width/zoomFactor );

% set up the portal to match exactly
portal = Portal.Portal;
portal.units = 'pixels';
portal.targetObject = obj;
portal.minimumMargins = Portal.Margins(0,0,0,0);
portal.size = Portal.Point( width, height );
portal.viewExtents.clear;
portal.viewExtents.unionPt( Portal.Point(left, top) );
portal.viewExtents.unionPt( Portal.Point(right, bottom) );

% render the canvas to a bitmap file.
portal.getCanvas.print('','bmp',pj.FileName,'usletter','landscape',0,0,0,0,0,0);
%--------------------------------------------------------------------------
function tf = isDriverTight(pj)
%Returns true if the current driver uses tight bounds.  Typical of
%raster formats which don't need to show unnecessary whitespace at the
%edge of the paper.
%
%Does not include -dbitmap, because that's exclusively a screen
%capture.

% Notes:
% ======
% 1. Even if DriverClass is GS, it need necessarily have tight bounds. One
% example is pdfwrite. If pdfwrite has tight bounds it trims the boundaries
% and puts the image in the bottom of the pdf document. See g452666
% (Sridhar Ramaswamy March 2008)
%

tf = strcmpi(pj.DriverClass,'IM') || ... %imread/imwrite
    strcmpi(pj.DriverClass,'EP') || ... % EP
    (strcmpi(pj.DriverClass,'GS') && ~strcmpi(pj.GhostDriver,'pdfwrite')) || ...   %ghostscript && ~pdfwrite
    strcmpi(pj.Driver,'meta') || ...   %MW windows-specific
    strcmp(pj.Driver,'svg'); %Don't need extra space on SVG images
%--------------------------------------------------------------------------
function toPrinter = isPrintingToPrinter(pj)
% Check whether the printing is sent to printer or a file. Criteria varies
% for unix and PC

if(isunix)
    toPrinter = logical(pj.PrintOutput);
else
    toPrinter = strncmpi(pj.Driver,'win',3) && strcmpi(pj.FileName,'');
end
%--------------------------------------------------------------------------
function result = WillRasterizeWithQt(pj)
% will this print job, as given, rasterize using Qt? We should probably
% change this function to call in to interrogate the as-compiled Qt,
% since the list of supported types could potentially change.

device = pj.Driver;
if ( strcmp(device,'') )
    device = pj.DefaultDevice(3:end);
end

[pj, device, filename] = LocalQtDeviceAlias( pj, device ); %#ok
result = 0; %#ok Bug in Mlint
switch( device )
    case 'pbm'
        result = 1;
    case 'pgm'
        result = 1;
    case 'ppm'
        result = 1;
    case 'bmp'
        result = 1;
    case 'png'
        result = 1;
    otherwise
        if ( max(size(device)) >= 4 && strcmpi(device(1:4),'jpeg') )
            result = 1;
        else
            result = 0;
        end
end

% Due to Qt4.4.0 upgrade, formats supported by Qt such as PNG/JPG/BMP does
% not look good on MACI. As of now we are going via the HG pipeline to
% workaorund this issue. We will switch it back after we get a valid fix
% from TrollTech. See geck 476215 for more info.
if(ismac)
   result = 0;
end
%--------------------------------------------------------------------------
function AddStudentAnnotationToPortal(portal)
%
% Insert a little label at the bottom-right corner of the page
%

canvas = portal.getCanvas;
layers = canvas.getLayers;
olayLayer = layers(2);
m = olayLayer.getModel;

% Calculate the text location (20 pixels from bot-right corner)
offset = 20;
x = portal.size.x - offset;
y = portal.size.y - offset;

% Text properties
fontName    = 'Helvetica';
fontSize    = 10;
fontAngle   = 'ITALIC_ANGLE';
fontWeight  = 'BOLD_WEIGHT';
color       = [0 0 0 1]; % black
textFormat  = 'SIMPLE_FORMAT';  
hAlign      = 'RIGHT_TEXT';
vAlign      = 'BOTTOM_TEXT';
label       = 'Student Version of MATLAB';

% Add a separator to hold text node draw properties
txtNode = m.createSeparatorNode();
m.addNode(txtNode);

% Draw it!
m.addNode(txtNode, m.createStrokeNode(color));
m.addNode(txtNode, m.createFontNode(fontName, fontSize, fontWeight, fontAngle));
m.addNode(txtNode, m.createTextNode(x, y, label, hAlign, vAlign, textFormat));

% Make sure the bottom margin of the portal is at least as tall as our
% text (plus a 10 pixel fudge factor)
txtBounds = olayLayer.getDrawState(txtNode).bounds;
minTextMargin = offset+txtBounds(4)+10;
if (portal.actualMargins.bottom < minTextMargin)
    portal.minimumMargins.bottom = minTextMargin;
end
%--------------------------------------------------------------------------
function pj = LocalRenderCanvas( pj, canvas, obj, tileNum)
%
% Function that actually renders/prints the object on GLRC canvas
%

paperType = LocalSLSFGet(obj,'PaperType');
paperOrientation = LocalSLSFGet(obj,'PaperOrientation');

device = pj.Driver;
if (strcmp(device,''))
    device = pj.DefaultDevice(3:end);
end

% Fix for:
%    http://komodo.mathworks.com/main/gecko/view?Record=482572
% If the device is 'win' and the canvas is printed to a 
% color printer, the color is stripped off from the resulting figure
% from the canvas inside 'print' function. 'winc' for even BW printer works
% fine w/o problems. (sramaswa, Aug 2008)
if(ispc && isPrintingToPrinter(pj))
    device = 'winc';
end

% deal with any types we want to try mapping to Qt
[pj, device, filename] = LocalQtDeviceAlias( pj, device );

if ( tileNum ~= 0 && ~strcmp(filename,'') )
    % not direct to printer, but still tiled (i.e. generating a
    % raster file.) Adjust the file name to incorporate a tile
    % number.
    [path,file,ext]=fileparts(filename);
    file=sprintf('%s_%d',file,tileNum);
    filename=fullfile(path,[file ext]);
end

% clear the error state
err.message='';
err.identifier='';

oldLang = get(0, 'lang');
set(0, 'lang', 'en');

try
    % tiff formats are tricky. They can crop the edges of SF/SL blocks
    % resulting in incomplete figures. tiff goes through HG rendering as
    % opposed to PNG, JPEG, BMP etc. which go through Qt. So, temporarily save
    % the image as PNG and then use imread/imwrite pair to read the PNG file
    % and write it back to the original file as TIFF file. (Idea by Dennis
    % Wilkinson)
    convertBackToTiff = false;
    if(strcmpi(device,'tiff'))
        [~, basename] = fileparts(filename);
        basename = [basename '.png'];
        tmpFileName = [tempname '_' basename];
        origFileName = filename;
        filename = tmpFileName;
        device = 'png';
        convertBackToTiff = true;
    end

    % OK, print it !!!
    canvas.print( pj.PrinterName, device, filename, paperType, paperOrientation,...
        max(pj.DPI,0), ~(pj.PostScriptTightBBox), pj.PostScriptAppend,...
        (pj.PostScriptPreview==pj.TiffPreview), pj.PostScriptCMYK, ~(pj.PostScriptLatin1) );

    % For tiff formats convert the png file back to tiff
    if(convertBackToTiff)
        [a,map,alpha] = imread(tmpFileName,'png'); %#ok
        if(~isempty(map))
            imwrite(a,map,origFileName,'tiff');
        else
            imwrite(a,origFileName,'tiff');
        end
        delete(tmpFileName); % delete the temp tiff file
    end
catch ex
    set(0, 'lang', oldLang);
    rethrow(ex);
end

set(0, 'lang', oldLang);
%--------------------------------------------------------------------------
function [isSLSF, obj] = LocalGetSLSFObject( hdl, pj )
%
%
%

isSLSF = 0;
obj = 0;

if ( ~inmem('-isloaded','simulink') )
    return;
end

% hdl will be vector when printing with frames. if that is the case we are
% going through the old pipeline for frames. So just return
if(~isscalar(hdl))
    return;
end

if isslhandle( hdl )
    % for Simulink handles, the object is just the model's object
    obj = get_param(hdl,'Object');
    isSLSF = 1;
elseif ishghandle( hdl )
    try
        % otherwise, we should be some sort of figure. If our tag
        % indicates that we come from Stateflow, extract the chart ID
        % and get the object
        tag = get(hdl,'Tag');
        if ( strcmp( tag, 'SF_PORTAL') )
            portalId = get(hdl,'UserData');
            objId = sf('get',portalId,'.viewObj');
            obj = idToHandle(sfroot,objId);
            isSLSF = 1;
        end
    catch ex
    end
elseif ( length(hdl) > 1 )
    % special case - if we're dealing with print formats that were
    % figure only, pre-new-pipeline, and get a request to draw a model
    % to that format with print frames, just drop the print frame.
    if ( strcmpi(pj.DriverClass,'IM') )
        restrictedHdl = LocalDropPrintFrames(hdl);
        if ( length(restrictedHdl) == 1 )
            device = pj.Driver;
            if ( strcmp(device,'') )
                device = pj.DefaultDevice(3:end);
            end
            display(sprintf('Format "%s" can not be used with printframes', device ));
            [isSLSF, obj] = LocalGetSLSFObject( restrictedHdl, pj );
        end
    end
end
%--------------------------------------------------------------------------
function outHdl = LocalDropPrintFrames(hdl)
%
% remove any handles from hdl that are print frames
%

outHdl = [];
for i=1:length(hdl)
    thisHdl = hdl(i);
    if ( ishghandle(thisHdl) )
        try
            tag = get(thisHdl,'Tag');
            if ( ~strcmpi(tag,'PrintFrameFigure') )
                outHdl = [outHdl thisHdl]; %#ok
            end
        catch ex
        end
    else
        outHdl = [outHdl thisHdl]; %#ok
    end
end
%--------------------------------------------------------------------------
function [pj, device, filename] = LocalQtDeviceAlias( pj, device )
%
%
%

filename = pj.FileName;
if ( pj.PrintOutput )
    % direct to printer in new path. Let the internal call to HG
    % printing sort out intermediate files
    filename = '';
end

% first, deal with 'straight' device mappings
switch( device )
    case 'bitmap'
        device = 'bmp';
end

if ( strcmp( device, '' ) )
    if ( ispc )
        device = 'win';
    else
        device = 'ps2';
    end
end

% then deal with things we can shortcut in Ghostscript
% (the two spaces should not overlap, generally)
if ( strcmpi(pj.DriverClass,'GS') && ~(strcmp(pj.GhostDriver,'')) )
    switch( pj.GhostDriver )
        case 'bmp16m'
            % use 'native' bitmap drawing
            device = 'bmp';
        case 'png16m'
            % use 'native' png drawing
            device = 'png';
        otherwise
            % use the device name of the GhostDriver, see note below
            % about recursive printing for why
            device = pj.GhostDriver;
    end

    % because we print recursively, we always revert to the original
    % file name, since we'll pick up the Ghostscript work on the
    % innermost call to print (which is HG printing, not this path)
    filename = pj.GhostName;
end
%--------------------------------------------------------------------------
function retVal = LocalSLSFGet(slsfObj,propName)
% Some parameters like PaperPosition, PaperType etc. cannot be gotten from
% objects like Stateflow.Function, Stateflow.State etc. So derive that
% information based on the class type of object. Simulink.<Objects> are
% pretty straightforward i.e. all the Simulink.Objects will have Paper*
% parameters

if(isa(slsfObj,'Stateflow.Object'))
    if(isValidProperty(slsfObj,propName))
        retVal = get(slsfObj,propName);
    else
        chartObj = get(slsfObj,'Chart');
        retVal = get(chartObj,propName);
    end
else
    retVal = get(slsfObj,propName);
end
%--------------------------------------------------------------------------
function LocalSLSFSet(slsfObj,propName,propVal)
% Some parameters like PaperPosition, PaperType etc. cannot be set on
% objects like Stateflow.Function, Stateflow.State etc. So set the
% parameter information based on the class type of object.
% Simulink.<Objects> are pretty straightforward i.e. all the
% Simulink.Objects will have Paper* parameters

if(isa(slsfObj,'Stateflow.Object'))
    if(isValidProperty(slsfObj,propName))
        set(slsfObj,propName,propVal);
    else
        chartObj = get(slsfObj,'Chart');
        set(chartObj,propName,propVal);
    end
else
    set(slsfObj,propName,propVal);
end
%--------------------------------------------------------------------------
function retVal = LocalGetSFObjZoomFactor(sfObj)
%
% Get the zoom factor for any stateflow object. For non-chart objects, get
% the chart first. ZoomFactor is available only on Stateflow.Editor
% object(which in turn is available only from Stateflow.Chart)
%

assert(isa(sfObj,'Stateflow.Object'));

if(isa(sfObj,'Stateflow.Chart'))
    retVal = sfObj.Editor.ZoomFactor;
else
    retVal = sfObj.Chart.Editor.ZoomFactor;
end
%--------------------------------------------------------------------------
function retVal = LocalGetScreenPixelsPerPoint
%
% Screen Pixels/Point.
%

retVal = get(0,'ScreenPixelsPerInch')/72; % 72 Points/Inch is standard
                                          % irrespective of OS.
%--------------------------------------------------------------------------
function retVal = LocalInSFCurrentViewMode(obj)
% Determine wheter we are in SF current view mode.  See SFPRINT

retVal = false;
if ~isa(obj,'Stateflow.Object');
    return
end

oldSFPortal = sf('Private','acquire_print_portal');
viewMode = sf('get', oldSFPortal, '.viewMode');

if (viewMode == 1) % current view
    retVal = true;
end
%--------------------------------------------------------------------------
function LocalSetSFCurrentView(portal,obj,portalOrientation)
% Set portal view extent to fit the Stateflow current view

% View Limits of the chart
viewLimits = LocalGetSFViewLimits(obj);
viewX1 = viewLimits(1);
viewX2 = viewLimits(2);
viewY1 = viewLimits(3);
viewY2 = viewLimits(4);

viewHeight = viewY2 - viewY1;
viewWidth = viewX2 - viewX1;

% Add more comments
if strcmpi(portalOrientation,'landscape')
    portal.viewExtent = Portal.BoundingBox( ...
        Portal.Point(viewY1, -viewX1-viewWidth), ...
        viewHeight, viewWidth);

% Add more comments
elseif strcmpi(portalOrientation,'rotated')
    portal.viewExtent = Portal.BoundingBox( ...
        Portal.Point(-viewY1-viewHeight, viewX1), ...
        viewHeight, viewWidth);

% Add more comments
else %portrait
    portal.viewExtents = Portal.BoundingBox( ...
        Portal.Point(viewX1,viewY1), ...
        viewWidth,viewHeight);
end
%--------------------------------------------------------------------------
function retVal = LocalGetSFViewLimits(obj)
% Get SF view limits

retVal = [0 0 0 0];
if ~isa(obj,'Stateflow.Object');
    return;
end

chartObj = obj;
if ~isa(obj,'Stateflow.Chart')
    chartObj = obj.Chart;
end

% View Limits of the chart
retVal = sf('get',chartObj.id,'.viewLimits');
%--------------------------------------------------------------------------
function LocalAdjustPortalSizeForImageFormats(portal, minMarginPix, maxImageSize)
% LocalAdjustPortalSizeForImageFormats: Make sure that portal size does not
% exceed a given size

PORTAL_MAX_SIZE_PIX = maxImageSize;
PORTAL_CLAMPING_SIZE_PIX = PORTAL_MAX_SIZE_PIX - 1;

% Target object height and width
targetObjWidth = portal.targetObjectExtents.width;
targetObjHeight = portal.targetObjectExtents.height;

% Effective portal width and height after adding the margins
netPortalWidth = targetObjWidth + 2 * minMarginPix;
netPortalHeight = targetObjHeight + 2 * minMarginPix;

if(netPortalWidth <= PORTAL_MAX_SIZE_PIX && netPortalHeight <= PORTAL_MAX_SIZE_PIX)
    
    % Nothing special needs to be done if both width and height are within
    % the acceptable limits. fitPortalByFactor(1) will take care of setting
    % the correct portal size
    portal.fitPortalByFactor(1);
    
else
    
    bt = warning('QUERY', 'BACKTRACE');
    warning('BACKTRACE', 'off');
    
    % issue a warning to the user about clamping the image size
    warning('Simulink:ClampingPrintImageSize', ...
        xlate('Image dimensions exceed threshold of %d pixels. Reducing image dimensions.'),PORTAL_MAX_SIZE_PIX);
    
    warning('BACKTRACE', bt.state);
    
    % width exceeding the limit
    if(netPortalWidth > PORTAL_MAX_SIZE_PIX && netPortalHeight < PORTAL_MAX_SIZE_PIX)
        
        newPortalWidth = PORTAL_CLAMPING_SIZE_PIX;
        newPortalHeight = (PORTAL_CLAMPING_SIZE_PIX / netPortalWidth) * netPortalHeight;
        
    % height exceeding the limit    
    elseif(netPortalHeight > PORTAL_MAX_SIZE_PIX && netPortalWidth < PORTAL_MAX_SIZE_PIX)
        
        newPortalHeight = PORTAL_CLAMPING_SIZE_PIX;
        newPortalWidth = (PORTAL_CLAMPING_SIZE_PIX / netPortalHeight) * netPortalWidth;
        
    % both width and height exceeding the limit    
    else
        
        scaleW = PORTAL_CLAMPING_SIZE_PIX / netPortalWidth;
        scaleH = PORTAL_CLAMPING_SIZE_PIX / netPortalHeight;
        scale = min(scaleW, scaleH);
        newPortalWidth = scale * netPortalWidth;
        newPortalHeight = scale * netPortalHeight;
        
    end
    
    % set the portal width and height
    portal.size.x = newPortalWidth;
    portal.size.y = newPortalHeight;
    
end

% [EOF]


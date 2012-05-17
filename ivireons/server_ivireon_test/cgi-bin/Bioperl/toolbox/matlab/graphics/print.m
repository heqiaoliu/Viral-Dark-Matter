function varargout = print( varargin )
%PRINT Print figure or model. Save to disk as image or MATLAB file.
%   SYNTAX:
%     print
%       PRINT alone sends the current figure to your current printer.
%       The size and position of the printed output depends on the figure's
%       PaperPosition[mode] properties and your default print command
%       as specified in your PRINTOPT.M file.
%
%     print -s
%       Same as above but prints the current Simulink model.
%
%     print -device -options
%       You can optionally specify a print device (i.e., an output format such
%       as tiff or PostScript or a print driver that controls what is sent to
%       your printer) and options that control various characteristics  of the
%       printed file (i.e., the resolution, the figure to print
%       etc.). Available devices and options are described below.
%
%     print -device -options filename
%       If you specify a filename, MATLAB directs output to a file instead of
%       a printer. PRINT adds the appropriate file extension if you do not
%       specify one.
%
%     print( ... )
%       Same as above but this calls PRINT as a MATLAB function instead of
%       a MATLAB command. The difference is only in the parenthesized argument
%       list. It allows the passing of variables for any of the input
%       arguments and is especially useful for passing the handles
%       of figures and/or models to print and filenames.
%
%     Note: PRINT will produce a warning when printing a figure with a
%     ResizeFcn.  To avoid the warning, set the PaperPositionMode to 'auto'
%     or match figure screen size in the PageSetup dialog.
%
%   BATCH PROCESSING:
%       You can use the function form of PRINT, which is useful for batch
%       printing. For example, you can use a for loop to create different
%       graphs and print a series of files whose names are stored in an array:
%
%       for i=1:length(fnames)
%           print('-dpsc','-r200',fnames(i))
%       end
%
%   SPECIFYING THE WINDOW TO PRINT
%       -f<handle>   % Handle Graphics handle of figure to print
%       -s<name>     % Name of an open Simulink model to print
%       h            % Figure or model handle when using function form of PRINT
%
%     Examples:
%       print -f2    % Both commands print Figure 2 using the default driver
%       print( 2 )   % and operating system command specified in PRINTOPT.
%
%       print -svdp  % prints the open Simulink model named vdp
%
%   SPECIFYING THE OUTPUT FILE:
%       <filename>   % String on the command line
%       '<filename>' % String passed in when using function form of PRINT
%
%     Examples:
%       print -dps foo
%       fn = 'foo'; print( gcf, '-dps', fn )
%       Both save the current figure to a file named 'foo.ps' in the current
%       working directory. This file can now be printed to a
%       PostScript-compatible printer.
%
%   COMMON DEVICE DRIVERS
%       Output format is specified by the device driver input argument. This
%       argument always starts with '-d' and falls into one of several
%       categories:
%     Microsoft Windows system device driver options:
%       -dwin      % Send figure to current printer in monochrome
%       -dwinc     % Send figure to current printer in color
%       -dmeta     % Send figure to clipboard (or file) in Metafile format
%       -dbitmap   % Send figure to clipboard (or file) in bitmap format
%       -dsetup    % Bring up Print Setup dialog box, but do not print
%       -v         % Verbose mode, bring up the Print dialog box
%                    which is normally suppressed.
%
%     Built-in MATLAB Drivers:
%       -dps       % PostScript for black and white printers
%       -dpsc      % PostScript for color printers
%       -dps2      % Level 2 PostScript for black and white printers
%       -dpsc2     % Level 2 PostScript for color printers
%
%       -deps      % Encapsulated PostScript
%       -depsc     % Encapsulated Color PostScript
%       -deps2     % Encapsulated Level 2 PostScript
%       -depsc2    % Encapsulated Level 2 Color PostScript
%
%       -dhpgl     % HPGL compatible with Hewlett-Packard 7475A plotter
%       -dill      % Adobe Illustrator 88 compatible illustration file
%       -djpeg<nn> % JPEG image, quality level of nn (figures only)
%                    E.g., -djpeg90 gives a quality level of 90.
%                    Quality level defaults to 75 if nn is omitted.
%       -dtiff     % TIFF with packbits (lossless run-length encoding)
%                    compression (figures only)
%       -dtiffnocompression % TIFF without compression (figures only)
%       -dpng      % Portable Network Graphic 24-bit truecolor image
%                    (figures only)
%
%     Other output formats are possible by using the GhostScript application
%     supplied with MATLAB. For a full listing see the online help
%     for GHOSTSCRIPT, use the command 'help private/ghostscript'.
%     An example of some of the device drivers supported via GhostScript are:
%       -dljet2p   % HP LaserJet IIP
%       -dljet3    % HP LaserJet III
%       -ddeskjet  % HP DeskJet and DeskJet Plus
%       -dcdj550   % HP Deskjet 550C (UNIX only)
%       -dpaintjet % HP PaintJet color printer
%       -dpcx24b   % 24-bit color PCX file format, 3 8-bit planes
%       -dppm      % Portable Pixmap (plain format)
%
%     Examples:
%       print -dwinc  % Prints current Figure to current printer in color
%       print( h, '-djpeg', 'foo') % Prints Figure/model h to foo.jpg
%
%   PRINTING OPTIONS
%     Options only for use with PostScript and GhostScript drivers:
%       -loose     % Use Figure's PaperPosition as PostScript BoundingBox
%       -append    % Append, not overwrite, the graph to PostScript file
%       -tiff      % Add TIFF preview, EPS files only (implies -loose)
%       -cmyk      % Use CMYK colors instead of RGB
%       -adobecset % Use Adobe PostScript standard character set encoding
%
%     Options for PostScript, GhostScript, Tiff, Jpeg, and Metafile:
%       -r<number> % Dots-per-inch resolution. Defaults to 90 for Simulink,
%                    150 for figures in image formats and when
%                    printing in Z-buffer or OpenGL mode,  screen
%                    resolution for Metafiles and 864 otherwise.
%                    Use -r0 to specify screen resolution.
%     Example:
%       print -depsc -tiff -r300 matilda 
%       Saves current figure at 300 dpi in color EPS to matilda.eps
%       with a TIFF preview (at 72 dpi for Simulink models and 150 dpi
%       for figures). This TIFF preview will show up on screen if
%       matilda.eps is inserted as a Picture in a Word document, but
%       the EPS will be used if the Word document is printed on a
%       PostScript printer.
%
%     Other options for figure windows:
%       -Pprinter  % Specify the printer. On Windows and Unix.
%       -noui      % Do not print UI control objects
%       -painters  % Rendering for printing to be done in Painters mode
%       -zbuffer   % Rendering for printing to be done in Z-buffer mode
%       -opengl    % Rendering for printing to be done in OpenGL mode
%       A note on renderers: when printing figures, MATLAB does not always
%       use the same renderer as on screen. This is for efficiency reasons.
%       There are cases, however, where the printed output is not exactly
%       like the screen representation because of this. In these instances
%       specifying -zbuffer or -opengl will more likely give you output that
%       emulates the screen.
%
%   See the Using MATLAB Graphics manual for more information on printing.
%
%   See also PRINTOPT, PRINTDLG, ORIENT, IMWRITE, HGSAVE, SAVEAS.

%   Copyright 1984-2009 The MathWorks, Inc.

% Function handle to be used for Simulink/Stateflow printing.
% Make persistent for efficiency (sramaswa)
persistent slSfPrintFcnHandle;

% Reset error state to empty.
err.message='';
err.identifier='';

pj = [];
if feature('HGUsingMATLABClasses') && ~isempty(varargin) 
    for idx = 1:length(varargin)
        if ischar(varargin{idx}) && strcmp('-printjob', varargin{idx}) && ...
           (idx+1) <= length(varargin) && isstruct(varargin{idx+1})
            pj = varargin{idx+1};
            varargin = {varargin{1:idx-1} varargin{idx+2:end}};
            break;
        end
    end
end

if isempty(pj)
   pj = printjob;
end

try
    wasErr = 0;

    %Check the input arguments and flesh out settings of PrintJob
    [pj, devices, options ] = inputcheck( pj, varargin{:} );

    %----------------------------------------------------------------------
    % Fork for new SL/SF editor printing. 'print' needs to be supported for
    % SL/SF since customers use 'print -s' API a lot and 'sfprint'
    % (published SF API) calls 'print'.
    % -sramaswa
    if(isSLorSF(pj))
        if(slfeature('SLGlueBigSwitch') == 1) % check switch for new editor
            if(isempty(slSfPrintFcnHandle))
                slSfPrintFcnHandle = LocalGetSlSfPrintFcnHandle;
            end
            feval(slSfPrintFcnHandle, pj);
            return;
        end
    end
    % End new SL/SF editor printing fork.
    %----------------------------------------------------------------------
    
    % rquist - moved LocalAdjustPrintParamsForDepViewer() call down
    % Printing parameters like paper position, paper size etc. needs to be
    % adjusted for ModelDependencyViewer figure.
    % LocalAdjustPrintParamsForDepViewer(pj);
    
    %User can find out what devices and options are supported by
    %asking for output and giving just the input argument '-d'.
    %Do it here rather then inputcheck so stack trace makes more sense.
    if strcmp( pj.Driver, '-d' )
        if nargout == 0
            disp('Supported devices are:')
            for i=1:length(devices)
                disp(['    -d' devices{i}])
            end
        else
            varargout{1} = devices;
            varargout{2} = options;
        end
        %Don't actually print anything if user is inquiring.
        return
    end

    pj = preparepointers( pj );

    %Validate that PrintJob state is ok, that input arguments
    %and defaults work together.
    pj = validate( pj );


    %Handle missing or illegal filename.
    %Save possible name first for potential use in later warning.
    tmpName = pj.FileName;
    pj = name( pj );

    %Check to see if filename is variable name in caller's workspace and
    %warn if so -- continue in any case, if the filename specified did NOT
    %have an extension (and could therefore possibly have meant a variable.
    [fndir, fnname, fnext] = fileparts(tmpName);
    if isempty(fnext)  %if no extension, the name could have been a variable
        if any(ismember(evalin('caller','who'),fnname))  % see name matches a variable name
            warning('MATLAB:print:FileName',...
                ['You used the function print with a filename %s that matches the name of\n',...
                'a variable in your workspace.  If you wanted to use the value of %s instead of\n',...
                'printing to the file %s, try calling print in the following form:\n',...
                '      print(''-depsc'',%s)\n',...
                'For a more detailed example, see the doc for <a href="matlab:doc(''print'')">print</a> or \n',...
                '<a href="matlab:helpview(fullfile(docroot,''techdoc'',''matlab_prog'',''matlab_prog.map''),''matlab_calling_syntax'')">explanation of commands and functions</a>'],   fnname, fnname, fnname, fnname);
        end
    end

    %If only want to setup the output, do it and early exit.
    %Currently this is a PC only thing, opens standard Windows Print dialog.
    if setup( pj )
        restorepointers( pj );
        return
    end

    %Sometimes need help tracking down problems...
    if pj.DebugMode
        disp('Debugging in PRINT, PrintJob object is:')
        pj %#ok<NOPRT>
    end

    %  if handled via new path just return from here, otherwise fall through
    [done, result] = alternatePrintPath(pj);
    if done
        restorepointers( pj ); 
        if pj.RGBImage
            varargout(1) = {result};
        end
        return;
    end
    
    %Turning on the printjob structure
    pj.Active = 1;

    % rquist - moved here from above
    % Printing parameters like paper position, paper size etc. needs to be
    % adjusted for ModelDependencyViewer figure.
    LocalAdjustPrintParamsForDepViewer(pj);
    
    %Objects to print have their handles in a cell-array of vectors.
    %Each vector is for one page; all objects in that vector
    %are printed on the same page. The caller must have set their
    %PaperPosition's up so they do not overlap, or do so gracefully.
    numPages = length( pj.Handles );
    for i = 1 : numPages
        %numObjs = length( pj.Handles{i} );
        pj = positions( pj, pj.Handles{i} );
        
        %Only prepare and restore the first object.
        h = pj.Handles{i}(1);
        %Add object to current page
        pj.Error = 0;
        pj.Exception = [];
        %May want to change various properties before printing depending
        %upon input arguments and state of other HG/Simulink properties.
        pj = prepare( pj, h );
        %Call the output driver and render Figure/model to device, file, or clipboard.
        %Save erroring out until we restore the objects.
        try
            if ishghandle(h) && ~localIsPrintHeaderHeaderSpecEmpty(h) && ...
                    (~pj.DriverExport || ...
                     strcmp(pj.DriverClass,'MW'))
                    
                ph=paperfig(h);
                pj=render(pj,ph);
                delete(ph);
            else
                pj = render(pj,pj.Handles{i});
            end
            if ~isempty(pj.Exception) %pj.Error
                rethrow(pj.Exception)
            end
        catch ex
            pj.Error = 1;
            pj.Exception = ex;
        end
        
        %Reset the properties of a Figure/model after printing.
        pj = restore( pj, h );

        if pj.Error
            if ~isempty(pj.Exception)
                throw(pj.Exception);
            else
                throw(MException('MATLAB:print:PrintFailedException','print failed due to an unknown reason'));
            end
        end

        if i < numPages
            %Start a new page for next vector of handles
	    pj.PageNumber = pj.PageNumber + 1;
        end
    end

    %Close connect with printer or file system.
    pj.Active = 0;

    if pj.GhostDriver
        pj = ghostscript( pj );

    elseif strcmp( pj.Driver, 'hpgl' )
        hpgl( pj );
    end

    if pj.PrintOutput
        send( pj );
    end

catch ex
    wasErr = 1;
end

restorepointers( pj );

if wasErr
    throw(ex);
end
%--------------------------------------------------------------------------
function LocalAdjustPrintParamsForDepViewer(pj)
% Special case to handle the Printing parameters for ModelDependencyViewer
% (a tool used to view model/library dependencies for Simulink Models)

if( length(pj.Handles) == 1 && ...
        strcmpi(get(pj.Handles{1},'Tag'),'DAStudio.DepViewer') )

    h = pj.Handles{1};
    set(h,'PaperUnits','points');
    pSize = get(h,'PaperSize');
    pPos = get(h,'PaperPosition');

    paddingMarginPoints = 10; % printing margin in points

    ax = get(h,'CurrentAxes');
    set(ax,'Units','points'); % make sure we are all in points
    axPos = get(ax,'Position');

    % Set the target with and target height and adjust for marigins
    targetWidth = min(pSize(1),pPos(3))-paddingMarginPoints;
    targetHeight = min(pSize(2),pPos(4))-paddingMarginPoints;

    % Get the ratio of width
    widthRatio =  targetWidth/axPos(3);
    heightRatio = targetHeight/axPos(4);

    % Get the minimum of the ratio ...
    minScale = min(widthRatio,heightRatio);

    % .. and apply to the targetWidth and targetHeight
    newWidth = axPos(3)*minScale;
    newHeight = axPos(4)*minScale;

    % Set the new width and height of the axes
    set(ax,'Position',[(targetWidth-newWidth)/2 (targetHeight-newHeight)/2 newWidth-2*paddingMarginPoints newHeight-2*paddingMarginPoints]);

    % Set the paper position of the figure such that there is 10 pixel
    % margin from left and bottom.
    set(h,'PaperPosition',[((pSize(1)-targetWidth)/2) + paddingMarginPoints ((pSize(2)-targetHeight)/2) + paddingMarginPoints ...
        min(pSize(1),pPos(3)) min(pSize(2),pPos(4))]);

    % apply scale to all the texts in the model
    texts = findall(h,'type','text');
    for k = 1:length(texts)
        fontSize = get(texts(k),'FontSize');
        set(texts(k),'FontSize',fontSize*minScale);
    end
end
%--------------------------------------------------------------------------
% This function is needed because the PrintHeaderHeaderSpec may be
% technically empty (string is '' and date is 'none'), but still exist, and
% if it is in this state we do not want to call paperfig and do a copyobj.
% Fix for g408962.
function reallyEmpty = localIsPrintHeaderHeaderSpecEmpty(fig)
    reallyEmpty = false; % assume the headerspec is valid and not completely empty
    hs = getappdata(fig,'PrintHeaderHeaderSpec');
    if isempty(hs) || (~isempty(hs) && strcmp(hs.dateformat,'none') && isempty(hs.string))
        reallyEmpty = true; % either no header spec or it doesn't specify any header
    end
% end of function localCheckHeaderSpec
%--------------------------------------------------------------------------
function fHandle = LocalGetSlSfPrintFcnHandle

cwd = pwd;

try
    cd(fullfile(matlabroot,'toolbox','simulink','simulink','private')); %#ok<*MCCD,MCMLR,MCTBX>
    fHandle = str2func('slsf_print');
    if(~isa(fHandle, 'function_handle'))
        throw(MException('MATLAB:UndefinedFunction',sprintf('Undefined function or variable %s','slsf_print')));
    end
catch me
    cd(cwd);
    rethrow(me);
end

cd(cwd);
    

% [EOF]


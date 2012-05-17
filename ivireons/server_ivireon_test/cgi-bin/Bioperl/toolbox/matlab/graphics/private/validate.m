function pj = validate( pj )
%VALIDATE Method to check state of PrintJob object.
%   Values of PrintJob object class variables are checked for consistency.
%   Errors out if it finds bad combinations. Fills in missing data with
%   defaults.
%
%   Ex:
%      pj = VALIDATE( pj );
%
%   See also PRINT, PRINTOPT, INPUTCHECK.

%   Copyright 1984-2010 The MathWorks, Inc.

pj.Validated = 1;

%If no window requested, and none to act as default, error out.
pj = validateHandleToPrint(pj); 

% for future use
if pj.RGBImage && ~isempty(pj.Driver)
    error('MATLAB:Print:IncompatibleRGBImageOption', ...
        ['The ''-d' pj.Driver ''' option is not supported with ''-RGBImage''.'] );
end

if pj.RGBImage && ~isempty(pj.FileName)
    error('MATLAB:Print:IncompatibleRGBImageOption', ...
        'The ''filename'' option is not supported with ''-RGBImage''.' );
end

if pj.RGBImage && ~isempty(pj.PrinterName)
    error('MATLAB:Print:IncompatibleRGBImageOption', ...
        'The ''-Pprinter'' option is not supported with ''-RGBImage''.' );
end

if pj.PostScriptPreview && ~strcmp(pj.DriverClass,'EP')
    error('MATLAB:Print:ValidateTiffPreviewOnlyWithEPS', 'TIFF previews allowed only with EPS output.' )
end

%If no device given, use default from PRINTOPT
if ~pj.RGBImage && isempty( pj.Driver )
    %Use method to validate default and set related class variables
    wasError = 0;
    try
        pj = inputcheck( pj, pj.DefaultDevice );
        pj.DriverColorSet = 0;
    catch ex  %#ok<NASGU>
        wasError = 1;
    end
    if wasError || isempty( pj.Driver )
      error('MATLAB:Print:ValidateUnknownDeviceType',...
            ['PRINTOPT specifies an unknown device type '''...
                pj.DefaultDevice '''.'])
    end
end

if strcmp(pj.DriverClass, 'MW' ) 
    if isunix
      error('MATLAB:Print:ValidateUseWindowsDriver',...
            ['Can only use Windows driver ''' pj.Driver ''' on a Windows machine.'])
    end
    
    % If user specifies a filename while device is -dwin
    % or -dwinc, either because the user gave that device or, more
    % likely, it's the default, and since the filename is useless
    % with Windows driver anyway, we'll assume the user really wants
    % a PostScript file. This is because 'print foo' is easier
    % to type then 'print -dps foo' and probably more commonly
    % meant if a filename is given. Unless of course the user asked
    % for the Print Dialog with the -v flag, then s/he really meant it.
    if (~isempty(pj.FileName) && ~pj.Verbose ) ...
            && ( strcmp(pj.Driver, 'win') || strcmp(pj.Driver, 'winc') )
        if pj.DriverColor
            pj.Driver = 'psc';
        else
            pj.Driver = 'ps';
        end
        pj.DriverExt = 'ps';
        pj.DriverClass = 'PS';
    end
end

if pj.XTerminalMode && pj.UseOriginalHGPrinting
    % Substitute ghostscript drivers for tiff and png in headless
    % mode and otherwise error
    invalidInEmulationMode = 0;
    if strcmp(pj.DriverClass, 'IM' )
      if strcmp(pj.Driver,'tiff')
        pj.Driver = 'tiff24nc';
        pj.DriverClass = 'GS';
      elseif strcmp(pj.Driver,'png')
        pj.Driver = 'png16m';
        pj.DriverClass = 'GS';
      else
        invalidInEmulationMode = 1;
      end
    elseif strcmp(pj.DriverClass, 'MW')
        if strcmp(pj.Driver, 'meta') || strcmp(pj.Driver, 'bitmap')
            invalidInEmulationMode = 1;
        end
    end
    if invalidInEmulationMode
        error('MATLAB:Print:ValidateTerminalModeNotAllowed',...
              ['Cannot produce ' upper(pj.Driver) ' files in terminal emulation mode.'] )
    end
end

if strcmp( pj.Driver, 'mfile' ) && ~all( ishghandle( [pj.Handles{:} ] ) )
  error('MATLAB:Print:ValidateMFileNotAllowed',...
        'The -dmfile device option cannot be used with Simulink systems.' )
end

if strcmp( pj.Driver, 'mfile' ) && isempty( pj.FileName )
  error('MATLAB:Print:ValidateMissingFileName',...
        'Filename required for saving Figure to M-file.' )
end

if strcmp( pj.Driver, 'mfile' )
    locMakeSafeForDmfile( pj.Handles )
end

%GhostScript produced image formats needs -loose PS files
if ( strcmp(pj.DriverClass, 'GS') && pj.DriverExport )
    pj.PostScriptTightBBox = 0;
end

%TIFF previews imply -loose, historicly because ZBuffer TIFF was always "loose".
if pj.PostScriptPreview == pj.TiffPreview
    pj.PostScriptTightBBox = 0;
    
    %We have to produce a 72dpi EPS file first, have GS convert it to
    %TIFF, and then we combine a second high res EPS and the TIFF together.
    %Already checked above that for TIFF preview we have only one page.
    pj.GhostDriver = 'tiffpack';
    pj.GhostName = [tempname '.tif'];
    pj.PostScriptPreview = pj.TiffPreview;
end

%Fill renderer and -noui from the printtemplate (if it exists) if
%the user didn't specify these options on the command line
h = pj.Handles{1}(1);
if isfigure(h)
  pt = getprinttemplate(h);
  if ~isempty(pt)
	if ~pj.nouiOption
	  pj.PrintUI = pt.PrintUI;
	end
	if ~pj.rendererOption && ~strcmp( pt.Renderer, 'auto' )
	  pj.Renderer = pt.Renderer;
	end
  end
end

% end validate

function locMakeSafeForDmfile( handles )
% if the figure has app data it was likely put there by scribe
% warn the user and turn off scribe before printing

figh = handles{1}(1);
usingAppData = ~ isempty( fieldnames(getappdata(figh)) );
if ( usingAppData )
    % turn off plotedit
    if plotedit(figh,'isactive')
        plotedit(figh, 'off');
    end

    % turn off interactive modes (e.g. zoom, pixval)
    uiclearmode(figh, '');

    % save warning state
    warning('MATLAB:Print:ValidateAnnnotatedPlotsNotFullySupported',...
            'print -dmfile does not fully support annotated plots.  Use hgsave.');
end
% end locMakeSafeForDmfile

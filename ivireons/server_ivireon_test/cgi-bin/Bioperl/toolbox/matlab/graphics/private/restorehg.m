function pj = restorehg( pj, h )
%RESTOREHG Reset a Figure after printing.
%   When printing a Figure, some of its properties have to be changed to 
%   create the desired output. RESTOREHG resets the properties back to 
%   their original values.
%
%   Ex:
%      pj = RESTOREHG( pj, h ); %modifies PrintJob pj and Figure h
%
%   See also PRINT, PRINTOPT, PREPARE, PREPAREHG, RESTORE, RESTOREUI.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.10 $  $Date: 2009/04/21 03:24:44 $

error( nargchk(2,2,nargin,'struct') )

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

if ~isequal(size(h), [1 1]) || ~isfigure( h )
    error('MATLAB:restorehg:InvalidHandle','Need a handle to a Figure object.' )
end

%Early exit, saved Figure as is.
if strcmp(pj.Driver, 'mfile')
    pj.hgdata = [];
    return
end

    
%Get quicker link to saved data
hgdata = pj.hgdata;

% If printing to JPEG or TIFF file, then we need to restore animated
% objects back to their previous erasemode.
% Same if producing TIFF for EPS preview of printed Figure.
if strcmp(pj.DriverClass, 'IM') || ((pj.PostScriptPreview == pj.TiffPreview) && ~pj.GhostImage)
    [prevWarnMsg prevWarnID] = lastwarn;
    noanimateWarn = warning('off', 'MATLAB:noanimate:DeprecatedFunction');
    noanimate('restore',h);
    warning(noanimateWarn);
    lastwarn(prevWarnMsg, prevWarnID);    
end

% Reselect any objects that were selected before we printed the Figure.
noselection('restore',h);

% set color of lines and text back to what they were
if hgdata.Undithered
    nodither('restore', h);
end

% Invert back the toner saving color changes
if (hgdata.Inverted	== 1)
    savtoner('restore', h);
elseif (hgdata.Inverted == 2)
	colornone('restore', h);
end

if ~isempty( pj.Renderer )
    set( h, 'renderer', hgdata.Renderer )
    if hgdata.RendererAutoMode 
        set( h, 'renderermode', 'auto' )
    end
end

%Recover from the funky changes necessary to handle ResizeFcn's.
if ~isempty( hgdata.PixelObjects )
    set( hgdata.PixelObjects, 'units', 'pixels' )
    hgdata.PixelObjects = [];
end
if ~isempty( hgdata.FontPixelObjects )
    set( hgdata.FontPixelObjects, 'fontunits', 'pixels' )
    hgdata.FontPixelObjects = [];
end

%%% Clean up UIControls
if pj.PrintUI
    pj = restoreui( pj, h );
end

if ~isempty( hgdata.ResizeFcn )
    set( h, 'ResizeFcn', hgdata.ResizeFcn  );
end

%Put Figure back to original size if we needed to
%resize Figure to PaperPosition.
if hgdata.ResizedWindow
    set( h, 'units', hgdata.WindowUnits, 'position', hgdata.WindowPos );
end

%Figures can be formatted for output via a PrintTemplate object
if ~isempty( hgdata.PrintTemplate )
    ptrestorehg( hgdata.PrintTemplate, h );
end

% Indicate that we are finished printing.
if isappdata(0,'BusyPrinting')
    rmappdata(0,'BusyPrinting');
end
fireprintbehavior(h,'PostPrintCallback');

if ~hgdata.ResizedWindow && ((hgdata.Inverted || hgdata.Undithered) && ~strcmp(pj.Driver, 'bitmap') ) && ...
      (isempty(pj.UIData) || isempty(pj.UIData.UICHandles) )
  % Call drawnow here to make sure all objects are back to their original
  % states.
  drawnow;
end

% If windows cover up our figure during printing, then the figure will have rendered
% in the wrong (print vs. screen) state unless backingstore is on.  XOR'ed objects 
% never get put into the backingstore and so they will always render incorrectly.
% To fix the figure after one of these cases, we call refresh below.
if strcmp(get(h, 'BackingStore'), 'off') || ~isempty(findall(h, 'EraseMode', 'xor'))
   refresh(h);
end

%Don't need it anymore, get rid of it so next Figure to be printed doesn't use it.
pj.hgdata = [];

function pj = ghostscript( pj )
%GHOSTSCRIPT Function to convert a PostScript file to another format. 
%   Ghostscript is a third-party application supplied with 
%   MATLAB. See the file ghoscript/gs.rights in the MATLAB 
%   installation area for more information on Ghostscript itself. 
%   The PRINT command calls GHOSTSCRIPT when one of the device 
%   drivers listed below is specified as the -d option. 
%
%   These devices use Ghostscript and are supported on all platforms:
%      -dlaserjet - HP LaserJet
%      -dljetplus - HP LaserJet+
%      -dljet2p   - HP LaserJet IIP
%      -dljet3    - HP LaserJet III
%      -dljet4    - HP LaserJet 4,5L and 5P
%      -dpxlmono  - HP LaserJet 5 and 6
%      -ddeskjet  - HP DeskJet and DeskJet Plus
%      -ddjet500  - HP Deskjet 500
%      -dcdjmono  - HP DeskJet 500C printing black only
%      -dpaintjet - HP PaintJet color printer
%      -dpjxl     - HP PaintJet XL color printer
%      -dpjetxl   - HP PaintJet XL color printer
%      -dbj10e    - Canon BubbleJet BJ10e
%      -dbj200    - Canon BubbleJet BJ200
%      -dbjc600   - Canon Color BubbleJet BJC-600 and BJC-4000
%      -dbjc800   - Canon Color BubbleJet BJC-800
%      -depson    - Epson-compatible dot matrix printers (9- or 24-pin)
%      -depsonc   - Epson LQ-2550 and Fujitsu 3400/2400/1200
%      -deps9high - Epson-compatible 9-pin, interleaved lines 
%                      (triple resolution)
%      -dibmpro   - IBM 9-pin Proprinter
%
%   These devices use Ghostscript and are supported on UNIX platforms only:
%      -dcdjcolor - HP DeskJet 500C with 24 bit/pixel color and high-
%                      quality color (Floyd-Steinberg) dithering
%      -dcdj500   - HP DeskJet 500C
%      -dcdj550   - HP Deskjet 550C
%      -dpjxl300  - HP PaintJet XL300 color printer
%      -ddnj650c  - HP DesignJet 650C
%
%   The following formats will always result in a file being left on disk
%   because they are image formats. If no name is given to the PRINT command
%   a default name will be used and echoed to the command line.
%      -dbmpmono  - Monochrome .BMP file format
%      -dbmp256   - 8-bit (256-color) .BMP file format
%      -dbmp16m   - 24-bit .BMP file format
%      -dpcxmono  - Monochrome PCX file format
%      -dpcx16    - Older color PCX file format (EGA/VGA, 16-color)
%      -dpcx256   - Newer color PCX file format (256-color)
%      -dpcx24b   - 24-bit color PCX file format, 3 8-bit planes
%      -dpbm      - Portable Bitmap (plain format)
%      -dpbmraw   - Portable Bitmap (raw format)
%      -dpgm      - Portable Graymap (plain format)
%      -dpgmraw   - Portable Graymap (raw format)
%      -dppm      - Portable Pixmap (plain format)
%      -dppmraw   - Portable Pixmap (raw format)
%      -dpdf      - Color PDF file format

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.15.4.13 $  $Date: 2008/11/04 21:19:58 $ 
error(nargchk(1,1,nargin, 'struct') )

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

rsp_file = [tempname '.rsp'];
rsp_fid = fopen (rsp_file, 'w');

if (rsp_fid < 0)
    error('print:ghostscript', 'Unable to create response file')
end

% the path to ghostdir needs to change for new gs version
ghostDir = fullfile( matlabroot, 'sys', 'gs8x' );



if ~exist(ghostDir, 'dir')
    error('print:ghostscript', ...
          'Can not find the directory for Ghostscript in %s', matlabroot)
end

fprintf(rsp_fid, '-dNOPAUSE -q \n');
fprintf(rsp_fid, '-I"%s"\n', fullfile( ghostDir, 'ps_files', ''));
fprintf(rsp_fid, '-I"%s"\n', fullfile( ghostDir, 'fonts', ''));

% if the device is jpegNN (where NN is a numeric 'quality' setting
% strip off the NN and pass device into ghostscript as 'jpeg'
% then pass a separate -dJPEGQ=NN flag to ghostscript to specify quality
if length(pj.GhostDriver) > 4 && strncmp( pj.GhostDriver, 'jpeg', 4 )
    if isempty( str2num(pj.GhostDriver(5:end)) ) 
        error( 'MATLAB:Print:jpegQlvl', 'JPEG quality level in device name must be numeric and between 0 and 100, inclusive.' );
    end
    qual = str2num(pj.GhostDriver(5:end));
    if (qual < 0 || qual > 100)
        error( 'MATLAB:Print:jpegQlvl', 'JPEG quality level in device name must be numeric and between 0 and 100, inclusive.' );
    end

    fprintf(rsp_fid, '-sDEVICE=%s\n', pj.GhostDriver(1:4));
    fprintf(rsp_fid, '-dJPEGQ=%s\n', pj.GhostDriver(5:end));
else
  fprintf(rsp_fid, '-sDEVICE=%s\n', pj.GhostDriver);
end


%If saving as a picture, not a printer format, crop the image,
%unless we are using PDF which needs a paper size.
if pj.GhostImage && ~strncmp(pj.GhostDriver,'pdf',3)
    fprintf(rsp_fid, '-g%.fx%.f\n', pj.GhostExtent(1), pj.GhostExtent(2) );

else    
    %If not the default of letter/Ansi A, set the name Ghostscript wants
    %First object is 'master' object. What to do if the others are not the same?
     
     % nvillanu (4/19/2005): this handles the custom papersizes when print
     % format is PDF.  with this code we won't be prompted with the error
     % 'Problem calling GhostScript. System returned error', when we have a
     % custom papersize (i.e 3x5, 5x6, etc).
     % g252763
     gsName = getget( pj.Handles{1}(1), 'papertype' );
     if ~( strcmp(gsName,'usletter') || strcmp(gsName,'A') || strcmp(gsName,'<custom>') )
         switch gsName
         case 'uslegal',  gsName = 'legal';
         case 'a4letter', gsName = 'a4';
         case 'tabloid',  gsName = '11x17';
         case 'arch-A',   gsName = 'archA';
         case 'arch-B',   gsName = 'archB';
         case 'arch-C',   gsName = 'archC';
         case 'arch-D',   gsName = 'archD';
         case 'arch-E',   gsName = 'archE';
         case 'B',        gsName = '11x17';
         case 'C',        gsName = 'archC'; %following ANSI sizes not supported
         case 'D',        gsName = 'archD';
         case 'E',        gsName = 'archE';
         % nvillanu (8/2/2005): fix for g274764.
         otherwise
         % PaperType is already the correct name.
             gsName = lower( gsName );
         end
         fprintf( rsp_fid, '-sPAPERSIZE=%s\n', gsName );
     elseif strcmp(gsName,'<custom>')
     % we have got a custom page setup sizes properly
       pagesize = getget( pj.Handles{1}(1), 'papersize' );
       pageunits = getget( pj.Handles{1}(1), 'paperunits' );
       switch pageunits
       case 'centimeters' , pagesize = round(pagesize ./ 2.54 * 72);
       case 'inches' , pagesize = round(pagesize * 72);
       % clean up before erroring out, otherwise we'll get drools!
       case 'normalized' , 
          fclose(rsp_fid); 
          delete(rsp_file);  
          delete(pj.FileName);
          error('MATLAB:ghostscript:normCustom', 'custom paper size not supported for normalized paperunits');
       end;
       fprintf( rsp_fid, '-dDEVICEWIDTHPOINTS=%.0i\n-dDEVICEHEIGHTPOINTS=%.0i\n-dFIXEDMEDIA\n', pagesize );
     end
end

%If using GS to produce a TIFF image for an EPS preview.
if pj.PostScriptPreview == pj.TiffPreview 
    res = get(0,'screenpixelsperinch');
    fprintf( rsp_fid, ['-r' int2str(res) 'x' int2str(res) '\n'] );
end

fprintf(rsp_fid, '-sOutputFile="%s"\n', pj.GhostName );
fclose(rsp_fid);
if pj.DebugMode
    disp( ['PRINT debugging: call gscript with: ' rsp_file ' and ' pj.FileName] )
end 
s = 0;
r = '';

% run ghostscript to convert the file
[s, r] = gscript(['@' rsp_file], pj.FileName, pj.DebugMode );

if pj.DebugMode
    disp( ['PRINT debugging: GHOSTSCRIPT converting PS file = ''' pj.FileName '''.'] )
    disp( ['PRINT debugging: GHOSTSCRIPT response file = ''' rsp_file ''':'] )
    eval( ['type ' rsp_file] )
    disp( ['Ghostscript STDOUT: ' num2str(s) ] );
    disp( ['Ghostscript STDERR: ' r ] );
else
    delete(rsp_file)
    delete(pj.FileName)    
end

if s && ~isempty(r)
  error('print:ghostscript',  ['Problem converting PostScript. System returned error: ' num2str(s) '.' r]) 
elseif s
    error('print:ghostscript',  ['Problem calling GhostScript. System returned error: ' num2str(s)]) 
end

%Ghostscript doesn't return an error if couldn't create file
%because of write protection. See if file was created.
fid = fopen( pj.GhostName, 'r');
if ( fid == -1 )
    error('print:ghostscript', '%s', [ 'Ghostscript could not create ''' pj.GhostName '''.' ])
else
    fclose( fid );
end

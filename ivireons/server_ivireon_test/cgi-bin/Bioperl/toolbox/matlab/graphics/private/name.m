function pj = name( pj )
%NAME Method to check or create valid filename.
%   Validate FileName in PrintJob object. If empty, no name passed to PRINT 
%   command, but one is required by the driver, image file formats, we invent 
%   a name and tell the user what it is. Also invent name, but do not tell 
%   user, for temporary PS file created on disk when printing directly 
%   to output device or for GhostScript conversion.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.8.4.11 $

%Generate a name we would use if had to in various circumstances.
if isfigure( pj.Handles{1}(1) )
    objName = ['figure' int2str( double(pj.Handles{1}(1) ))];
else
    objName = get_param(pj.Handles{1}(1),'name');
end

tellUserFilename = 0;
if isempty(pj.FileName)
    if pj.DriverExport && ... 
            ~strcmp(pj.DriverClass,'MW') && ~pj.DriverClipboard && ~pj.RGBImage
        %These kinds of files shouldn't go to printer, generate file on disk
        pj.FileName = objName;
        tellUserFilename = 1;
        
    else
        %File is going to be sent to an output device by OS or us.
        if ~strcmp(pj.DriverClass,'MW') && ~pj.DriverClipboard && ~pj.RGBImage
            %Going to a file, invent a name
            pj.FileName = tempname;
            pj.PrintOutput = 1;
        end
    end
else
	%Both / and \ are commonly used, but in MATLAB we recognize only filesep
	pj.FileName = strrep( pj.FileName, '/', filesep );
	pj.FileName = strrep( pj.FileName, '\', filesep );        
end

%Append appropriate extension to filename if 
% 1) it doesn't have one, and 
% 2) we've determined a good one
if ~isempty( pj.DriverExt ) && ~isempty( pj.FileName )
    %Could assert that ~isempty( pj.FileName )
    [p,n,e] = fileparts( pj.FileName );
    if isempty( e )
        pj.FileName = fullfile( p, [n '.' pj.DriverExt] );
    end
end

% on unix fix the file spec if it starts with '~/' so we look at the user's home dir
if (isunix)
    pj.FileName = fixTilde(pj.FileName);
end

if tellUserFilename
    %Invented name above because of device or bad filename
    if tellUserFilename == 1
        errStr1 = sprintf( 'Files produced by the ''%s'' driver cannot be sent to printer.\n', pj.Driver);
    else
        errStr1 = '';
    end
    
    warning('MATLAB:Print:SavingToDifferentName',...
            '%sFile saved to disk under name ''%s''.', errStr1, pj.FileName ) 
end

% Check that we can write to the output file
if ~isempty(pj.FileName)
  [fpath,fname,ext] = fileparts(pj.FileName);
  if isempty(fpath)
    fpath = '.';
  end
  pj.FileName = fullfile(fpath,[fname ext]);
  % first check if readable file already exists there
  fidread = fopen(pj.FileName,'r');
  didnotexist = (fidread == -1);
  if ~didnotexist
    fclose(fidread);
  end
  % now check if file is appendable (will create file if not there)
  fidappend = fopen(pj.FileName,'a');
  if fidappend ~= -1
    fclose(fidappend);
    % check if we have to delete the created file
    if didnotexist
      % @todo Replace This once we have a flag on delete 
      % for disabling the recycle.
      ov=recycle('off');
      delete(pj.FileName);
      recycle(ov);
    end
  else
    error('MATLAB:Print:CannotCreateOutputFile',...
          'Cannot create output file ''%s''', pj.FileName);
  end
end

%A little business to clear up.
%Now that we found good extension and all that for GS driver,
%we swap in a PS driver and temporary name for later conversion
%to a file whose name we just prettied up.
if strcmp( pj.DriverClass, 'GS' )
    %Remember actual device, get MATLAB to produce PostScript
    %for later conversion by GhostScript
    pj.GhostDriver = pj.Driver;
    if pj.DriverColor
        pj.Driver = 'psc';
    else
        pj.Driver = 'ps';
    end
    pj.GhostName = pj.FileName;
    pj.FileName = [tempname '.ps'];
end

% function to replace, on unix, a leading tilde (~) 
% of a directory specification in a file name (ie. '~/test.pdf'
% with the name/path of the user's  home directory 
% (to get something like '/home/user/test.pdf')
%
% This is done, in part, to work around problem with Ghostscript not
% supporting a filename with the tilde (ie. '~/test.pdf')
function filename = fixTilde(fileName)
persistent homeDir; % keep track of user's home dir
filename = fileName;
% yes, we tested for isunix above...but in case that test gets deleted
if (isunix && (length(fileName) > 1)) 
    if (fileName(1) == '~' && fileName(2) == filesep)
        if isempty(homeDir)
            % save current location, 
            % go 'home' and remember that location
            % switch back to original location
            currDir = pwd;
            cd('~');
            homeDir = pwd;
            cd(currDir);
        end
        if ~isempty(homeDir)
            % now that we know where the home dir is
            % replace 1st char (~) with user's home dir and take rest of
            % path specified
            filename = [homeDir fileName(2:end)];
       end
    end
end


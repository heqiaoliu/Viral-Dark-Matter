function v = CUDADriverVersion
%CUDADriverVersion - return a description of the NVIDIA CUDA driver version
%   V = parallel.internal.gpu.CUDADriverVersion returns a string description
%   of the NVIDIA CUDA driver version.

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.10.1 $   $Date: 2010/07/23 15:35:48 $

% The implementation is completely different for each platform.
if ispc
    v = iPcDriverVersion();
elseif ismac
    v = iMacDriverVersion();
elseif isequal( computer, 'GLNXA64' ) || ...
        isequal( computer, 'GLNX86' )
    v = iLinuxDriverVersion();
else
    error( 'parallel:gpu:CUDADriverVersion:UnknownComputer', ...
           'Could not calculate driver version for computer type %s.', ...
           computer );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The PC version operates by extracting information from the nvcuda.dll file
% itself using Windows APIs.
function verstr = iPcDriverVersion()

% Extract the location of nvcuda.dll
DRIVER_NAME = 'nvcuda.dll';

% Get the absolute path to nvcuda.dll
cmd = sprintf( 'cmd /c for %%I in (%s) do @echo %%~f$PATH:I', DRIVER_NAME );
[s,w] = system( cmd );
driverFullFname = strtrim( w );
if s || ~exist( driverFullFname, 'file' )
    error( 'parallel:gpu:CUDADriverVersion:NoDriver', ...
           'Could not find the CUDA driver named "%s".', DRIVER_NAME );
end

% Use Scripting.FileSystemObject to get the version info in the form x.y.z.q.
fsobj     = actxserver( 'Scripting.FileSystemObject' );
verstr    = fsobj.GetFileVersion( driverFullFname );
verpieces = regexp( verstr, '([0-9]+)', 'match' );

% Reformat the z.q piece as per NVIDIA's recommendation - otherwise return
% simply the string we were given.
if length( verpieces ) == 4
    piece3 = str2double( verpieces{3} );
    piece4 = str2double( verpieces{4} );
    verstr = sprintf( '%s (%.2f)', verstr, ...
                      ( ( (piece3 - 10) * 10000 ) + piece4 ) / 100 );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Mac version reads an Info.plist file to find the version information
function verstr = iMacDriverVersion()
VERSION_PINFO    = '/System/Library/Extensions/NVDAResman.kext/Contents/Info.plist';
xmldoc           = xmlread( VERSION_PINFO );
dicts            = xmldoc.getElementsByTagName( 'dict' );
dict             = dicts.item(0);
entries          = dict.getChildNodes();
nextValIsVersion = false;
verstr           = '';

for ii = 0:entries.getLength() - 1
    entry = entries.item(ii);
    if entry.getNodeType == entry.ELEMENT_NODE
        if isequal( char(entry.getNodeName), 'key' )
            if isequal( char(entry.getFirstChild.getData), ...
                        'CFBundleGetInfoString' )
                nextValIsVersion = true;
            end
        end
        if isequal( char(entry.getNodeName), 'string' ) && nextValIsVersion
            verstr = char(entry.getFirstChild.getData);
            break;
        end
    end 
end

verstr = regexp( verstr, '(?<=\()[0-9a-z\.]+', 'match' );

if length( verstr ) ~= 1 || ~iscell( verstr )
    error( 'parallel:gpu:CUDADriverVersion:XMLReadFailed', ...
           'Could not read version information from "%s".', VERSION_PINFO );
else
    verstr = verstr{1};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Linux version reads a version information file under /proc.
function verstr = iLinuxDriverVersion()

VERSION_FILE = '/proc/driver/nvidia/version';
fh           = fopen( VERSION_FILE, 'rt' );

if fh == -1
    error( 'parallel:gpu:CUDADriverVersion:NoVersionFile', ...
           'Could not read version information from "%s".', VERSION_FILE );
end
cleanup = onCleanup( @() fclose(fh) );
    
% Read the file, look for line with NVIDIA info (there is other info)
tline = fgetl( fh );
while ischar( tline )
    match = regexp( tline, '(?<=NVRM.*Kernel Module\s*)([0-9\.]+)', 'match' );
    if length( match ) == 1;
        verstr = match{1};
        return;
    end
    tline = fgetl( fh );
end

% Fell through - couldn't parse the file.
error( 'parallel:gpu:CUDADriverVersion:InvalidVersionFile', ...
       'Could not extract version information from "%s".', VERSION_FILE );
end

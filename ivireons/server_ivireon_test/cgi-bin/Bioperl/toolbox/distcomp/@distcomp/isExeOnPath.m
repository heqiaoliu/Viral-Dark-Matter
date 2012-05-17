function onPath = isExeOnPath( baseName )
; %#ok Undocumented

% Checks to see if a given program is on the executable PATH. On Windows,
% this will append extensions ".exe", ".bat" and ".cmd" and check those too.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:49:50 $

exePath = strread( getenv( 'PATH' ), '%s', 'delimiter', pathsep );

onPath = any( cellfun( @(x)( iExeHere( fullfile( x, baseName ) ) ), exePath ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iExeHere - is there an executable file at this location? Handles PC
% executable extensionss
function isHere = iExeHere( nameNoExt )

if ispc
    % On PC, handle the case where the input argument already specifies .exe or
    % whatever, and also append known likely executable extensions
    trail = {'', '.exe', '.bat', '.cmd', '.com'};
else
    trail = {''};
end

isHere = any( cellfun( @(x)( exist( [nameNoExt, x], 'file' ) ), trail ) == 2 );
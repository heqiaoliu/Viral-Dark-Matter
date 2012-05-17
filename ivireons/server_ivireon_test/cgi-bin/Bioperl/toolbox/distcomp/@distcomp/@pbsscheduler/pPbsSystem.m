function [FAILED, out] = pPbsSystem( pbs, cmd ) %#ok<INUSL>
; %#ok Undocumented

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/08/26 18:13:35 $

% Many PBS commands on unix return exit codes > 128, which causes MATLAB's
% system() command to report this as a signal. This is not the case, so to
% work around this, simply wrap all system calls on UNIX within a wrapper
% script which sanitises the exit codes.

persistent wrapper

if isunix
    if isempty( wrapper )
        wrapper = fullfile( toolboxdir('distcomp'), ...
                            'bin', 'util', 'shellWrapper.sh' );
    end
    cmd = [wrapper, ' ', cmd];
end

[FAILED, out] = dctSystem( cmd );

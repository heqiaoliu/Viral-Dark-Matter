function helpDir = docroot(new_docroot)
%DOCROOT A utility to get or set the root directory of MATLAB Help
%   DOCROOT returns the current docroot.
%   DOCROOT(NEW_DOCROOT) sets the docroot to the new docroot, whether or
%   not the new docroot is a valid directory.  A warning is printed out if
%   the directory appears to be invalid.
%
%   The documentation root directory is set by default to be
%   MATLABROOT/help.  This value should not need to be changed, since
%   documentation in other locations may not be compatible with the running
%   version. However, if documentation from another location is desired,
%   docroot can be changed by calling this function to set the value to
%   another directory. This value is not saved in between sessions.  To set
%   this value every time MATLAB is run, a call to docroot can be inserted
%   into startup.m.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $  $Date: 2009/09/28 20:25:35 $

% If at least one argument is passed in, set user docpath
if nargin > 0
    if (usejava('jvm') == 1)
        % remove trailing directory separator
        if (~isempty(new_docroot) && new_docroot(end)==filesep)
            new_docroot = new_docroot(1:end-1);
        end
        if ~com.mathworks.mlservices.MLHelpServices.setDocRoot(new_docroot)
            % warn the user that docroot doesn't look like a valid docroot
            warning('MATLAB:docroot:InvalidDirectoryNotSet', 'directory does not appear to be a valid docroot.');
        end
        helpDir = new_docroot;
    else
        helpDir = fullfile(matlabroot,'help','');
        disp('Changing docroot is not supported in this configuration.');
    end
    return;
end

% Get the docroot.
if usejava('jvm')
    helpDir = strrep(char(com.mathworks.mlservices.MLHelpServices.getDocRoot), '/', filesep);
else
    helpDir = fullfile(matlabroot,'help','');
end



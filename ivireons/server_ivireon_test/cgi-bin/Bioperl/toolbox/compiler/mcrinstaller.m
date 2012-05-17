function [installer,major,minor,update,platform,list]=mcrinstaller
%MCRINSTALLER Display version and location of available MCR Installers
%
%   This function displays version and location information for the MCR
%   installer corresponding to the current platform. 
%
%   [INSTALLER, MAJOR, MINOR, UPDATE, PLATFORM, LIST] = mcrinstaller;
%
%   INSTALLER: The full path to the installer for the current platform.
%   MAJOR: The major version number of the installer.
%   MINOR: The minor version number of the installer.
%   UPDATE: The update version number of the installer.
%   PLATFORM: The name of the current platform, all uppercase. (The value 
%             returned by UPPER(COMPUTER('arch'))).
%   LIST: A cell array of strings containing the full paths to MCR installers
%         for other platforms. This list is non-empty only in a multi-platform
%         MATLAB installation.
%
%   You must distribute the MATLAB Compiler Runtime library to your end 
%   users to enable them to run applications developed with the 
%   MATLAB Compiler.
% 
%   Prebuilt MCR installers for all your licensed platforms ship with the 
%   MATLAB Compiler. 
%
%   Run the DOC command and search for 'MCR Installer' for complete 
%   instructions.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2010/05/20 02:06:04 $

% Locate the MCR installer on this machine
[installer, platform, deploy] = findmcrinstaller;
[major, minor, update] = mcrversion;

if (update==0)
    updateString = '';
else
    updateString = ['.' num2str(update)];
end
versionString = [ num2str(major) '.' num2str(minor) updateString];
msg = sprintf(['The %s MCR Installer, version %s, is:\n' ...
               '    %s\n'], platform, versionString, installer);

disp(msg);

msg = sprintf(['MCR installers for other platforms are located in:\n' ...
               '    %s\n  <ARCH> is the value of COMPUTER(''arch'')' ...
               ' on the target machine.\n'], fullfile(deploy, '<ARCH>'));
disp(msg);
list=listmcrinstallers(deploy);
if ~isempty(list)
    disp('Full list of available MCR installers:');
    for k=1:numel(list)
        disp(list{k});
    end
    disp(' ');
end


url = 'http://www.mathworks.com/access/helpdesk/help/toolbox/compiler/f12-999353.html';
local_url = ['jar:file:///' docroot '/toolbox/compiler/help.jar!/f12-999353.html'];

if (isempty(javachk('jvm')) && desktop('-inuse'))
    url = ['<a href="' url '">online documentation</a>'];
    local_url = ['read your local <a href="' local_url '">MCR Installer help</a>'];
else
    url = ['online documentation (' url ')'];
    local_url = 'run DOC and search for ''MCR Installer''';
end

msg = sprintf('For more information, %s.', local_url);
disp(msg);
msg = sprintf('Or see the %s at The MathWorks'' web site. (Page may load slowly.)', url);

disp(msg);

function [installer platform deployDir] = findmcrinstaller
% FINDMCRINSTALLER Return a string containing the location of the MCR installer
    platform = computer('arch');
    deployDir = fullfile(matlabroot, 'toolbox', 'compiler', 'deploy');
    platformDir = fullfile(deployDir, platform);
    platform = upper(platform);
    if ispc
        installer = fullfile(platformDir, 'MCRInstaller.exe');
    elseif ismac
        installer = fullfile(platformDir, 'MCRInstaller.dmg');
    else
	installer = fullfile(platformDir, 'MCRInstaller.bin');
    end

function list=listmcrinstallers(deploy)
% LISTMCRINSTALLERS List the available MCR Installers (exclude cur. platform)

list = {};

d = dir(deploy);
for k=1:length(d)
    if (strcmp(d(k).name, '.') || strcmp(d(k).name, '..'))
        continue;
    end
    if (d(k).isdir == true)
    % Look for MCRInstaller.
	mcrinstaller = fullfile(deploy, d(k).name, 'MCRInstaller.*');
        f = dir(mcrinstaller);
        if (~isempty(f))
     	    list{end+1} = fullfile(deploy, d(k).name, f(1).name);
        end
    end
end

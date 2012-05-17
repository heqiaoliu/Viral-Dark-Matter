function root=ctfroot
%CTFROOT Returns the root of the application in deployed mode.
%    ROOT = CTFROOT returns the string that is the name of the directory
%    where the CTF file for the deployed application is exploded.
%
%    Use this function to determine the directory where the CTF
%    archive is extracted by the deployed application. In MATLAB
%    environment, this function will return MATLABROOT. To determine the 
%    base directory of any toolbox, use TOOLBOXDIR.
%
%    See also MCC, MBUILD, ISDEPLOYED, MATLABROOT, TOOLBOXDIR.

% Copyright 1984-2006 The MathWorks, Inc.

allroots = which(mfilename, '-all');
pathstr = fullfile('toolbox','compiler');
for i=1:length(allroots)
    root=fileparts(allroots{i});
    root=root(1:strfind(root, pathstr)-2);
    if(length(root) > 0) break;
    end
end
if(length(root) < 0)
    error('MATLAB:Compiler:UndefinedCTFRootFunction',...
        ['CTRFOOT.M undefined in ', ...
        fullfile('toolbox','compiler')]);
end
function dirName = scdpathdep_setup 
% SCDPATHDEP_SETUP  function to copy the referenced library to a temporary
% directory
%
 
% Author(s): Erman Korkut 29-Sep-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:45:57 $

%Disable path warnings
warning('off','MATLAB:dispatcher:pathWarning');

dirName = tempname;
if ~exist(dirName,'dir')
   parentDir = tempdir;
   mkdir(parentDir,dirName(length(parentDir+1):end))
end

%Read existing file
srcFile = fullfile(matlabroot,'toolbox','slcontrol','slctrldemos','html_extra','scdpathdep','scdpathdep_plantslib.mdl');
fID = fopen(srcFile,'r');
content = fread(fID);
fclose(fID);

%Write temp file
dstFile = strcat(dirName,[filesep,'scdpathdep_plantslib.mdl']);
fID = fopen(dstFile,'w+');
fwrite(fID,content);
fclose(fID);
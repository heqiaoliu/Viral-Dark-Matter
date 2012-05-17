function diff2asv(filename)
%DIFF2ASV  Compare file to autosaved version if it exists
%   DIFF2ASV(filename)
%
%   See also VISDIFF.

% Copyright 1984-2009 The MathWorks, Inc.

fullfilename = which(filename);
[pt,fn,xt] = fileparts(fullfilename);

asvFilename = com.mathworks.mde.autosave.AutoSaveUtils.getAutoSaveFilename( ...
    pt,[fn xt]);

asvFilename = char(asvFilename);

if isempty(asvFilename)
    sprintf('Autosave is not enabled\n');
else
    asvPath = fileparts(asvFilename);
end

d = dir(asvFilename);
if ~isempty(d)
    visdiff(asvFilename,fullfilename)
else
    sprintf('File %s is not in autosave directory %s\n',fn,asvPath)
end

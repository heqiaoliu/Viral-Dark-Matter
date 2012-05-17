function filter = loadFilter(fileName)

% Copyright 2009-2010 The MathWorks, Inc.
currFile = getFile(fileName);
if ~isempty(currFile)
    if exist(fileName, 'file') == 0
        postApply(this);
    else
        covfilterName = 'coverageFilterRules';
        
        var =  load(fileName, '-mat');
        if ~isempty(strmatch(covfilterName , fieldnames(var), 'exact'))
            %only one rule can be handeled by this editor
            filter = var.(covfilterName){1};
        end
     end
end
%==================
function currFile = getFile(val)
currFile = '';

if ~isempty(val)
    val = which(val);
    [ currDir, currFile, ext]  = fileparts(val);
    if ~isempty(currDir)
        addpath(currDir);
    end
    currFile =  [currFile ext];

end


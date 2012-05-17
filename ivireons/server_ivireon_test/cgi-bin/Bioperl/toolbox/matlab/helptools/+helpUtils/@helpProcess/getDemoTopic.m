function demoTopic = getDemoTopic(hp)
    demoTopic = '';
    [path, name] = fileparts(hp.fullTopic);
    if ~isempty(dir(fullfile(path, 'html', [name '.html'])))
        [path, demoTopic] = fileparts(hp.fullTopic);
        while ~strcmp(hp.fullTopic, which(demoTopic))
            [path, demoDir] = fileparts(path);
            demoTopic = [demoDir, '/', demoTopic]; %#ok<AGROW>
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/14 14:54:12 $

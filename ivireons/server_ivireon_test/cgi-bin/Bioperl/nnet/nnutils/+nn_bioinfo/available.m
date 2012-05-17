function flag = available()
%AVAILABLE True if Bioinformatics Toolbox is installed and licensed

% Copyright 2010 The MathWorks, Inc.

flag = ~isempty(ver('bioinfo')) && license('test','bioinfo');

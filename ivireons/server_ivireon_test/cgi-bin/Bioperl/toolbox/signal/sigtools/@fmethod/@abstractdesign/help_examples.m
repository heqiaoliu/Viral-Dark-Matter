function help_examples(this)
%HELP_EXAMPLES   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:37:06 $

example_strs = getexamples(this);

for indx = 1:length(example_strs)
    disp(sprintf('    %% Example #%d - %s', indx, example_strs{indx}{1}));
    for jndx = 2:length(example_strs{indx})
        disp(sprintf('       %s', example_strs{indx}{jndx}));
    end
    disp(' ');
end

% [EOF]

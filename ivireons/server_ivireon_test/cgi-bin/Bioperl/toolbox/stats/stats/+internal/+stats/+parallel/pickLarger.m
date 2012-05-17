function val = pickLarger(val, update)
%PICKLARGER is an argmax reduction operator.
%
%   PICKLARGER is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

if update{1} > val{1}
    val = update;
    return;
end
if update{1} == val{1}
    if update{2} < val{2}
        val = update;
    end
end


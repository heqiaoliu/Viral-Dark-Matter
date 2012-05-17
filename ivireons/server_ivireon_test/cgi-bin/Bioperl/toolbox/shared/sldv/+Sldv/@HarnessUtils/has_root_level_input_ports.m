function status = has_root_level_input_ports(modelH)

%   Copyright 2009 The MathWorks, Inc.

    status = ~isempty(find_system(modelH,'SearchDepth',1,'BlockType','Inport'));
end     
function flag = nn_is_binary_ext(ext)

% Copyright 2010 The MathWorks, Inc.

flag = ~isempty(strmatch(ext,{'mat','png','enc'},'exact'));

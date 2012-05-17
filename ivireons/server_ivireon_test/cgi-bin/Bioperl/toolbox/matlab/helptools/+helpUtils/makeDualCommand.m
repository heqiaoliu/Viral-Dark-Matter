function dualCommand = makeDualCommand(command, arg)
    if ~isempty(regexp(arg, '^\(|[ '',;\n-\r]', 'once'))
        arg = mat2str(arg);
        dualCommand = sprintf('%s(%s)', command, arg);
    else
        dualCommand = [command ' ' arg];
    end

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/11/16 22:26:33 $

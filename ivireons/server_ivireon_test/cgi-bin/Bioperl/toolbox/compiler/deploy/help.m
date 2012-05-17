function help(varargin)
% Copyright 2005 The MathWorks, Inc.

msg = '';
if nargin == 1 && ~isempty(varargin{1})
    msg = sprintf('Help for topic ''%s'' unavailable.', varargin{1});
end

warning('Compiler:NoHelp', ...
        sprintf([...
            'The HELP function cannot be used in compiled applications.' ...
            ' For help please visit the MathWorks web site at ' ...
            'www.mathworks.com.\n\n%s'], msg));



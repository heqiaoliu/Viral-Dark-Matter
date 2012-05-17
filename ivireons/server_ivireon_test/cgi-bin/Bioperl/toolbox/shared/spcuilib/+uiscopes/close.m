function close(arg, varargin)
%CLOSE    Close any or all specified scope GUI instances.
%   CLOSE closes the current scope instance.
%
%   CLOSE('all') closes all scope instances.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:07:43 $

if nargin<1
    m = uiscopes.find(0);  % current instance
else
    if ~strcmpi(arg,'all')
        error(generatemsgid('InvalidArgs'),...
              'Argument must be ''all''.');
    end
    m = uiscopes.find(varargin{:});  % all instances
end

if isempty(varargin)
    % If the ScopeCfg object wasn't passed in, execute the default behavior
    % of close which is to delete the Framework UI.
    if ~isempty(m)
        close(m);
    end
else
    % Get the closefcn callback for the application and evaluate it. This makes
    % the 'close all' behavior the same as the close behavior defined for a
    % configuration. For example: System scope objects hide the scope instead
    % of deleting them.
    for i = 1:length(m) 
        closeFcn = getCloseRequestFcn(m(i).ScopeCfg,m(i));
        feval(closeFcn, m(i));
    end
end

% [EOF]

function processAll(this)
%processAll Process extension configuration enable states.
%   processAll(hDriver) reacts to the enable-state of each extension
%   configuration in the config database, including property merging and
%   extension instantiation.
%
%   This is a manual-scan of enable states across the current configuration
%   database.
%
%   Note that we might attempt to enable an extension that fails to execute
%   properly, and corrective actions include disabling it and posting a
%   message.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.8 $ $Date: 2008/03/17 22:38:27 $

% Sort configurations by registration order and dependencies
%
sortConfigDb(this);

% Check for violations in overall config set
% process() below will not generally check overall config violations
% It only checks config if an extension must be disabled due to an error
errorIfConstraintViolation(this);

checkDependencyViolation(this);

% Visit each config in the database and process it individually.  Postpone
% rendering until we have every extension loaded.  Process disabled first
% so they are removed before adding new extensions.
hDisabled = findChild(this.ConfigDb, 'Enable', false);
for indx = 1:length(hDisabled)
    process(this, hDisabled(indx), false);
end
hEnabled = findChild(this.ConfigDb, 'Enable', true);
for indx = 1:length(hEnabled)
    process(this, hEnabled(indx), false);
end

% Render the GUI.  Extensions may have added information to UIMgr and we
% have suppressed all rendering by passing process the false argument.
hGUI = getGUI(this.Application);
if ~isempty(hGUI) && isRendered(hGUI)
    render(hGUI);
end

%% ------------------------------------------------------------------------
function sortConfigDb(this)
%sortCfgs Sort configurations by registration order and dependencies.
%   Sort configurations by registration type-order and extension order,
%   provided by extensions during registration.  Also sort according to
%   dependency, issuing messages if there are failures.

hRegisterDb = this.RegisterDb;
sortedTypeNames = hRegisterDb.SortedTypeNames;

% Get all Config separated according to sorted type names
%
% c{indx} contains a vector of Register of the same type name
% typeNames{indx} indicates the type name of the group
hConfigDb = this.ConfigDb;
N = numel(sortedTypeNames);
c = cell(1,N);
for indx=1:N
    c{indx} = findConfig(hConfigDb,sortedTypeNames{indx});
end

% Silently disconnect all children so we can reconnect
% in new order
%
remove(hConfigDb);

% Reorder extensions within each type, according to individual extension
% order, then re-connect extensions in new order
%
for indx=1:N
    ci = c{indx}; % get all Config's in next type-group
    
    % get vector of registration order info
    o = local_getRegOrder(this,ci);
    
    % Sort/reorder configs:
    [temp,ext_sort_order] = sort(o);
    ci=ci(ext_sort_order); % reorder Config's in this type-group
    c{indx}=ci(:)';
end

c = [c{:}];

% xxx Make sure that extensions that rely on other extensions are at the
% end, so that when we enable them, their dependent extensions are enabled.
% This algorithm needs some work, it won't be reliable for multiple
% dependencies, or "dependency chains".
indx = 1;
nMoved = 0;
while indx < length(c) - nMoved
    hRegister = findRegister(this.RegisterDb, c(indx).Type, c(indx).Name);
    if isempty(hRegister.Depends)
        
        % If there are no dependencies, move to the next config.
        indx = indx+1;
    else
        
        % If we find a dependency, just move it to the end, so it gets
        % added last.
        c = [c(1:indx-1) c(indx+1:end) c(indx)];
        nMoved = nMoved + 1;
    end
end

% Add each Config back to ConfigDb, now in the right order
for indx = 1:numel(c)
    connect(c(indx), hConfigDb, 'up');
end


%% ------------------------------------------------------------------------
function o = local_getRegOrder(this, hConfig_vect)
% Return vector of registration-order info corresponding to each config

% Find registration objects corresponding to each config object
hRegister_vect = local_getRegFromCfg(this.RegisterDb, hConfig_vect);

% Get order info
o = get(hRegister_vect,'Order');   % vectorized get
if iscell(o)
    o = cat(2,o{:});       % convert cell to non-cell
end

%% ------------------------------------------------------------------------
function hRegister_vect = local_getRegFromCfg(hRegisterDb, hConfig_vect)
%getRegFromCfg Return registration objects corresponding to config objects.

for indx = 1:numel(hConfig_vect)
    hRegister_vect(indx) = hRegisterDb.findRegister(hConfig_vect(indx).Type, ...
                                        hConfig_vect(indx).Name); %#ok
end

%% -------------------------------------------------------------------------
function checkDependencyViolation(this)

% If the configuration is not enabled, it cannot cause a dependency violation
hConfigs = findChild(this.ConfigDb, 'Enable', true);

hMsgLog = get(this, 'MessageLog');

for indx = 1:length(hConfigs)
    
    hRegister = this.RegisterDb.findRegister(hConfigs(indx));
    
    % Loop over and check each dependency.
    for jndx = 1:length(hRegister.Depends)
       hConfigDepend = this.ConfigDb.findConfig(hRegister.Depends{jndx});
       if isempty(hConfigDepend)
           hConfigs(indx).Enable = false;
           if ~isempty(hMsgLog)
               hMsgLog.add('fail', 'Registration', 'Invalid dependency', ...
                   sprintf('Assert: Invalid dependency %s.', hRegister.Depends{jndx}));
           end
       elseif ~hConfigDepend.Enable
           hConfigs(indx).Enable = false;
           if ~isempty(hMsgLog)
               hMsgLog.add('warn', 'Configuration', 'Dependency violated', ...
                   sprintf('Cannot enable "%s:%s" unless "%s" is enabled.', ...
                   hRegister.Type, hRegister.Name, hRegister.Depends{jndx}));
           end
       end
    end
end

% [EOF]

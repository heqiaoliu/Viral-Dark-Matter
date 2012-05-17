function install(h, me, installmenus)
% Attach to ModelExplorer

%   Copyright 2009-2010 The MathWorks, Inc.

if nargin == 2
    installmenus = false;
end

if ~isempty(me)
    h.connect(me, 'up');
    h.Explorer = me;
    % Install on ModelExplorer
    h.Explorer.installViewManager(h, installmenus);
    % keep the ME in sync with MEView changes and vice versa
    h.enableLiveliness;
else
    h.Explorer.installViewManager('', installmenus);
end

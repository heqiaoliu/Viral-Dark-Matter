function configureAdvancedPropertiesObject(this)
% utility to configure advanced (nonlinearity) properties objects contents

% Copyright 1986-2007 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/31 06:13:16 $

import com.mathworks.toolbox.ident.nnbbgui.*;

% attach property pre-set listeners
%Ind = this.Parent.NlarxPanel.getCurrentOutputIndex;
options = this.Parent.getNonlinOptions;
f = fieldnames(options);
for k = 1:length(f)
    L = handle.listener(this,findprop(this,f{k}),'PropertyPostSet',...
        @(es,ed) LocalPropSetCallback(ed,this,f{k}));
    this.Listeners = [this.Listeners,L];
end

%--------------------------------------------------------------------------
function LocalPropSetCallback(ed,this,PropName)
% post-change callback

opt = this.Parent.getNonlinOptions;
OldValue = opt.(PropName);

try
    this.Parent.setNonlinOption(PropName,ed.NewValue);
    nlbbpack.sendModelChangedEvent('idnlarx');
catch E
    % (the callback is not executed twice)
    errordlg(idlasterr(E),'Invalid Value','modal');
    this.(PropName) = OldValue;
end


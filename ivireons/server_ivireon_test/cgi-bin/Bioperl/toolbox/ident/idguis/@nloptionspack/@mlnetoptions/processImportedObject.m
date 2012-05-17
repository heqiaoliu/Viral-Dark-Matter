function processImportedObject(this,obj,varname)
% Process the imported entity and its name returned by import dialog
% (varimportdlg).

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:13:20 $

nl = this.Object;
try
    nl.Network = obj;
catch E
    errordlg(idlasterr(E),'Invalid Network Object','modal')
    return
end

this.Object = nl;
this.jMainPanel.setNetworkObject(java.lang.String(varname));
this.NetworkName = varname;
nlbbpack.sendModelChangedEvent('idnlarx');

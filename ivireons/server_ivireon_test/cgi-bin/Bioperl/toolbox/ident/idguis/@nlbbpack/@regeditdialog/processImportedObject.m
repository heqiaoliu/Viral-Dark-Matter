function processImportedObject(this,obj,varname)
% Process the imported entity and its name returned by import dialog
% (varimportdlg).

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:45:37 $

Ind = this.getCurrentOutputIndex;
m = this.ModelCopy; % h.NlarxPanel.NlarxModel;

try
    m = addreg(m, obj, Ind);
catch E
    errordlg(idlasterr(E),'Invalid Custom Regressor Expression','modal')
    return
end

%h.NlarxPanel.NlarxModel = []; h.NlarxPanel.NlarxModel = m;
this.ModelCopy = []; this.ModelCopy = m;

this.addToCustomRegTable(Ind);

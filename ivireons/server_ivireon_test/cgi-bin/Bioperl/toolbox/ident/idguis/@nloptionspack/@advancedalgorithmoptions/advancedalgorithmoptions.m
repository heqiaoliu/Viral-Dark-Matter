function this = advancedalgorithmoptions(algooptions)
% object for advanced properties of algorithm
% algooptions: handle to nloptionspack.algorithmoptions object

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/12/14 14:45:41 $

this = nloptionspack.advancedalgorithmoptions;
this.Parent = algooptions;

adv = algooptions.Algorithm.Advanced;
pn = fieldnames(adv);
for k = 1:length(pn)
    L = handle.listener(this,findprop(this,pn{k}),...
        'PropertyPostSet',@(es,ed) LocalAdvancedPropCallback(pn{k},ed,this));
    this.Listeners = [this.Listeners,L];
end

%--------------------------------------------------------------------------
function LocalAdvancedPropCallback(prop,ed,this)
% set advanced properties

%disp('in advanced ?')

nn = idnlarx; 
OldValue = this.Parent.Algorithm.Advanced.(prop);

try
    nn.Algorithm.Advanced.(prop) = ed.NewValue;
    this.Parent.Algorithm.Advanced.(prop) = ed.NewValue;
catch E
    errordlg(idlasterr(E),'Invalid Advanced Options Setting','modal');
    this.(prop) = OldValue;
end

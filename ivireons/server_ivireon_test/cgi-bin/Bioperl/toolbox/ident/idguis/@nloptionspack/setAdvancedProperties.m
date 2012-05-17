function setAdvancedProperties(this,options)
% set all properties of this UDD object based on the corresponding
% properties of the nonlinearity object's options.
% this: handle to advancedwavenet/advancedtree object that is required by
% property inspector.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:42 $

if nargin<2
    options = this.Parent.getNonlinOptions; %this.NlarxPanel.NlarxModel.Nonlinearity(Ind).Options;
end

%EN = get(this.Listeners,'Enabled');
set(this.Listeners,'Enabled','off');
f = fieldnames(options);
for k = 1:length(f)
    this.(f{k}) = options.(f{k});
end
set(this.Listeners,'Enabled','on');

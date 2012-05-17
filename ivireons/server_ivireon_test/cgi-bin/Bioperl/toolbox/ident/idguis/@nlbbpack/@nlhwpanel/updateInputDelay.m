function updateInputDelay(this,Del,un,yn)
% update delay (Del) from input un to output yn in nlhw model

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/31 06:13:12 $

m = this.NlhwModel;
if m.nk(yn,un)==Del
    return;
end
m.nk(yn,un) = Del;

this.updateModel(m);

this.updateLinearPanelforNewOutput;

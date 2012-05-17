function updateInputDelay(this,Del,un,yn)
% update delay (Del) from input un to output yn in nlarx model

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2009/01/20 15:32:42 $

m = this.NlarxModel;
if m.nk(yn,un)==Del
    return;
end
m.nk(yn,un) = Del;

this.updateModel(m);

this.updateRegressorsPanel(m,yn);

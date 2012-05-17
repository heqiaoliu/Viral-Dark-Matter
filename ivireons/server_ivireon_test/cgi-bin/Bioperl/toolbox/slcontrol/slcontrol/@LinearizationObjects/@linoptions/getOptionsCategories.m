function opts = getOptionsCategories(this,Description)
% GETOPTIONSCATEGORIES
 
% Author(s): John W. Glass 28-Jul-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:35:14 $

names = fieldnames(this);
opts = {};
for ct = 1:numel(names)
    p = findprop(this,names{ct});
    if strcmp(p.Description,Description)
        opts{end+1} = names{ct};
    end
end
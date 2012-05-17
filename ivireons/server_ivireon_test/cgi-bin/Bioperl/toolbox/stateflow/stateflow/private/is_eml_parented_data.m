function b = is_eml_parented_data(id)
% Determine whether a data belongs to eML or not.

% Copyright 2005 The MathWorks, Inc.

parent = sf('get',id,'data.linkNode.parent');
b = is_eml_based_chart(parent) || is_eml_based_fcn(parent);

end
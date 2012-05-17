function b = is_plant_model_parented_data(id)
% Determine whether a data belongs to a plant model chart or not

% Copyright 2005 The MathWorks, Inc.

parent = sf('DataChartParent', id);
b = is_plant_model_chart(parent);

end

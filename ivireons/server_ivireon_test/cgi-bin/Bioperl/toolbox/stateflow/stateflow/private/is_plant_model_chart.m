function result = is_plant_model_chart(chartId)

% Copyright 2002-2007 The MathWorks, Inc.

% We do not merely check whether a chart has "zero crossings" enabled. We
% also insist that the chart not be continuous. This is to account for
% weird situations where the user enables zero crossings but then changes
% the update method to something other than continuous.
% 
% Since we want to retain the user's settings rather than disable zero
% crossings when the user changed the update method to anything other than
% continuous, we have to extend the check which needs to be done.

% NOTE: Any change in logic here has to be equally reflected in the
% function chart_is_plant_model in chart.cpp

result = sf('IsChartPlantModel', chartId);

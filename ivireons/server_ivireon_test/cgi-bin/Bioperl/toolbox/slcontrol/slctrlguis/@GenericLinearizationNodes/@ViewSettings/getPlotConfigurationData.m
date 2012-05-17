function data = getPlotConfigurationData(this);
%getPlotConfigurationData  Method to get the current plot configurations
%for a view.
%
%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.

NUMBER_OF_PLOTS = 6;

data = javaArray('java.lang.Object',NUMBER_OF_PLOTS,3);
for ct = 1:NUMBER_OF_PLOTS
        data(ct,1) = java.lang.String(sprintf('Plot %d',ct));
        %% Compute the new table data
        util = com.mathworks.toolbox.slcontrol.util.LTIPlotUtils;
        data(ct,2) = char(util.getComboLabelfromPlotType(this.PlotConfigurations{ct,2}));
        data(ct,3) = java.lang.String(this.PlotConfigurations{ct,3});
end
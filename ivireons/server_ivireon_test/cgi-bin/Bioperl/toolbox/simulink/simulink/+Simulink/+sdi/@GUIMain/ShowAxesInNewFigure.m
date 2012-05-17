function ShowAxesInNewFigure(this, AxesID)

    % Copyright 2009-2010 The MathWorks, Inc.

    % Get axes object for ID
    AxesObj = this.GetAxesByID(AxesID);
    
    gc = Simulink.sdi.GeoConst;
    
    % Create new figure and copy data
    f = figure;    
    newAxes = copyobj(AxesObj, f);
    set(newAxes, 'Units', 'normal');
    set(newAxes, 'pos', gc.defaultAxesPos);
end
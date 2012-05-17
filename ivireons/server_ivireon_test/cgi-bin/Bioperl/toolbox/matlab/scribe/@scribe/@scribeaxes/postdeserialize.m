function postdeserialize(scribeax)

% Copyright 2003-2006 The MathWorks, Inc.

shapes = scribeax.Shapes;
scribeChil = handle(get(scribeax,'Children'));
shapes = [shapes;scribeChil];
for k=1:length(shapes)
    if ishandle(shapes(k))
        shk = shapes(k);
        if isequal(shapes(k).shapetype,'legend')
            leginfo = shapes(k).methods('postdeserialize');
            delete(double(leginfo.leg));
            if strcmpi(leginfo.loc,'none')
                legend(leginfo.ax,leginfo.strings,'Location',leginfo.position);
            else
                legend(leginfo.ax,leginfo.strings,'Location',leginfo.loc);
            end
        else
            if ismethod(shapes(k),'postdeserialize')
                shapes(k).postdeserialize;
            end
        end
    end
end

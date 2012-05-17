function findBaseWSSimulinkParameters(obj)

%   Copyright 2010 The MathWorks, Inc.

    simData = obj.SimDataTimeSeries(1);
    sldvParameters = simData.paramValues;
    for idx=1:length(sldvParameters)
        if (evalin('base', sprintf('isa(%s, ''Simulink.Parameter'');', sldvParameters(idx).name)))
            obj.BaseWSSimulinkParameters.(sldvParameters(idx).name) = ...
                evalin('base', sldvParameters(idx).name);                
        end
    end
end


function list = dataSrcsList(this, DataRunID)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    tsr = Simulink.sdi.SignalRepository;
    count = tsr.getSignalCount(DataRunID);
    
    list = cell(1,count);
    for i=1:count
        data = tsr.getSignal(DataRunID, i);
        list{i} = data.DataSource;
    end
    
end
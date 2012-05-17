function oldSldvData = removeVersionInfo(sldvData)

    oldSldvData = sldvData;

    if isfield(oldSldvData,'Version')
        oldSldvData = rmfield(oldSldvData,'Version');
    end

end
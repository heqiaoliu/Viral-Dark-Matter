function msgPortNames = containsArrayOfBuses(modelH)
    ssInBlkHs = Sldv.utils.getSubSystemPortBlks(modelH);
    numInports = length(ssInBlkHs);
    msgPortNames = {};  
    for idx=1:numInports
        isBus = Sldv.utils.isInOutportBlkDataTypeBus(ssInBlkHs(idx));
        if(isBus)
            dims = get_param(ssInBlkHs(idx), 'PortDimensions');
            if(prod(str2num(dims)) > 1) %#ok<ST2NM>
                msgPortNames{end+1} = getfullname(ssInBlkHs(idx)); %#ok<AGROW>
            end
        end
    end
end
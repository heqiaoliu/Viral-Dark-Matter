function desc = getTestcaseDesc(sldvData, i)

%   Copyright 2008 The MathWorks, Inc.

    desc = '';
   
    [tc, title] = Sldv.DataUtils.getSimData(sldvData, i);
    if isempty(tc)
        return;
    end
    
    atTime = zeros([1 length(sldvData.Objectives)]);
    for k=1:length(tc.objectives)
        obj = tc.objectives(k);
        atTime(obj.objectiveIdx) = obj.atTime;
    end

    nobjs = 0;
    desc = '';
    for j=1:length(sldvData.Objectives)
        obj = sldvData.Objectives(j);
        if obj.testCaseIdx == i
            nobjs = nobjs+1;
            blk = sldvData.ModelObjects(obj.modelObjectIdx);
            desc = sprintf('%s\n\t%d. %s - %s @ T=%02.02f', ...
                           desc, nobjs, ...
                           blk.descr, ... 
                           obj.descr, atTime(j));
        end
    end
    
    pdesc = '';
    if isfield(tc, 'paramValues')
        for m=1:length(tc.paramValues)
           p = tc.paramValues(m);
           pdesc = sprintf('%s\n\t\t%s = %s', ...
                           pdesc, p.name, sldvshareprivate('util_matrix2str', p.value));
        end
        pdesc = sprintf('\n\tParameter values:%s\n', pdesc);
    end
    
    desc = sprintf('%s %d (%d Objectives)%s%s', ...
                   title, i, nobjs, pdesc, desc);
end

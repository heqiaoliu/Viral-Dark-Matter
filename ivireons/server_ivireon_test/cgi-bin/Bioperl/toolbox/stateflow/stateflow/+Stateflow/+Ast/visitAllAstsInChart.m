function visitAllAstsInChart(chartId, cbFcn)

    %   Copyright 2009-2010 The MathWorks, Inc.

    objIds = [sf('get', chartId, '.states'), sf('get', chartId, '.transitions')];
    for ii=1:length(objIds)
        objId = objIds(ii);
        objUddH = idToHandle(sfroot, objId);
        
        if ~isa(objUddH, 'Stateflow.State') && ~isa(objUddH, 'Stateflow.Transition')
            continue
        end
        
        try
            cont = Stateflow.Ast.getContainer(idToHandle(sfroot, objId));
        catch ME
            if isequal(ME.identifier, 'Stateflow:Ast:ParseError')
                continue
            else
                rethrow(ME);
            end
        end
        
        sections = cont.sections;
        for i = 1:length(sections)
            if(isa(sections{i},'Stateflow.Ast.EventSection'))
                cond = sections{i}.condition{1};
                cbFcn(objId, cond);
            end
            roots = sections{i}.roots;
            for j=1:length(roots)
                cbFcn(objId, roots{j});
            end
        end
    end
end

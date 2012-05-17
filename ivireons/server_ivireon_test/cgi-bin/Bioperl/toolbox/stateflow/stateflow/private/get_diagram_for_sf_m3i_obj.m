function modelDiagram = get_diagram_for_sf_m3i_obj(sfObj)

modelDiagram = [];

if(isa(sfObj,'StateflowDI.State') || isa(sfObj,'StateflowDI.ImmutableState'))
    
    if( sfObj.isSLFunction )
        stateId = sfObj.backendId;
        % stateId is int32, conversion to double is necessary to return the
        % valid block handle, surprisingly!!
        % -sramaswa
        slFcnBlockHandle = sf('get', double(stateId), '.simulink.blockHandle');
        slFcnBlockUDI = get(slFcnBlockHandle,'Object');
        slFcnFullName = slFcnBlockUDI.getFullName;
        modelDiagram = SLM3I.Util.getDiagram(slFcnFullName); 
    elseif( sfObj.isSubchart )
        modelDiagram = StateflowDI.Util.getSubviewer( sfObj.backendId );
    end     
    
end

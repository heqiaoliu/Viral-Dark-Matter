function checkPARFORoption(obj)

%   Copyright 2010 The MathWorks, Inc.

    useParComp = Sldv.SimModel.checkSldvFeature('UseParforForSim');    
    if useParComp
        obj.checkMatlabPool;
        if length(obj.TcIdx)==1
            useParComp = false;
            msgId = 'UnnecessaryParfor';                       
            msg = xlate(['There is only one test case to simulate. ', ...                           
                       'Disabling the use of Parallel computation.']);                       
            obj.handleMsg('warning', msgId, msg);               
        end
        if useParComp && obj.GetCoverage
            useParComp = false;
            msgId = 'NoParforForCoverage';                       
            msg = xlate(['Parallel computation cannot be used to measure coverage. ', ...                           
                       'Disabling the use of Parallel computation.']);                       
            obj.handleMsg('warning', msgId, msg);   
        end        
        if useParComp && ...
                (strcmp(get_param(obj.Model,'SimulationMode'),'accelerator') || ...
                length(obj.ModelHsInMdlRefTree)>1 || ...
                ~isempty(find(sfroot, '-isa', 'Stateflow.Machine', 'Name', obj.Model))); %#ok<GTARG>
            useParComp = false;
            msgId = 'NoParforForModelBlockEMLSF';                       
            msg = xlate(['Parallel computation cannot be used to simulate the tests cases if ', ...
                'model is configured to simulate in Accelerator mode or it contains a Stateflow, ', ...
                'an Embedded MATLAB, or a Simulink Model block. ',...
                'Disabling the use of Parallel computation.']);                                                                                              
            obj.handleMsg('warning', msgId, msg);               
        end
        if useParComp && strcmp(get_param(obj.ModelH,'Dirty'),'on')
            useParComp = false;
            msgId = 'DirtyMdlParFor';                   
            msg = xlate(['Model ''%s'' has unsaved changes. Parallel computation cannot be ', ...                           
                       'used to simulate the test cases. ', ... 
                       'Disabling the use of Parallel computation.']); 
            obj.handleMsg('warning', msgId, msg, obj.Model);              
        end
    end            
    obj.UseParComp = useParComp; 
end

% LocalWords:  EMLSF

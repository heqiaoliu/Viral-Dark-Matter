function status = isMdlRefHarnessEnabled(testcomp)    

%   Copyright 2008-2010 The MathWorks, Inc.

    if exist('sldvprivate', 'file')==2
        % check model is created from a subsystem analysis
        if sldvprivate('mdl_iscreated_for_subsystem_analysis', testcomp, false)
            % we are in subsystem analysis mode and test component is live.
            % Which means that, this utility is invoked from sldvrun.
            status = false;
            return;
        end
    end
    
    if ~isempty(testcomp) && ~isempty(testcomp.analysisInfo)
        analysisInfo = testcomp.analysisInfo;       
        blockrepWithSS = ~isempty(analysisInfo.analyzedSubsystemH) && ...
                            ishandle(analysisInfo.analyzedSubsystemH) && ...
                            ~isempty(analysisInfo.replacementInfo.replacementModelH) && ...
                            ishandle(analysisInfo.replacementInfo.replacementModelH);
        if blockrepWithSS
            status = false;
            return;
        end
    end
        
    opts = [];
        if ~isempty(testcomp) && ~isempty(testcomp.activeSettings) && ...
                isa(testcomp.activeSettings,'Sldv.Options')
            opts = testcomp.activeSettings;                
        end
    
    %default options sets to off anyway
    if ~isempty(opts)
        status = strcmp(get(opts,'ModelReferenceHarness'),'on');
    else
        status = false;
    end         
            
end
% LocalWords:  Sldv testcomponent

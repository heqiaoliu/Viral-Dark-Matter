function pcgd_LCT(Step)
    % Runs the stages of the Legacy Code Tool

%   Copyright 2007 The MathWorks, Inc.

    [pcgDemoData] = RTWDemos.pcgd_startEmbeddedCoderOverview;
	switch Step
        case 1
            def     = legacy_code('initialize');
            assignin('base','def',def);            
            message = 'Definition Structure, def, created in base workspace';
        case 2
            pcgDemoData = evalin('base','pcgDemoData');
            def         = evalin('base','def');
            RTWDemos.pcgd_wrapperData(pcgDemoData,def);
            message = 'Function interface defined';
        case 3
            def     = evalin('base','def');
            legacy_code('sfcn_cmex_generate',def);
            message = 'S-Function code generated';
        case 4
            def     = evalin('base','def');      
            legacy_code('compile',def);            
            message = 'S-Function Compiled';            
        case 5
            def     = evalin('base','def');           
            legacy_code('slblock_generate',def);
            message = 'S-Function block generated';            
        case 6
            def     = evalin('base','def');      
            legacy_code('sfcn_tlc_generate',def)            
            message = 'TLC File Created';
        otherwise
            message = 'Error in with Legacy Code Tool Prep Stage';
    end

    % list of messages
    tmph = msgbox(message);
    pause(1)
    delete(tmph);
end

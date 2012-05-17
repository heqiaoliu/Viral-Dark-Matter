function getInputMATFilePaths(obj)

%   Copyright 2010 The MathWorks, Inc.

    opts = sldvdefaultoptions;       
    opts.OutputDir = obj.OutputDir;
    
    msg = xlate(['In order to use Code Generation Verification (CGV) API ' ...
                'separate MAT files must be generated to store input data. ' ...
                'Unable to generate MAT files.']);  
    msgId = 'UnabletoCreateMATFilesForCGV';

    FilePathMATFile = '$ModelName$_cgv_input';
    MakeOutputFilesUnique = 'on';
    
    numTestCases = length(obj.TcIdx);
    obj.CGVMATFileInput = cell(1,numTestCases);
    for idx=1:numTestCases
        inputFile = sprintf('%s_tc_%d',FilePathMATFile,obj.TcIdx(idx));
        fullPath = Sldv.utils.settingsFilename(inputFile,...
            MakeOutputFilesUnique,...
            '.mat', obj.Model, false, true, opts);

        if isempty(fullPath)                                                                   
            obj.handleMsg('error', msgId, msg);          
        end
        obj.CGVMATFileInput{idx} = fullPath;
    end
end
% LocalWords:  CGV Unableto cgv tc

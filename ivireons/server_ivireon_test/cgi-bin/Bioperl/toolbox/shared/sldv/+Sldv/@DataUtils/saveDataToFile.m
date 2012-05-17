function warnmsg = saveDataToFile(sldvData, filename, createableSimData)  %#ok<INUSL>
    warnmsg = '';    
    if nargin<3
        createableSimData = true;
    end
    
    if isempty(filename)
        warnmsg = 'filename should not be empty';
    end
        
    if createableSimData
        try
            save(filename, 'sldvData');
        catch Mex %#ok<NASGU>
            warnmsg = ['Cannot write to the file: ',filename];            
        end    
    else
        warnmsg =  [ char(10) ...
            'The data file was not created because the ' ...
            'model has input signals of Fixed Point type and the Fixed-Point Toolbox is ' ...
            'not installed. The Fixed-Point Toolbox is required to correctly create the test data.' ...
            char(10)];                    
    end
end
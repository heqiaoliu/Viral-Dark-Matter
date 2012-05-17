function qualifiedName = getQualifiedFileName(filePath)
    % GETQUALIFIEDFILENAME - used to extract the file name
    % qualified by the enclosing package and/or class

    % Copyright 2009 The MathWorks, Inc.
    qualifiedName = helpUtils.getPackageName(filePath);
    
    [folderPath, fileName] = fileparts(filePath);
    
    if ~helpUtils.containers.isClassDirectory(folderPath)
        if ~isempty(qualifiedName)
            qualifiedName = [qualifiedName '.' fileName];
        else
            qualifiedName = fileName;
        end
    end
end
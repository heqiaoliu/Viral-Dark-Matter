% Copyright 2009 The MathWorks, Inc.
%
% File formats:
% -1 -> Unknown
% 1 -> 7a and earlier
% 2 -> 7b
% 3 -> >=8a 
function version = determineDepFileVersion(fullFileName, abstractDataSignature, editorDataSignature)
    version = -1;
    
    depFile = fopen(fullFileName);            
    if( eq(depFile, -1) )
        assert(false); %should have been handled prior to calling this function
        return;
    end
    
    firstLine = fgets(depFile);
    fclose(depFile);
    if( strmatch('ModelProps', firstLine) )                
        version = 1;
        return;
    end
    
    if( strmatch('<?xml version="1.0" encoding="utf-8"?>', firstLine) )
        version = 2;
        return;
    end
           
    version = 3;
end

function dirInfo = hashedDirInfo(dirPath)
    persistent seenDirs;
    persistent usingHash;
    if nargout == 0
        seenDirs = [];
        usingHash = true;
        return;
    end
    
    if usingHash
        try
            dirPathAsField = ['x' regexprep(fliplr(dirPath), {'@','+','\W'}, {'AT','PLUS',''})];
            if length(dirPathAsField) > namelengthmax
                dirPathAsField = dirPathAsField(1:namelengthmax);
            end
            if isfield(seenDirs, dirPathAsField)
                dirInfo = seenDirs.(dirPathAsField);
            else 
                % Note: -caseinsensitive is an undocumented and unsupported feature
                dirInfo = what('-caseinsensitive', dirPath);
                seenDirs.(dirPathAsField) = dirInfo;
            end
        catch e %#ok<NASGU>
            usingHash = false;
        end
    else
        dirInfo = what('-caseinsensitive', dirPath);
    end
    
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $  $Date: 2007/12/14 14:53:36 $

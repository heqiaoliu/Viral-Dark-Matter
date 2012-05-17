function deleteDataOrEvent(id)
    % Delete data or event object specified by id

%   Copyright 2009 The MathWorks, Inc.
    
    if(ischar(id))
        id = str2double(id);
    end
    
    rt = sfroot;
    obj = rt.idToHandle(id);
    if(~isempty(obj))
        showGui = sfpref('showDeleteUnusedConfGui');         
        if(showGui == 1)
            deleteUnusedConfGui(obj);
        else
            delete(obj);
        end
    end
end

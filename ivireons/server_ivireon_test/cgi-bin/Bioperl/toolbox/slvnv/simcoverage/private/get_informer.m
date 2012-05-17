function uddObj = get_informer(varargin)

% Copyright 2003-2005 The MathWorks, Inc.
    
    persistent infrmObj;
    %erase
    if ~isempty(varargin) 
        if ~isempty(infrmObj) && ishandle(infrmObj)
            delete(infrmObj);
        end
        infrmObj = [];
        return;
    end
    if isempty(infrmObj)
        infrmObj = DAStudio.Informer;
        infrmObj.mode = 'ClickMode';
    end

    try
        infrmObj.position = [10 600 125 400];
    catch Mex %#ok<NASGU>
        infrmObj = DAStudio.Informer;
        infrmObj.mode = 'ClickMode';
        infrmObj.position = [10 600 125 400];
    end
    
    if (infrmObj.visible == 0)
        infrmObj.visible = 1;
    end
 
    uddObj = infrmObj;
    

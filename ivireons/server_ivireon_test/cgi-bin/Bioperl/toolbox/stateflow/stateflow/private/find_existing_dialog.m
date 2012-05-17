function thisDialog = find_existing_dialog(thisDialogTag)

% Copyright 2005 The MathWorks, Inc.

    t = DAStudio.ToolRoot;
    openD = t.getOpenDialogs;
    thisDialog = [];

    for i=1:size(openD)
        tag = openD(i).dialogTag;
        if strcmp(tag, thisDialogTag)
            % We have a match
            thisDialog = openD(i);
            break;
        end
    end

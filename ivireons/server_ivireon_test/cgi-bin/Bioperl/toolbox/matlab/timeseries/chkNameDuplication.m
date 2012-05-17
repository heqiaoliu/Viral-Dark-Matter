function [newname, status] = chkNameDuplication(h,name,type)
%
% tstool utility function
% During rename operation, check if an object of the name specified already
% exists, ans an immediate child of parent h (such as tsparentnode or
% tscollectionNode object).
%
% "type": represents the node class, such as 'tsguis.tsnode'.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2006/06/27 23:05:18 $

newname = name;
status = true;


if localDoesNameExist(h,name,type)
    Namestr = sprintf('''%s'' is already defined. Please choose a different name.', ...
        name);
elseif ~isempty(strfind(name,'/'))
    Namestr = 'Slashes (''/'') are not allowed in the names. Please choose a different name.';
else
    return
end

tmpname = name;
while true
    answer = inputdlg(Namestr,xlate('Enter New Name'));
    % comparing the given new name with all the nodes in tstool
    %return if Cancel button was pressed
    if isempty(answer)
        status = false;
        return;
    end
    tmpname = strtrim(cell2mat(answer));
    if isempty(tmpname)
        Namestr = sprintf('Empty names are not allowed. Please choose a different name.');
    else
        tmpname = strtrim(cell2mat(answer));
        %node = h.getChildren('Label',tmpname);
        if localDoesNameExist(h,tmpname,type)
            Namestr = sprintf('''%s'' is already defined. Please choose a different name.',tmpname);
            continue;
        elseif ~isempty(strfind(tmpname,'/'))
            Namestr = 'Slashes (''/'') are not allowed in the names. Please choose a different name.';
            continue;
        else
            newname = tmpname;
            break;
        end %if ~isempty(node)
    end %if isempty(answer)
end %while


%--------------------------------------------------------------------------
function Flag = localDoesNameExist(h,name,type)

nodes = h.getChildren('Label',name);
Flag = false;
if ~isempty(nodes)
    for k = 1:length(nodes)
        if strcmp(class(nodes(k)),type)
            Flag = true;
            break;
        end
    end
end
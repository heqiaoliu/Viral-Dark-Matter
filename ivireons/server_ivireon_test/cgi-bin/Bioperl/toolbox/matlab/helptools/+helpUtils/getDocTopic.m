function docTopic = getDocTopic(path, name, isClassElement)
    persistent refBookPattern;
    if isempty(refBookPattern)
        pathToToolboxes = [matlabroot, filesep, 'toolbox', filesep];
        escapedPathToToolboxes = regexptranslate('escape', pathToToolboxes);
        refBookPattern = ['^' escapedPathToToolboxes, '(?<refBook>\w+)'];
    end
    splitPath = regexp(path, refBookPattern, 'names');
    docTopic = '';
    if ~isempty(splitPath)
        refBook = [splitPath.refBook '/' name];
        docCmdArg = com.mathworks.mlwidgets.help.HelpInfo.getDocCommandArg(refBook, isClassElement);
        if ~isempty(docCmdArg)
            docTopic = char(docCmdArg);
        end
    end
end

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/12/08 21:54:27 $

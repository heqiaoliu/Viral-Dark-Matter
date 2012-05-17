function outputMFilePath = exportToMFile(this, outputDir)
    % EXPORTTOMFILE - takes a HelpContainer object as input and generates
    % an M-file containing all the help comments stored in this object.
    %
    % Example:
    % filePath = which('addpath');
    % helpContainer = helpUtils.XMLUtils.HelpContainer.create(filePath);
    % outputDir = pwd;
    % outputMFilePath = helpContainer.exportToMFile(outputDir);
    
    % Copyright 2009 The MathWorks, Inc.
    error(nargchk(2,2,nargin, 'struct'));
    
    if ~ischar(outputDir) || ~isdir(outputDir)
        error('MATLAB:abstractHelpContainer:exportToMFile:InvalidOutputDirectory', ...
            'Second input argument must be a valid path to a directory');
    end
    
    % Need to extract method name from package and/or class qualified name
    fileName = regexp(this.mFileName, '\w*$', 'match', 'once');
    
    outputMFilePath = fullfile(outputDir, [fileName '.m']);
    
    outputFileHandle = fopen(outputMFilePath, 'w');
    
    if outputFileHandle < 0
        error('MATLAB:abstractHelpContainer:exportToMFile:MFileCreationFailed', ...
            'Unable to create file in %s', outputDir);
    end
    
    closeFile = onCleanup(@()fclose(outputFileHandle));
    
    if this.isClassHelpContainer
        writeClassHelpMFile(this, outputFileHandle, fileName);
    else
        if writeFunctionHelpMFile(this, outputFileHandle)
            writeCopyrightText(this, outputFileHandle);
        else
            error('MATLAB:abstractHelpContainer:exportToMFile:NoHelpComments', ...
                'Help container does not store any help comments to export.');
        end
    end
    
end

%% ------------------------------
function hasMainHelp = writeFunctionHelpMFile(helpContainer, outputFileHandle)
    % writeFunctionHelpMFile - outputs the main help string stored in
    % HelpContainer to the output file as a comment.
    mainHelpStr = helpContainer.getHelp;
    
    hasMainHelp = ~isempty(mainHelpStr);
    if hasMainHelp
        mainHelpStr = regexprep(mainHelpStr, '^.', '%', 'lineanchors');
        if mainHelpStr(end) ~= 10
            mainHelpStr = [mainHelpStr 10];
        end
        fprintf(outputFileHandle, '%s', mainHelpStr);
    end
end

%% ------------------------------
function writeCopyrightText(helpContainer, outputFileHandle)
    copyrightText = helpContainer.getCopyrightText;
    if ~isempty(copyrightText)
        fprintf(outputFileHandle, '\n %s\n\n', copyrightText);
    end
end


%% ------------------------------
function writeClassHelpMFile(helpContainer, outputFileHandle, className)
    
    fprintf(outputFileHandle, 'classdef %s\n', className);
    
    if writeFunctionHelpMFile(helpContainer, outputFileHandle)
        % if class has main help then append newline followed by copyright
        writeCopyrightText(helpContainer, outputFileHandle);
        writeClassMembers(helpContainer, outputFileHandle);
    else
        % otherwise write the copyright at the bottom of the class M-file
        writeClassMembers(helpContainer, outputFileHandle);
        writeCopyrightText(helpContainer, outputFileHandle);
    end
    
end

%% ------------------------------
function writeClassMembers(helpContainer, outputFileHandle)
    % writeClassMembers - prints the help content of a ClassHelpContainer
    % related to methods (including constructor) and properties into the
    % output M-file.

    % Write 'methods' block
    strIndent = getIndent(1);
    fprintf(outputFileHandle, [strIndent 'methods\n']);

    % Print the constructor
    printConstructorFcnHandle = @(constructorHelpContainer) printMethodHelp(outputFileHandle, ...
            constructorHelpContainer, 'out=%s');

    printAllMembersHelp(helpContainer.getConstructorIterator, printConstructorFcnHandle);

    % Print all the methods
    printMethodsFcnHandle = @(methodHelpContainer) printMethodHelp(outputFileHandle, ...
            methodHelpContainer, '%s(in) %%#ok<MANU>');

    printAllMembersHelp(helpContainer.getConcreteMethodIterator, printMethodsFcnHandle);
    
    fprintf(outputFileHandle, [strIndent 'end\n']);
    
    % Write abstract methods block
    fprintf(outputFileHandle, [strIndent 'methods (Abstract)\n']);
    
    % Print all the abstract methods as if they are properties
    printAbstractFcnHandle = @(abstractHelpContainer) printPrefixHelp(outputFileHandle, abstractHelpContainer);
    
    printAllMembersHelp(helpContainer.getAbstractMethodIterator, printAbstractFcnHandle);
    
    fprintf(outputFileHandle, [strIndent 'end\n']);

    % Write 'properties' block
    fprintf(outputFileHandle, [strIndent 'properties\n']);
    
    % Print all the properties
    printPropertiesFcnHandle = @(propertyHelpContainer) printPrefixHelp(outputFileHandle, propertyHelpContainer);
    
    printAllMembersHelp(helpContainer.getPropertyIterator, printPropertiesFcnHandle);
    
    fprintf(outputFileHandle, [strIndent 'end\n']);
    
    fprintf(outputFileHandle, 'end\n');
end

%% ------------------------------
function printAllMembersHelp(memberIterator, printMember)
    % printAllMembersHelp - iterates through and prints the help content of
    % the ClassMemberHelpContainers
    while memberIterator.hasNext
        memberHelpContainer = memberIterator.next;
        printMember(memberHelpContainer);
    end    
end

%% ------------------------------
function printMethodHelp(outputFileHandle, memberHelpContainerObj, functionFormat)
    % printMethodHelp - writes help comments for a class method to the
    % output M-file.
    twoTabIndent = getIndent(2);
    
    functionFormat = sprintf('%s%s %s\n', twoTabIndent, 'function', functionFormat);
    fprintf(outputFileHandle, functionFormat, memberHelpContainerObj.Name);
    
    methodHelp = memberHelpContainerObj.getHelp;
    
    if ~isempty(methodHelp)
        threeTabIndent = getIndent(3);
        methodHelp = formatHelpString(methodHelp, [threeTabIndent '%']);
        fprintf(outputFileHandle, '%s', methodHelp);
    end
    
    fprintf(outputFileHandle, '%send\n\n', twoTabIndent);
end

%% ------------------------------
function printPrefixHelp(outputFileHandle, prefixHelpContainerObj)
    % printPrefixHelp - writes help comments followed by the identifier name
    prefixHelp = prefixHelpContainerObj.getHelp;
    indent = getIndent(2);
    if ~isempty(prefixHelp)
        formattedStr = formatHelpString(prefixHelp, [indent '%']);
        fprintf(outputFileHandle, '%s', formattedStr);
    end
    fprintf(outputFileHandle, '%s%s;\n\n', indent, prefixHelpContainerObj.Name);
end

%% ------------------------------
function formattedHelp = formatHelpString(origHelpStr, commentIndent)
    % formatHelpString - helper method to format help comments
    formattedHelp = regexprep(origHelpStr, '^.', commentIndent, 'lineanchors');
    
end

%% ------------------------------
function outputStr = getIndent(numTabs)
    % getIndent - helper function to format the indents for help comments
    % in generated M-file
    outputStr = repmat(' ', 1, numTabs * 4); % tab defined as four spaces
end

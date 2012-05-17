function errorStruct = openFile(this, filenames)
%OPENFILE A method which is invoked to load a new file.
%   If a filename is not provided to this function,
%   They will be asked to select a file.
%
%   Function arguments
%   ------------------
%   THIS: the fileframe object instance.
%   FILENAME: the name of the file to open.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/07/28 14:29:11 $

    errorStruct = [];
    numOpen = numOpenFiles(this);

    % Select a file if one is not provided.
    if nargin < 2
        title = xlate('Select an HDF or HDF-EOS file');
        filterspec = {'*.hdf', xlate('HDF Files (*.hdf)');...
                      '*.*', xlate('All Files')};
        
        filenames = getFilenames(this, title, filterspec);
        if isempty(filenames)
            return
        end
    else
        % Convert to a cell array for homogenous processing later on
        filenames = {filenames};
    end
    % Open each selected file
    for i=1:length(filenames)
        filename = filenames{i};
        % Open the file based on its extension
        set(this.figureHandle, 'Pointer', 'watch');
        try
            [path file ext] = fileparts(filename);
            if hdftool.validateFile(filename)
                % Open the file
                fileTree = hdftool.hdftree(this, this.treeHandle, filename);
            else
                errorStruct.message = 'File is not in HDF format';
                errorStruct.identifier = 'MATLAB:hdftool:incorrectFormat';
                dlgMessage = sprintf('This file (%s) is not in the HDF format. ', filename);
                dlgMessage = sprintf('%s%s', dlgMessage, xlate('Do you wish to use the Import Wizard to import data from this file?'));
                importAnyway = questdlg(dlgMessage, 'Use the Import Wizard?',...
                    'Yes','No','Yes');
                if strcmp(importAnyway, 'Yes')
                    uiimport(filename);
                end
            end
        catch myException
            set(this.figureHandle, 'Pointer', 'arrow');
            errorStruct = myException;
            if nargin < 2
                % We are being called without a filename.
                % Report errors in a dialog
                errordlg(myException.message, 'Error opening file');
            end
        end
    end

    set(this.figureHandle, 'Pointer', 'arrow');
    if numOpen==0
        this.setDatapanel('default');
    else
        errorStruct = [];
    end
end

function filenames = getFilenames(this, title, filterspec)
    %GETFILENAME gets a filename from the user
    [filenames pathname] = uigetfile(filterspec, title,'MultiSelect', 'on');
    if isequal(filenames,0)
        filenames = '';
        return;
    end
    if ~iscell(filenames)
        filenames = {filenames};
    end
    for i=1:length(filenames)
        filenames{i} = fullfile(pathname,filenames{i});
    end
end

function num = numOpenFiles(this)
    % A method to determine the number of open files.
    hdfRootNode = get(this.treeHandle,'Root');
    num = get(hdfRootNode, 'ChildCount');
end


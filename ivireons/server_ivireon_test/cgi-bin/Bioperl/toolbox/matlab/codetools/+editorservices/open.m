function obj = open(filename)
%editorservices.open Open file in MATLAB Editor.
%   EDITOROBJ = editorservices.open(FILENAME) opens the specified file in 
%   the MATLAB Editor and creates an associated EditorDocument object. 
%   FILENAME must include the full path. If the file is already open, the  
%   OPEN function makes the document active.
%
%   If the file does not exist and your Preferences settings allow Editor
%   prompts, MATLAB displays a confirmation dialog box to create the file.
%   In this case, the OPEN function does not resume until you interactively 
%   close the dialog box.
%
%   Example: Open fft.m and view the Filename property of the associated
%   EditorDocument object.
%
%      fftDoc = editorservices.open(which('fft.m'));
%      fftDoc.Filename
%
%   See also edit, editorservices.EditorDocument, editorservices.find, editorservices.IsOpen, editorservices.openAndGoToFunction, editorservices.openAndGoToLine, editorservices.EditorDocument/makeActive.

% Copyright 2008-2009 The MathWorks, Inc.

if nargin == 0
    error('MATLAB:editorservices:NoFilename',...
        'No filename to editorservices.open specified. Please specify a filename.');
end

if ischar(filename)
    obj = editorservices.EditorDocument.openEditor(filename);
elseif iscell(filename)
    obj = editorservices.EditorDocument.empty(1,0);
    for i = 1:numel(filename)
        try
            thisEditor = editorservices.open(filename{i});
            %Have to do this check and build in a loop because each input may result in an
            %empty EditorDocument object, which we cannot concatenate to the list and so
            %we don't know for sure what the final size will be.
            obj(end+1) = thisEditor; %#ok<AGROW>
        catch ex
            warning(ex.identifier, ex.message);
        end
        
    end
end

end

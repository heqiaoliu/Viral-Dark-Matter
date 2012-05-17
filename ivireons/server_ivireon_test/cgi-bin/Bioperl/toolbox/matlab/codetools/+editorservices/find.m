function obj = find(filename)
%editorservices.find Create EditorDocument object for already open document.
%   EDITOROBJ = editorservices.find(FILENAME) returns an EditorDocument
%   object for the open file FILENAME. If FILENAME does not include the 
%   full path, MATLAB issues a warning and returns the first matching 
%   Editor document found. If the file is not open or found, EDITOROBJ is
%   empty.
%
%   Example: Open several files in the Editor. Create an EditorObject
%   associated with fft.m, and list its properties.
%
%      edit('fft.m');
%      edit('fftn.m');
%      edit('fftw.m');
%
%      % Create object and view all properties
%      fftObj = editorservices.find(which('fft.m'))
%
%      % View the Filename property
%      fftObj.Filename
%
%   See also editorservices.EditorDocument, editorservices.open.

%  Copyright 2008-2009 The MathWorks, Inc.

if nargin == 0
    error('MATLAB:editorservices:NoFilename',...
        'No filename to editorservices.find specified. Please specify a filename.');
end

if ischar(filename)
    obj = editorservices.EditorDocument.findEditor(filename);
elseif iscell(filename)
    obj = editorservices.EditorDocument.empty(1,0);
    for i = 1:numel(filename)
        thisEditor = editorservices.find(filename{i});
        if isempty(thisEditor)
            warning('MATLAB:editorservices:FileNotFound',...
                'Could not create EditorDocument. File ''%s'' not found', filename{i});
        else
            %Have to do this check and build in a loop because each input may result in an 
            %empty EditorDocument object, which we cannot concatenate to the list and so
            %we don't know for sure what the final size will be.
            obj(end+1) = thisEditor; %#ok<AGROW>
        end
    end
end

end

function openStatus = isOpen( filename )
%editorservices.isOpen Determine whether specified file is open in Editor.
%   OPENSTATUS = editorservices.isOpen(FILENAME) returns logical TRUE when
%   the file FILENAME is open in the MATLAB Editor. Otherwise, it returns
%   FALSE. The FILENAME input must include the full path.
%
%   Example: Open fft.m in the Editor, and verify that it is open. Close
%   it, and verify that it is closed.
%
%      fftPath = which('fft.m');
%
%      % Open and check
%      fftDoc = editorservices.open(fftPath);
%      check_fft = editorservices.isOpen(fftPath)
%
%      % Close and check
%      fftDoc.close;
%      check_fft = editorservices.isOpen(fftPath)
%
%   See also editorservices.EditorDocument, editorservices.EditorDocument.IsOpen, editorservices.open

% Copyright 2009 The MathWorks, Inc.

jea = editorservices.EditorUtils.getJavaEditorApplication;
openStatus = jea.isEditorOpen(...
    editorservices.EditorUtils.fileNameToStorageLocation(filename));

end


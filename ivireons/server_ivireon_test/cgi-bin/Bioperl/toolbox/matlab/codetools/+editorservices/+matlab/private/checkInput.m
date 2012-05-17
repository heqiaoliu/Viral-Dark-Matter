function checkInput( editorObj, language, varargin )
%checkInput helper function to verify certain properties of an EditorDocument or set of EditorDocuments
%
%   This function is unsupported and might change or be removed without
%   notice in a future version. 

% checkInput verifies that object is an EditorDocument, that it is open,
% and that language is the right type. It has optional inputs for verifying
% other properties
%
%  checkInput(editorObj, languageClass) verifies that editorObj is open and
%  its language type matches the languageClass. The languageClass is a char
%  that is the full java class name of the expected language object for
%  instance a MATLAB language editor would have languageClass of
%  'com.mathworks.widgets.text.mcode.MLanguage'
%
%  checkInput(editorObj, languageClass, 'scalar') verifies as before but
%  also makes sure that the editorObj is a scalar and not an array of
%  EditorDocuments.
 

%   Copyright 2009 The MathWorks, Inc.

if ~all(isa(editorObj, 'editorservices.EditorDocument'))
    error('MATLAB:editorservices:InvalidInput','The input must be an EditorDocument');
end

if ~all(editorObj.IsOpen)
    error('MATLAB:editorservices:EditorClosed', ...
        'The EditorDocument is not open. Create a new EditorDocument object using <a href="matlab:help editorservices.open">editorservices.open</a>.');
end

if ~all(isa(editorObj.LanguageObject, language))
    error('MATLAB:editorservices:InvaldiInput', 'The input object(s) must be a %s document(s).', language);
end

for i=1:length(varargin)    
    switch(varargin{i})
        case 'scalar'
            if numel(editorObj) ~= 1
                error('MATLAB:editorservices:NonScalarInput',...
                    'this operation only works on scalar EditorDocument objects.');
            end
    end
end

end


function objs = getAll
%editorservices.getAll() Identify all open Editor documents.
%   EDITOROBJS = editorservices.getAll returns an array of EditorDocument
%   objects corresponding to all documents open in the MATLAB Editor.
%
%   Example: List the file names of all open documents.
%
%      allDocs = editorservices.getAll;
%      allDocs.Filename 
%
%   See also editorservices.EditorDocument, editorservices.find, editorservices.getActive, editorservices.open..

% Copyright 2008-2009 The MathWorks, Inc.

objs = editorservices.EditorDocument.getAllOpenEditors;

% Attempt to verify that the Editor is "settled"
% Attempt at polling (might be able to solve this with making get 
% synchronous on the Java side
% Note: This only works for closing editors, not for newly opening ones
pause(1)
drawnow
reget = false;
if ~isempty(objs)
    for i = 1:length(objs)
        if ~objs(i).IsOpen
            reget = true;
        end
    end
end

if reget
    objs = editorservices.EditorDocument.getAllOpenEditors;
end

end
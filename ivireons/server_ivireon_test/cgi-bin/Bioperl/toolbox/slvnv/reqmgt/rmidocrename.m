function rmidocrename( model, old_doc, new_doc )
%
%RMIDOCRENAME Update model requirements document paths and file names.
%   RMIDOCRENAME(MODEL_HANDLE, OLD_PATH, NEW_PATH)
%   RMIDOCRENAME(MODEL_NAME, OLD_PATH, NEW_PATH)
%   
%   RMIDOCRENAME(MODEL_HANDLE, OLD_PATH, NEW_PATH) collectively
%   updates the links from a Simulink(R) model to requirements files whose
%   names or locations have changed. MODEL_HANDLE is a handle to the
%   model that contains links to the files that you have moved or renamed.
%   OLD_PATH is a string that contains the existing file name or path or 
%   a fragment of file name or path.
%   NEW_PATH is a string that contains the new file name, path or fragment.
%
%   RMIDOCRENAME(MODEL_NAME, OLD_PATH, NEW_PATH) updates the
%   links to requirements files associated with MODEL_NAME. You can pass
%   RMIDOCRENAME a model handle or a model name string.
%
%   When using the RMIDOCRENAME function, make sure to enter specific
%   strings for the old document name fragments so that you do not
%   inadvertently modify other links.
%
%   RMIDOCRENAME displays the number of links modified.
%
%   Examples:
%
%       For the current Simulink(R) model, update all links to requirements
%       files whose names contain the string 'project_0220', replacing 
%       with 'project_0221': 
%           rmidocrename(gcs, 'project_0220', 'project_0221');
%       
%       For the model whose handle is 3.0012, update links after all
%       documents were moved from C:\My Documents to D:\Documents
%           rmidocrename(3.0012, 'C:\My Documents', 'D:\Documents');
%
%
%   See also RMI
%
%   Copyright 2009-2010 The MathWorks, Inc.
%

if nargin ~= 3 || ~ischar(old_doc) || ~ischar(new_doc)
    error('slvnv:reqmgt:rmidocrename:USAGE', 'RMIDOCRENAME required arguments: model pattern_string replacement_string');
end

try
    modelH = rmisl.getmodelh(model);
catch Mex 
    error('slvnv:reqmgt:rmidocrename:NOMODEL', 'Could not resolve model: %s', model);
end
if ishandle(modelH)
    [ num_objects, modified, total ] = rmi.docRename(modelH, old_doc, new_doc);
    fprintf(1, 'Processed %d objects with requirements, %d out of %d links were modified.\n\n', ...
        num_objects, modified, total);
else
    error('slvnv:reqmgt:rmidocrename:NOMODEL', 'Failed to resolve model handle for %s', model);
end



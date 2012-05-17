classdef (Hidden) EditorUtils
    %EDITORUTILS Static utility methods for editorservices functions
    %
    %   This function is unsupported and might change or be removed without
    %   notice in a future version.
    
    % These are utility functions to be used by editorservices functions and is not meant to be
    % called by users directly.
    
    % Copyright 2009 The MathWorks, Inc.
    
    methods (Access = private)
        function obj = EditorUtils
            obj = [];
        end
    end
    
    methods (Static)
        function F = fileNameToJavaFile(filename)
            %fileNameToJavaFile converts a string file name to java.io.File object
            
            F = java.io.File(filename);
        end
        
        function tf = isAbsolutePath(filename)
            %isAbsolutePath tests if the specified string is an absolute path
            javaFile = editorservices.EditorUtils.fileNameToJavaFile(filename);
            tf = javaFile.isAbsolute;
        end
        
        function storageLocation = fileNameToStorageLocation(filename)
            %fileNameToStorageLocation converts a string file name to a StorageLocation object
            storageLocation = com.mathworks.widgets.datamodel.FileStorageLocation(filename);
        end
        
        function jea = getJavaEditorApplication
            %getJavaEditorApplication returns the Java Editor application
            jea = com.mathworks.mlservices.MLEditorServices.getEditorApplication;
        end
        
        cellArray = javaCollectionToArray(javaCollection)
    end
    
end


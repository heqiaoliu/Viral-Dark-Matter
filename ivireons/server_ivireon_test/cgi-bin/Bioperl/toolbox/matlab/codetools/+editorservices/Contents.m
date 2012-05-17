% EDITORSERVICES Summary of Editor services functionality
% Programmatically access the MATLAB Editor to open, change, save, or close
% documents.
%
% MATLAB Version 7.11 (R2010b) 03-Aug-2010 
%
% Work with all documents currently open in the Editor:
%   closeGroup          - Close Editor and all open documents. 
%   getAll              - Identify all open Editor documents.
%
% Work with single document currently open in the Editor:
%   getActive           - Find active Editor document.
%   getActiveFilename   - Find file name of active document.
%   find                - Create EditorDocument object for an open document.
%   isOpen              - Determine whether specified file is open in Editor.
%
% Open an existing document or create a new one:
%   new                 - Create document in Editor. 
%   open                - Open file in Editor.
%   openAndGoToFunction - Open MATLAB file and highlight specified function.
%   openAndGoToLine     - Open file and highlight specified line.

%   Copyright 2008-2010 The MathWorks, Inc. 
%   Generated from Contents.m_template revision 1.1.8.1  $Date: 2009/12/31 18:51:14 $
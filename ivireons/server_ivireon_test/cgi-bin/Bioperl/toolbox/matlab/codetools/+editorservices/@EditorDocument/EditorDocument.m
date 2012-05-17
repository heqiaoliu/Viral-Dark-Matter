classdef (Sealed) EditorDocument < handle
%editorservices.EditorDocument  Access documents in the MATLAB Editor.
%   The editorservices package provides programmatic access to the Editor.
%   Create EditorDocument objects to open, close, change, or check the 
%   status of files in the Editor.  Each EditorDocument object corresponds
%   to an open Editor document.
%
%   To create EditorDocument objects, use any of the following
%   editorservices package functions:
%
%      editorservices.find                - Find document already opened
%      editorservices.getActive           - Return the topmost document
%      editorservices.getAll              - Return all open documents
%      editorservices.new                 - Create a document
%      editorservices.open                - Open an existing file
%      editorservices.openAndGoToLine     - Open a file and highlight line
%      editorservices.openAndGoToFunction - Open a file and highlight
%                                           function (MATLAB code only)
%   Methods:
%   EditorDocument methods do not require that the document you access is
%   the active (topmost) buffer in the Editor group. However, the methods 
%   do require that the document is already open in the Editor. Only the
%   makeActive method brings a document to the front of the Editor group.
%
%      appendText        - Add text to end of document
%      close             - Close document
%      closeNoPrompt     - Close and discard unsaved changes
%      goToLine          - Move cursor to specified line
%      goToLineAndColumn - Move cursor to specified line and column
%      insertText        - Insert text at specified location
%      makeActive        - Make document active (bring to top of group)
%      reload            - Revert to saved version of document
%      save              - Save document
%      setdiff           - Compare lists of Editor documents
%
%   Properties:
%   When you work interactively in the Editor to update documents, you
%   change the properties of the associated EditorDocument objects. Always
%   get property values immediately before using them.  All properties are
%   read-only except Text.
%
%      Filename    - Full path
%      IsDirty     - Whether there are unsaved changes (TRUE or FALSE)
%      IsOpen      - Whether the document is open (TRUE or FALSE)
%      Language    - Programming language associated with document
%      Text        - Text in document
%
%   Example:  Create a document in the Editor and add text.  View the
%   properties of the EditorDocument object.
%
%      newDoc = editorservices.new;
%      newDoc.Text = 'Sample text in new document.';
%
%      % View properties of newDoc
%      newDoc
%
%   See also editorservices.

%   Copyright 2008-2010 The MathWorks, Inc.

    properties (SetAccess = private, Dependent = true)
        %Filename - Full path of file associated with EditorDocument object.
        %
        %   For new, unsaved documents, Filename is 'Untitled' or 'UntitledN',
        %   where N is an integer.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated EditorDocument objects. Always
        %   get property values immediately before using them.
        Filename;
        %Language - Programming language associated with EditorDocument object.
        %
        %   MATLAB determines Language from the file extension, if specified, and
        %   the language associated with that extension in the Preferences
        %   settings. If your Preferences do not include the specified extension,
        %   Language is 'Plain' (plain text).
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated EditorDocument objects. Always
        %   get property values immediately before using them.
        Language;
        %IsDirty - Whether the EditorDocument instance contains unsaved changes.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated EditorDocument objects. Always
        %   get property values immediately before using them.
        IsDirty;
        %IsOpen - Whether the Editor document is open.
        %
        %   If IsOpen is FALSE, the EditorDocument object is invalid.  All
        %   EditorDocument methods assume that IsOpen is TRUE.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated EditorDocument objects. Always
        %   get property values immediately before using them.
        IsOpen;
        %SelectedText - the text of the document currently selected.
        SelectedText;
    end
    
    properties (SetAccess = public, Dependent = true)
        %Text - Text in the EditorDocument buffer.
        %
        %   To add text that contains single quotation marks, include an additional
        %   quotation mark.  For example, create a document that contains
        %   disp('Hello'):
        %           myDoc = editorservices.new('disp(''Hello'')');
        %
        %   To add a new line, use 10.  For example, add a line terminator and a
        %   call to the BEEP command to myDoc:
        %          myDoc.appendText([10 'beep']);
        %
        %   Before saving a new document, the line terminator 10 is equivalent to
        %   the '\n' escape sequence. On Windows systems only, when you save the
        %   new document, MATLAB converts line terminators to the '\r\n' escape
        %   sequence. This conversion allows all Windows text editors, including
        %   Microsoft Notepad, to read the file. Line terminators added after
        %   saving are equivalent to '\r\n'.
        %
        %   If you open an existing file and add a line terminator, MATLAB matches
        %   the line terminators in the file ('\n' or '\r\n'), regardless of
        %   operating system.
        %
        %   When you work interactively in the Editor to update documents, you
        %   change the properties of the associated EditorDocument objects. Always
        %   get property values immediately before using them.
        Text;
        %Selection - the start and end positions of the selection in the document.
        %
        %   The positions represent the linear character position of the
        %   start and end. If the two positions are the same then there is
        %   no selection. The selection index is 1-based. Starting the
        %   selection at the first character has a start position of
        %   1. The end position is up to but not including the end index.
        %   Set the end index to the desired character + 1;
        %   For example to select the first three chracters, Selection = [1 4];
        %        
        %   Setting the end position before the start puts the end position
        %   the same as the start position. If the start position is set
        %   less than 1, it will start at 1. If the end position is placed
        %   at beyond the length of the text + 1, it will end at the length
        %   of the the text + 1;
        %
        %   Selection can also be set by providing line and column numbers
        %   Selection = [startLine startColumn endLine endColumn]. To
        %   select a whole line, provide 1 as the startColumn and Inf as
        %   the endColumn.
        Selection;
        %Editable - makes the buffer editable or uneditable. 
        %
        % The Editable state determines whether the user can type into the
        % Editor or modify the text programmatically. A buffer's Editable
        % state does not affect the writeable status of the file. 
        Editable;
    end

    properties (SetAccess = private, Hidden = true)
        %JavaEditor the corresponding Java Editor object
        JavaEditor;
    end    
    
    properties (SetAccess = private, Hidden, Dependent)
        %LanguageObject the java object representing the EditorDocument's programming language
        LanguageObject;
    end
    
    methods (Access = private, Hidden = true)
        function obj = EditorDocument(JavaEditor)
        %EditorDocument Constructor for the EditorDocument class
        %   OBJ = EditorDocument(JAVAEDITOR) if INPUT is a string, assume a filename
        %   otherwise assume that we've been given a Java Editor object
            if isempty(JavaEditor)
                error('MATLAB:editorservices:EmptyEditor','Invalid Java editor specified.');
            end
            obj.JavaEditor = JavaEditor;
        end    
    end
    
    %% Static constructors
    %These should only be called from editorservices functions
    methods (Static, Hidden)
        function obj = findEditor(fname)
            %findEditor Returns an EditorDocument instance for the matched filename 
            %
            % This is a private constructor method to be used from editorservices.find(filename).
            %
            % It is an error to use this function to find an unopened EditorDocument.
            %
            % EditorDocument = findEditor(filename) for a given filename, returns the EditorDocument
            % object that corresponds to the open file. This expects a fully qualified path with the
            % file, but still tries to find the EditorDocument if it is a partial path by matching
            % the specified filename to the names of the open documents. If a match is found, a
            % MATLAB:editorservices:PartialPath warning will be thrown, otherwise an empty
            % EditorDocument will be returned.
            %
            % See also editorservices.find.
            if nargin < 1 || isempty(fname)
                error('MATLAB:editorservices:NoFilename', ...
                      'A filename must be provided to get an EditorDocument');
            end
            
            jea = editorservices.EditorUtils.getJavaEditorApplication;
            
            if editorservices.EditorUtils.isAbsolutePath(fname) 
                fileStorageLocation = editorservices.EditorUtils.fileNameToStorageLocation(fname);
                je = jea.findEditor(fileStorageLocation);
                if isempty(je)
                    obj = editorservices.EditorDocument.empty(1,0);
                else                
                    obj = editorservices.EditorDocument(je);
                end
            else 
                % This means that there was a path, it wasn't absolute though
                partialEditor = matchname(fname);
                if isempty(partialEditor)
                    obj = editorservices.EditorDocument.empty(1,0);
                else
                    obj = partialEditor;
                end
            end
        end
        
        function obj = openEditor(fname)
            %openEditor Tries to open the named file in the Editor
            % This is a private constructor method to be used from editorservices.open(filename).
            %
            % EditorDocument = openEditor(filename) for a given filename, returns the EditorDocument
            % object that corresponds to the open file. This requires a fully qualified path with
            % the file, otherwise a MATLAB:editorservices:PartialPath will be thrown. If the file
            % does not exist, an exception will be also be thrown.
            %
            % See also editorservices.open.
            if ~editorservices.EditorUtils.isAbsolutePath(fname)
                error('MATLAB:editorservices:PartialPath',...
                    'Open requires that ''%s'' be an absolute path.', fname);
            end
            
            jea = editorservices.EditorUtils.getJavaEditorApplication;
            javaEditor = jea.openEditor(editorservices.EditorUtils.fileNameToJavaFile(fname));
            
            if isempty(javaEditor)
                obj = editorservices.EditorDocument.empty(1,0);
            else
                obj = editorservices.EditorDocument(javaEditor);            
            end
        end
    end
    
    %% Static accessesor methods
    % These methods are used by editorservices to obtain information about existing editors, but
    % because the return type is an EditorDocument, they need to access the constructor.
    methods (Static, Hidden)
        function objs = getAllOpenEditors
        %getAllOpenEditors Returns a list of all the open Editors
            jea = editorservices.EditorUtils.getJavaEditorApplication;
            jEditors = jea.getOpenEditors;            
            editors = editorservices.EditorUtils.javaCollectionToArray(jEditors);               
            objs = editorservices.EditorDocument.empty(0,length(editors));
            for i=1:length(editors)
                objs(i) = editorservices.EditorDocument(editors{i});
            end
        end
        
        function obj = getActiveEditor
        %getActiveEditor returns an EditorDocument object for the active editor
            jea = editorservices.EditorUtils.getJavaEditorApplication;
            je = jea.getActiveEditor;
            if isempty(je)
                obj = editorservices.EditorDocument.empty(1,0);
            else
                obj = editorservices.EditorDocument(je);
            end            
        end
        
        function obj = new(bufferText)
            %NEW Creates a new document with the specified text and returns
            %an EditorDocument object which would be the reference to that untitled
            %object
            
            jea = ...
                editorservices.EditorUtils.getJavaEditorApplication;            
            javaEditor = jea.newEditor(bufferText);
            obj = editorservices.EditorDocument(javaEditor);
        end
    end    
    
    %% Public instance methods
    methods
        function save(obj)
            %SAVE Save document in Editor.
            %   EDITOROBJ.SAVE saves the contents of the open document associated with
            %   EDITOROBJ. The SAVE method writes to the file only when the document
            %   contains unsaved changes (that is, the EDITOROBJ.IsDirty property is
            %   TRUE).
            %
            %   Notes:
            %   * If EDITOROBJ represents an untitled buffer, MATLAB displays a dialog
            %     box to specify the file name.
            %   * If the associated file is read only, MATLAB displays a dialog box to
            %     create a file or overwrite the original file.
            %   In either case, the SAVE method does not resume until you interactively
            %   close the dialog box.
            %
            %   Example: Create a new, untitled document, and attempt to save. When the
            %   dialog appears, specify a file name or click CANCEL to abort.
            %
            %      tempDoc = editorservices.new('% Test document');
            %      tempDoc.save;
            %
            %   See also editorservices.EditorDocument/close, editorservices.EditorDocument.isDirty, editorservices.EditorDocument/reload.
            for i=1:numel(obj)
                obj(i).JavaEditor.negotiateSave;
            end
        end
        
        function goToLine(obj, line)
            %goToLine Move cursor to specified line in Editor document.
            %   EDITOROBJ.goToLine(LINENUMBER) moves the cursor to the beginning of
            %   the specified line of an open document in the MATLAB Editor, and
            %   highlights the line. EDITOROBJ is a scalar EditorDocument object
            %   associated with the open document. If LINENUMBER is past the end of
            %   the document, goToLine places the cursor at the last line. goToLine
            %   does not bring the document to the top of the Editor group.
            %
            %   Example: Go to the 20th line of the active Editor document.
            %
            %      activeDoc = editorservices.getActive;
            %      if ~isempty(activeDoc)
            %          activeDoc.goToLine(20);
            %      end
            %
            % See also editorservices.matlab.goToFunction, editorservices.open, editorservices.openAndGoToFunction, editorservices.openAndGoToLine, editorservices.EditorDocument/goToLineAndColumn, editorservices.EditorDocument/makeActive.
            assertScalar(obj);
            assertOpen(obj);
            
            % the java method goToLine(int, boolean) goes to the line and highlights
            obj.JavaEditor.goToLine(line, true);
        end
        
        function goToLineAndColumn(obj, line, column)
            %goToLineAndColumn Move to specified line and column in Editor document.
            %   EDITOROBJ.goToLineAndColumn(LINE, COLUMN) moves the cursor to the
            %   specified line and column of an open document in the MATLAB Editor.
            %   EDITOROBJ is a scalar EditorDocument object associated with the open
            %   document. If LINE or COLUMN is out of the range of the document,
            %   goToLineAndColumn places the cursor at the closest valid position.
            %   goToLineAndColumn does not bring the document to the top of the Editor
            %   group.
            %
            %   Example: Go to the 20th line and 11th column of the active document.
            %
            %      activeDoc = editorservices.getActive;
            %      if ~isempty(activeDoc)
            %          activeDoc.goToLineAndColumn(20,11);
            %      end
            %
            %   See also editorservices.matlab.goToFunction, editorservices.open, editorservices.openAndGoToFunction, editorservices.openAndGoToLine, editorservices.EditorDocument/goToLine, editorservices.EditorDocument/makeActive.
            assertScalar(obj);
            assertOpen(obj);

            %The method goToLine(int, int) goes to the specified line and column
            obj.JavaEditor.goToLine(line, column);
        end
        
        function close(obj)
            %close() Close document in MATLAB Editor.
            %   EDITOROBJ.close closes the MATLAB Editor buffer and pane
            %   corresponding to the EditorDocument object EDITOROBJ.  Closing
            %   invalidates EDITOROBJ.
            %
            %   If the buffer contains unsaved changes (that is, the EDITOROBJ.IsDirty
            %   property is TRUE), MATLAB displays a dialog box that provides the
            %   option to save.  In this case, the CLOSE method does not resume until
            %   you click YES or NO to save or discard the changes. Clicking CANCEL
            %   ends the operation and does not close the Editor buffer.
            %
            %   Example:
            %   Create a file in the Editor. Add text without saving, and attempt to
            %   close the file. When the confirmation dialog appears, click YES or NO
            %   to save or discard the buffer contents. Alternatively, click CANCEL to
            %   abort the operation.
            %
            %      newDoc = editorservices.new('This is a test.');
            %      newDoc.close;
            %
            %   See also editorservices.EditorDocument/closeNoPrompt, editorservices.closeGroup, editorservices.EditorDocument.isDirty, editorservices.EditorDocument/reload, editorservices.EditorDocument/save.
            for i=1:numel(obj)
                obj(i).JavaEditor.close;
            end
        end
        
        function closeNoPrompt(obj)
            %closeNoPrompt() Close document in Editor, discarding unsaved changes.
            %   EDITOROBJ.closeNoPrompt() closes the MATLAB Editor buffer and pane
            %   corresponding to the EditorDocument object EDITOROBJ. The closeNoPrompt
            %   method discards any unsaved changes to the document, and does not
            %   display a confirmation dialog box. Closing the buffer invalidates the
            %   associated EDITOROBJ.
            %
            %   Example: Create a file in the temporary folder for your system. Save
            %   its initial contents. Add text without saving, and close.
            %
            %      tempfile = [tempname '.m'];
            %      newDoc = editorservices.open(tempfile);
            %
            %      if editorservices.isOpen(tempfile)
            %          newDoc.appendText('% Testing CloseNoPrompt');
            %          newDoc.save;
            %
            %          newDoc.appendText('... will discard this text');
            %          newDoc.closeNoPrompt;
            %
            %          % View the contents of the file
            %          type(tempfile)
            %      end
            %
            %   See also editorservices.closeGroup, editorservices.EditorDocument/close.
            for i=1:numel(obj)
                obj(i).JavaEditor.closeNoPrompt;
            end
        end
        
        function reload(obj)
            %RELOAD Revert to saved version of Editor document.
            %   EDITOROBJ.RELOAD replaces the contents of an open document in the
            %   MATLAB Editor with the saved version of the file. EDITOROBJ is an
            %   EditorDocument object associated with the open document. If you attempt
            %   to reload an untitled buffer, MATLAB displays an error dialog box.
            %
            %   Example: Create and save a file in the temporary folder on your system.
            %   Modify the document, but do not save the changes. Reload the file.
            %
            %      tempfile = [tempname '.m'];
            %      tempDoc = editorservices.open(tempfile);
            %
            %      if editorservices.isOpen(tempfile)
            %          tempDoc.appendText('% Testing reload');
            %          tempDoc.save;
            %          tempDoc.appendText(' ... will discard this text');
            %
            %          % View contents before reload
            %          disp('Before reload:');
            %          tempDoc.Text
            %
            %          tempDoc.reload;
            %
            %          % View contents after reload
            %          disp('After reload:');
            %          tempDoc.Text
            %      end
            %
            %   See also editorservices.new, editorservices.open.
            assertOpen(obj);
            for i=1:numel(obj)
                obj(i).JavaEditor.reload;
            end  
        end
                        
        function appendText(obj, textToAppend)
            %appendText Append text to document in Editor.
            %   EDITOROBJ.appendText(TEXT) adds the specified text to the end of the
            %   open document associated with the scalar EditorDocument object
            %   EDITOROBJ.
            %
            %   Example: Create a document and append a line of text.
            %
            %      newline = 10;
            %      newDoc = editorservices.new('Initial text in new document');
            %      newDoc.appendText([newline 'Appended text']);
            %
            %   See also editorservices.EditorDocument/close, editorservices.new, editorservices.open, editorservices.EditorDocument/insertText, editorservices.EditorDocument/save.            
            assertScalar(obj);
            assertOpen(obj);
            assertEditable(obj);
            obj.JavaEditor.appendText(textToAppend);
        end
        
        function set.Text(obj, textToSet)
            %set.Text sets the text in the EditorDocument's buffer
            assertScalar(obj); 
            assertOpen(obj);
            assertEditable(obj);
            obj.JavaEditor.setSelection(0,obj.JavaEditor.getLength)
            obj.JavaEditor.insertTextAtCaret(textToSet);
        end
        
        function makeActive(obj)
            %makeActive() Make document active in MATLAB Editor.
            %   EDITOROBJ.makeActive() brings the document associated with the scalar
            %   EditorDocument object EDITOROBJ to the top of the MATLAB Editor group,
            %   making the document active.
            %
            %   Example: Open several files and bring fft.m to the front of the Editor
            %   group.
            %
            %      fft = editorservices.open(which('fft.m'));
            %      fftn = editorservices.open(which('fftn.m'));
            %      fftw = editorservices.open(which('fftw.m'));
            %      fft.makeActive;
            %
            %   See also editorservices.getActive, editorservices.open.
            assertScalar(obj);            
            obj.JavaEditor.bringToFront;
        end
        
        function newObjs = setdiff(newObjsList, originalObjList)
            %setdiff Compare lists of Editor documents.
            %   NEWOBJECTS = SETDIFF(NEWLIST, ORIGLIST) returns an array of
            %   EditorDocument objects that are in NEWLIST, but not in ORIGLIST.
            %
            %   Example: Get a list of all open documents in the Editor. Open an
            %   additional document. Identify the new document.
            %
            %      originalSet = editorservices.getAll;
            %      fft = editorservices.open(which('fft.m'));
            %      laterSet = editorservices.getAll;
            %
            %      newDocs = setdiff(laterSet, originalSet);
            %
            %      % List the files associated with new documents
            %      if ~isempty(newDocs)
            %         disp('New documents opened:');
            %         for k = 1:length(newDocs)
            %             newDocs(k).Filename
            %         end
            %      end
            %
            %   See also editorservices.getAll.
            newObjs = editorservices.EditorDocument.empty(1,0);
            for i = 1:numel(newObjsList)
                currentNewEditor = newObjsList(i);
                if ~ismember(currentNewEditor, originalObjList)
                    newObjs(end+1) = currentNewEditor; %#ok<AGROW>
                end
            end
        end
        
        function filename = get.Filename(obj)
            try
                if ~obj.JavaEditor.isBuffer
                    storageLocation = obj.JavaEditor.getStorageLocation;
                    filename = char(storageLocation.getFile);
                else
                    filename = char(obj.JavaEditor.getShortName);
                end
            catch ex %#ok<NASGU>
                filename = '';
            end
        end
        
        function text = get.Text(obj)
            assertOpen(obj);
            text = cell(size(obj));
            for i=1:numel(obj)
                text{i} = char( obj(i).JavaEditor.getText );
            end
            
            if numel(obj) == 1
                text = text{1};
            end            
        end
        
        function position = get.Selection(obj)
            assertOpen(obj);
            javaTextPane = obj.JavaEditor.getComponent.getEditorView.getSyntaxTextPane;
            position = [javaTextPane.getSelectionStart + 1 javaTextPane.getSelectionEnd + 1];
        end
        
        function set.Selection(obj, position)
            assertScalar(obj); 
            assertOpen(obj);
            
            javaTextPane = obj.JavaEditor.getComponent.getEditorView.getSyntaxTextPane;
            switch length(position) 
                case 2
                    startPos = max(0, position(1) - 1);
                    endPos = min(length(obj.Text), position(2) - 1);
                case 4
                    startLine = limitline(position(1));
                    endLine = max(startLine, limitline(position(3)));                    
                    
                    startPos = javaTextPane.getLineStart(startLine);
                    endPos = javaTextPane.getLineStart(endLine);                    
                    
                    startCol = limitCol(startLine, startPos, position(2));
                    endCol = limitCol(endLine, endPos, position(4));
                    
                    startPos = startPos + startCol;
                    endPos = endPos + endCol;
                otherwise
                error('MATLAB:editorservices:InvalidSelection',...
                    'Selection values must be either [startPosition endPosition] or [startLine startColumn endLine endColumn]');
            end
            
            javaMethodEDT('setSelectionStart', javaTextPane, startPos);
            javaMethodEDT('setSelectionEnd', javaTextPane, endPos);
            
            function x = limitline(x)
                %convert from one-based (MATLAB API) to zero-based line
                %numbers (Java API)
                x = max(1, x);
                x = min(javaTextPane.getNumLines, x) - 1;
            end
            function col = limitCol(line, linePos, col)
                col = col - 1;
                col = max(0, col);
                col = min(javaTextPane.getLineEnd(line) - linePos, col);
            end
        end
        
        
        function text = get.SelectedText(obj)
            assertOpen(obj);
            text = char(obj.JavaEditor.getSelection);
        end
        
        function editable = get.Editable(obj)
            assertOpen(obj);
            editable = obj.JavaEditor.isEditable;
        end
        
        function set.Editable(obj, editable)
            assertOpen(obj);
            
            if length(editable) == 1
                %share the same editable state among all the
                %EditorDocuments in the array
                editable = repmat(editable,1,length(obj));
            end
            if length(editable) ~= length(obj)
                error('MATLAB:editorservices:InvalidDimension', 'Either specify one value or one value per EditorDocument object');
            end
            
            for i=1:length(obj)
                obj(i).JavaEditor.setEditable(editable(i));                
            end
        end
        
        function lang = get.Language(obj)
            assertOpen(obj);
            lang = char(obj.LanguageObject.getName);
        end
        
        function langObj = get.LanguageObject(obj)
            assertOpen(obj);
            langObj = obj.JavaEditor.getLanguage;
        end
        
        function insertText(obj, text, position)
            %insertText Insert text in Editor document.
            %   EDITOROBJ.insertText(TEXT, POSITION) inserts text at the specified
            %   position into the open document associated with the scalar
            %   EditorDocument object EDITOROBJ. The POSITION represents the number of
            %   characters from the beginning of the document, including line break
            %   characters. To insert text at the beginning of the document, specify a
            %   POSITION of 0.
            %
            %   Example:  Create a document and insert text.
            %
            %      newline = 10;
            %
            %      % Start with two lines of text
            %      firstline = ['First line of text' newline];
            %      secondline = ['Second line of text'];
            %      newDoc = editorservices.new([firstline secondline]);
            %
            %      % Insert a new line after the first
            %      newtextPos = length(firstline);
            %      newtext = ['Insert this line' newline];
            %      newDoc.insertText(newtext, newtextPos);
            %
            %   See also editorservices.EditorDocument/appendText, editorservices.new.
            obj.JavaEditor.setCaretPosition(position);
            obj.JavaEditor.insertTextAtCaret(text);
        end
        
        function isopen = get.IsOpen(obj)
            isopen = false(size(obj));
            for i=1:numel(obj)
                isopen(i) = logical(obj(i).JavaEditor.isOpen);
            end
        end
        
        function bool = get.IsDirty(obj)
            assertOpen(obj);
            bool = false(size(obj));
            for i=1:numel(obj)
                bool(i) = obj(i).JavaEditor.isDirty;
            end
        end
               
        function bool = eq(obj1, obj2)
            %eq Overloads the == operator to compare two EditorDocumentObjects
            %
            %This method returns true if the two EditorDocument objects refer to the same open
            %window in the MATLAB editor.
            
            %only compute equals if one of the obj1s is scalar or both are same size
            n1 = numel(obj1);
            n2 = numel(obj2);
            if n1 ~= 1 && n2 ~= 1 && any(size(obj1) ~= size(obj2))
                error('MATLAB:dimagree','Matrix dimensions must agree.');
            end
            
            %make sure that either of the objects is not empty
            if isempty(obj1) || isempty(obj2)
                bool = false;
            else
                
                %loop over the larger array
                if n2 > n1
                    bool = loopEq(obj2, obj1);
                else
                    bool = loopEq(obj1, obj2);
                end
            end
            
            
            function bool = loopEq(obj1, obj2)
                bool = false(size(obj1));
                num2 = numel(obj2);
                for i=1:numel(obj1);
                    if num2 > 1
                        je2 = obj2(i).JavaEditor;
                    else
                        je2 = obj2.JavaEditor;
                    end
                    bool(i) = obj1(i).JavaEditor == je2;
                end
            end
            
        end
        
        function bool = isequal(obj1, obj2)
            %test two (possibly arrays of) EditorDocuments for equality
            bool = isequal(size(obj1),size(obj2)) && all(eq(obj1, obj2));
        end
    end    
    
end

function assertScalar(obj)
if numel(obj) ~= 1
    error('MATLAB:editorservices:NonScalarInput',...
        'This method only works on scalar EditorDocument objects.');
end
end

function assertOpen(obj)
if ~all(obj.IsOpen)
    error('MATLAB:editorservices:EditorClosed', ...
        'The EditorDocument is not open. Create a new EditorDocument object using <a href="matlab:help editorservices.open">editorservices.open</a>.');
end
end

function assertEditable(obj)
if ~all(obj.Editable)
    error('MATLAB:editorservices:Uneditable', ...
        'The EditorDocument is not editable. Set the EditorDocument to editable using the <a href="matlab:help editorservices.EditorDocument.Editable">EditorDocument.Editable</a> property.');
end
end

function match = matchname(fname)
%MATCHNAME Scaffolding, here to allow for an easier transition to the new Editor API, this should
%not be in the final version of the code
match = '';
editors = editorservices.EditorDocument.getAllOpenEditors;
for i = 1:length(editors)
    currentname = editors(i).Filename;
    if ~isempty(currentname) && ~isempty(strfind(currentname, fname))
        match = editors(i);
        break
    end
end
end

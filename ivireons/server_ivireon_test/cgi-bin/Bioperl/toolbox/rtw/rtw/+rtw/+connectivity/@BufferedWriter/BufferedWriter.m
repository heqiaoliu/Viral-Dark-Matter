classdef (Hidden = true) BufferedWriter < handle
%BUFFEREDWRITER is a buffered file writer 
%   Includes support for nested indentation.
%
%   This is an undocumented class. Its methods and properties are likely to
%   change without warning from one release to the next.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

    % private properties
    properties (SetAccess = 'private', GetAccess = 'private')
       bufferedWriter;         
       indentSpaces = 3;
       indentLevel = 0;
       isNewLine = true;
    end
    
    methods
        % constructor
        function this = BufferedWriter(fileName, ...
                                       append)
            error(nargchk(1, 2, nargin, 'struct'));
            rtw.connectivity.Utils.validateArg(fileName, 'char');
            if nargin > 1                                
                rtw.connectivity.Utils.validateArg(append, 'logical');
            else
                % default is to re-write the file
                append = false;
            end
            % create Java objects
            try
                fWriter = java.io.FileWriter(fileName, append);
                this.bufferedWriter = java.io.BufferedWriter(fWriter);                        
            catch javaE
                e = MException('Target:BufferedWriter:CreateObjects', ...
                                'Could not open file "%s" for writing.', ...
                                fileName);
                e = addCause(e, javaE);
                throw(e);                
            end
        end
        
        % clean up on destruction
        function delete(this)
           this.close;
        end

        % set the number of indentation spaces to use at each 
        % indentation level
        function setIndentSpaces(this, indentSpaces)
           this.indentSpaces = indentSpaces; 
        end
        
        % increment the indentation level
        function incIndent(this)
           this.indentLevel = this.indentLevel + 1; 
        end
        
        % decrement the indentation level
        function decIndent(this)
            this.indentLevel = this.indentLevel - 1;
            if this.indentLevel < 0
               this.indentLevel = 0; 
            end
        end
        
        % flush the buffer to the file and close the file
        function close(this)
            try
                this.bufferedWriter.close;
            catch javaE
                e = MException('Target:BufferedWriter:Close', ...
                                'Could not close the file.');
                e = addCause(e, javaE);
                throw(e);                
            end                 
        end
        
        % flush the buffer to the file
        function flush(this)
            try
                this.bufferedWriter.flush;
            catch javaE
                e = MException('Target:BufferedWriter:Flush', ...
                                'Could not flush the file.');
                e = addCause(e, javaE);
                throw(e);                
            end
        end
        
        % write string to buffer, indenting according to the current
        % indentation level if at the start of a new line
        function write(this, string)
           this.indent;
           this.pWrite(string);
        end

        % write string to buffer, indenting according to the current
        % indentation level if at the start of a new line, and terminating
        % with a new line.
        function writeLine(this, string)
            this.write(string);
            this.newLine;
        end

        % write each string of the cell array to the buffer, 
        % indenting according to the current indentation level if at the
        % start of a new line, and terminating with a new line.
        function writeCellLines(this, cellLines)
            for i=1:length(cellLines)
                this.writeLine(cellLines{i});                                
            end
        end
        
        % write a new line character to the buffer
        function newLine(this)
           try
               this.bufferedWriter.newLine;
           catch javaE
                e = MException('Target:BufferedWriter:Newline', ...
                    'Could not write newline to file.');
                e = addCause(e, javaE);
                throw(e);
           end
           this.isNewLine = true;
        end
    end
    
    methods (Access = 'private')        
        % private function to write the indentation amount for new lines
        function indent(this)            
            if this.isNewLine
                this.isNewLine = false;
                indentStr = repmat(' ', 1, this.indentSpaces * this.indentLevel);
                this.pWrite(indentStr);
            end
        end
        
        % private function to perform low level string write to the buffer
        function pWrite(this, string)
            try
               this.bufferedWriter.write(string); 
            catch javaE
                e = MException('Target:BufferedWriter:pWrite', ...
                    'Could not write to file.');
                e = addCause(e, javaE);
                throw(e);
            end
        end
    end
end

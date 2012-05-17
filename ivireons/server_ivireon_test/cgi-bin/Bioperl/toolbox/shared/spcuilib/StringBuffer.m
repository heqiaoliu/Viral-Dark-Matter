classdef StringBuffer < handle
% StringBuffer Return a StringBuffer object.
%   StringBuffer provides services to assemble sequences of strings
%   into a single text buffer.
%
%   S=StringBuffer returns an empty StringBuffer object, while
%   S=StringBuffer(T) adds string T to the buffer during construction.
%
%   StringBuffer methods:
%       add      - Concatenate string to end of string buffer.
%       addcr    - Adds string with a carriage-return (CR) after it.
%       cradd    - Adds string with a carriage-return before it.
%       craddcr  - Adds string with a carriage-return before and after.
%       insert   - Insert a string into buffer.
%       clear    - Clear string buffer, resetting its length to zero.
%       char     - Return buffer contents as a character string.
%       string   - Return buffer contents as a string.
%       chars    - Number of characters in string buffer.
%       lines    - Number of lines of text in string buffer.
%       edit     - Copy buffer contents into the MATLAB Editor.
%       write    - Write buffer contents to a text file.
%       readfile - Replace string buffer contents with text from a file.
%
%   StringBuffer public fields:
%       Indent   - Number of spaces to indent after a carriage return.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/30 23:59:01 $

     properties
         % Number of spaces to indent prior to text additions made after
         % a carriage return.  Indentation only occurs when using the add,
         % addcr, cradd, and craddcr methods.
         Indent = 0
     end
     
    properties (Access=private)
        % Buffer is private and should only be accessed through methods.
        Buffer = ''  % Row vector of chars
    end
    
    properties (SetAccess=protected)
        % Subclasses can change the private definition of the Carriage
        % Return (CR) character.
        CR = sprintf('\n')
    end
    
    methods
        function S = StringBuffer(varargin)
            % Return a StringBuffer object.
            %
            % S=StringBuffer returns an empty StringBuffer object.
            % S=StringBuffer(T) adds string T to the buffer by invoking
            %   the method add(S,T) automatically.

            if nargin>0
                S.add(varargin{:});
            end
        end
        
        function set.Indent(S,V)
            if V<0 || V~=fix(V) || isinf(V)
                error('spcuilib:StringBuffer:Indent:InvalidValue', ...
                'Indent property must be a finite, non-negative integer.');
            end
            S.Indent = V;
        end
        
        function add(S,varargin)
            % Concatenate string to end of string buffer.
            %   add(S) leaves the buffer S unchanged.
            %   add(S,T) adds string T to the end of buffer S.
            %   add(S,F,V1,V2, ...) adds format string F to buffer S,
            %      using variables V1, V2, etc, as appropriate.
            if nargin==2
                S.Buffer = [S.Buffer IndentStr(S) varargin{1}];
            elseif nargin>2
                % Could fail - allow that without try/catch
                % Keeps performance high
                S.Buffer = [S.Buffer IndentStr(S) sprintf(varargin{:})];
            end
        end
        
        function addcr(S,varargin)
            % Adds string with a carriage-return (CR) after it.
            %   addcr(S) adds a CR to string buffer S.
            %   addcr(S,T) adds string T to buffer S followed by a CR.
            %   addcr(S,F,V1,V2,...) adds format string F to buffer S,
            %      using variables V1, V2, etc, as appropriate, then adds
            %      a CR.
            
            if nargin<2
                S.Buffer = [S.Buffer S.CR];
            elseif nargin==2
                S.Buffer = [S.Buffer IndentStr(S) varargin{1} S.CR];
            else
                S.Buffer = [S.Buffer IndentStr(S) sprintf(varargin{:}) S.CR];
            end
        end
        
        function t = char(S)
            % Return buffer contents as a character string.
            t = S.Buffer;
        end
        
        function N = chars(S)
            % Number of characters in string buffer.
            N = length(S.Buffer);
        end
        
        function clear(S)
            % Clear string buffer, resetting its length to zero.
            S.Buffer = '';
        end
        
        function cradd(S,varargin)
            % Adds string with a carriage-return (CR) before it.
            %   cradd(S) adds a CR to string buffer S.
            %   cradd(S,T) adds string T to buffer S, preceded by a CR.
            %   cradd(S,F,V1,V2,...) adds format string F to buffer S,
            %      preceded by a CR.

            % Put CR into the buffer first, so IndentStr will "see" the
            % CR and do the indent for us properly.
            S.Buffer = [S.Buffer S.CR];
            if nargin<2
                % Nothing more to do
            elseif nargin==2
                S.Buffer = [S.Buffer IndentStr(S) varargin{1}];
            else
                S.Buffer = [S.Buffer IndentStr(S) sprintf(varargin{:})];
            end
        end
        
        function craddcr(S,varargin)
            % Add string with a carriage-returns (CR) before and after.
            %   craddcr(S) adds two CR characters to string buffer S.
            %   craddcr(S,T) adds a CR, then string T, then another CR to
            %      string buffer S.
            %   craddcr(S,F,V1,V2,...) adds format string F to buffer S,
            %       with a CR before and after the format text.
            
            % Put CR into the buffer first, so IndentStr will "see" the
            % CR and do the indent for us properly.
            S.Buffer = [S.Buffer S.CR];
            if nargin<2
                S.Buffer = [S.Buffer S.CR];
            elseif nargin==2
                S.Buffer = [S.Buffer IndentStr(S) varargin{1} S.CR];
            else
                S.Buffer = [S.Buffer IndentStr(S) sprintf(varargin{:}) S.CR];
            end
        end
        
        function disp(S)
            % Display string buffer contents.
            dash = repmat('-',[1 18]);            
            fprintf('String buffer object');
            fprintf(' (chars=%d, lines=%d, indent=%d)\n', ...
                chars(S), lines(S), S.Indent);
            fprintf('%s[ Start of buffer ]%s\n', dash, dash);
            fprintf('%s', char(S));
            fprintf('\n%s[  End of buffer  ]%s\n',dash,dash);
        end
        
        function edit(S,varargin)
            % Copy buffer contents into the MATLAB Editor.
            %   edit(S) copies the buffer contents into the MATLAB
            %      Editor, creating a new temporary file.
            %   edit(S,NAME) uses string NAME for the MATLAB file name.
            edit(write(S,varargin{:}));
        end
        
        function S = horzcat(S1,varargin)
            % Horizontal concatenation.
            %   S=[S1,S2,...] appends string S2 to the contents of string
            %   buffer S1, returning a newly created string buffer to hold
            %   the result.  S2 and later arguments can be either text
            %   strings or string buffer objects.
            
            S = StringBuffer(S1.Buffer); % Create new StringBuffer
            for i = 1:nargin-1
                if isa(varargin{i},'StringBuffer')
                    S.add(varargin{i}.Buffer);
                elseif isa(varargin{i},'char')
                    S.add(varargin{i});
                else
                    error('spcuilib:StringBuffer:horzcat:InvalidInput', ...
                        ['StringBuffer objects can only be concatenated with ' ...
                        'other StringBuffer objects and with chars.']);
                end
            end
        end
        
        function insert(S,POS,T)
            % Insert a string into buffer.
            %   insert(S,POS,T) inserts text T starting at location POS,
            %   where POS=1 indicates the first character position in
            %   string buffer S.  The string buffer is extended to hold the
            %   entire string.
            if POS<1 || POS>chars(S)
                error('spcuilib:StringBuffer:insert:InvalidIndex', ...
                    'Index is out of range.');
            end
            N = numel(T); % #chars in insertion text
            
            % Shift last part of string, at/after insertion point, to just
            % after the length of the string to insert
            S.Buffer(POS+N:end+N) = S.Buffer(POS:end);
            
            % Insert new string
            S.Buffer(POS:POS+N-1) = T;
        end
        
        function N = lines(S)
            % Number of lines of text in string buffer.
            
            % Add one to the count of all CR characters
            % (The first line of text is "line 1", yet may have no CR)
            N = 1+numel(strfind(S.Buffer,S.CR));
        end
        
        function t = string(S)
            % Return buffer contents as a string.
            % This is the same operation as char(S).
            t = char(S);
        end
        
        function S = vertcat(S1,varargin)
            % Vertical concatenation.
            % S=[S1;S2;...] appends a carriage return and string S2 to the
            % contents of string buffer S1, returning a newly created
            % string buffer to hold the result.  S2 and later arguments can
            % be either text strings or string buffer objects.

            % Return a new StringBuffer
            S = StringBuffer(S1.Buffer);
            for i=1:nargin-1
                if isa(varargin{i},'StringBuffer')
                    S.cradd(varargin{i}.Buffer);
                elseif isa(varargin{i},'char')
                    S.cradd(varargin{i});
                else
                    error('spcuilib:StringBuffer:vertcat:InvalidInput', ...
                        ['StringBuffer objects can only be concatenated with ' ...
                        'other StringBuffer objects and with chars.']);
                end
            end
        end
        
        function varargout = write(S,fname)
            % Write buffer contents to a text file.
            %   write(S,NAME) uses string NAME as the name of the file.
            %   write(S) writes the contents of string buffer S to a
            %     temporary file.
            if nargin<2
                fname = tempname;  % Create a temporary filename
            end

            % Only return the file name if asked.
            if nargout > 0
                varargout = {fname};
            end
            
            % Requested directory might not exist
            if ~createParentDir(fname)
                error('spcuilib:StringBuffer:write:CreateDirectory', ...
                    'Failed to create parent directory');
            end
            
            % Open file
            [fid, msg] = fopen(fname,'wt');  % open in "write text" mode, no append
            if fid==-1
                error('spcuilib:StringBuffer:write:PermissionDenied', msg);
            end
            fprintf(fid,'%s', S.Buffer);
            fclose(fid);
        end
        
        function t = readfile(S,fname)
            % Replace string buffer contents with text from a file.
            %   readfile(S,NAME) replaces the contents of string buffer S
            %     with text read from file NAME.
            
            %   T=readfile(S,NAME) optionally returns the text as a string
            %     in T, as if T=char(S) was called.
            
            [fid,msg] = fopen(fname);
            if fid==-1
                error('spcuilib:StringBuffer:read:PermissionDenied', msg);
            end
            S.clear;
            while 1
                tline = fgetl(fid);
                if ~ischar(tline), break, end
                S.addcr(tline);
            end
            fclose(fid);
            if nargout>0
                t = S.Buffer;
            end
        end
    end
    
    methods (Access=private)
        function t = IndentStr(S)
            % Only return spaces if the next buffer position is at the
            % start of a new line, e.g., the last char was a CR, or
            % we're at the start of the buffer.
            
            if (S.Indent>0) && ...
                    ( isempty(S.Buffer) || strcmp(S.Buffer(end-numel(S.CR)+1:end),S.CR) )
                t = blanks(S.Indent);
            else
                t = '';
            end
        end
    end
end

% ----------------
% Helper functions
% ----------------

function success = createParentDir(fname)
% Returns 1 if path exists or was created
% Returns 0 otherwise

p = fileparts(fname);
% If the path doesn't exist or is empty, return 0 and make the directory.
% MKDIR warns if the path is an empty string.
success = isempty(p) || exist(p,'dir');
if ~success
    success = mkdir(p);
end

end

% [EOF]

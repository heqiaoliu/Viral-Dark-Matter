function htmlOut = textdiff(source1,source2,width,ignore_whitespace)
% Creates a report showing the differences between the two specified text
% files.

% Copyright 1984-2010 The MathWorks, Inc.
% $Revision: 1.1.6.7.2.2 $

    if nargin < 3
        width = 60;
    elseif ischar(width)
        width = str2double(width);
    end
    
    if nargin<4
        ignore_whitespace = false;
    end

    if ischar(source1)
        % String supplied.  Treat it as a file name.
        source1 = resolvePath(source1);
        source1 = com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source1),source1);
    end
    if ischar(source2)
        % String supplied.  Treat it as a file name.
        source2 = resolvePath(source2);
        source2 = com.mathworks.comparisons.source.impl.LocalFileSource(java.io.File(source2),source2);
    end
    
    try
        [text1,readable1] = i_GetText(source1);
        [text2,readable2] = i_GetText(source2);
    catch e
        if strcmp(e.identifier,'MATLAB:Comparisons:FileIsBinary')
            % At least one of the files is binary, not text.  Use the
            % simple binary comparison method to compare them.
            identical = com.mathworks.comparisons.compare.concr.BinaryComparison.compare(source1,source2);
            nameprop = com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
            name1 = char(source1.getPropertyValue(nameprop,[]));
            name2 = char(source2.getPropertyValue(nameprop,[]));
            if identical
                htmlOut = com.mathworks.comparisons.util.HTMLUtils.getComparedIdenticalAsHTML(name1,name2);
            else
                htmlOut = com.mathworks.comparisons.util.HTMLUtils.getComparedDifferentAsHTML(name1,name2);
            end
            return
        else
            rethrow(e);
        end
    end
    htmlOut=i_CreateHTML(source1,text1,readable1, ...
        source2,text2,readable2,...
        width,ignore_whitespace);

end

function [text,readable] = i_GetText(source)
    if ~isa(source,'com.mathworks.comparisons.source.ComparisonSource')
        % Not a string and not a ComparisonSource.
        error('MATLAB:comparisons:ComparisonSourceRequired',...
            'Inputs to textdiff must be file names or ComparisonSources');
    end
    absnameprop = com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    textprop = com.mathworks.comparisons.source.property.CSPropertyText.getInstance();
    readableprop = com.mathworks.comparisons.source.property.CSPropertyReadableLocation.getInstance();

    % Depending on which properties this source has, we'll need to use
    % different approaches to get at the text.
    if source.hasProperty(textprop)
        % Text property present.  Get the text and convert it to a 
        % cell array of individual lines, preserving whitespace
        text = char(source.getPropertyValue(textprop,[]));
        text = textscan(text,'%s','delimiter',char(10),'whitespace','');
        text = text{1};
        readable = []; % not reading from a file
    elseif source.hasProperty(readableprop)
        % ReadableLocation property present.  Read that file.
        readable = char(source.getPropertyValue(readableprop,[]));
        [text,readable] = i_ReadFromFile(readable);
    elseif source.hasProperty(absnameprop)
        % No text or readable location.  Not a good sign, but try reading
        % the file indicated by the AbsoluteName property.
        absname = char(source.getPropertyValue(absnameprop,[]));
        [text,readable] = i_ReadFromFile(absname);
    end
end

function [text,filename] = i_ReadFromFile(filename)
    filename=resolvePath(filename);
    d = dir(filename);
    if numel(d)~=1 && exist(filename,'dir')~=0
        % fname specified a directory.  A directory listing will always
        % have at least two entries (even if the directory is empty). 
        % A user can only get here by requesting an output from visdiff.
        pGetResource('error','MATLAB:Comparisons:FolderNotAllowed');
    else
        % If the specified name resolves to more than one file, we'll get
        % a file-not-found error from gettextfromfile.
        text = gettextfromfile(filename);
    end
end

function [name,title,shorttitle,date,absname] = i_GetNames(source,filename)
    nameprop = com.mathworks.comparisons.source.property.CSPropertyName.getInstance();
    titleprop = com.mathworks.comparisons.source.property.CSPropertyTitle.getInstance();
    dateprop = com.mathworks.comparisons.source.property.CSPropertyLastModifiedDate.getInstance();
    shorttitleprop = com.mathworks.comparisons.source.property.CSPropertyShortTitle.getInstance();
    absnameprop = com.mathworks.comparisons.source.property.CSPropertyAbsoluteName.getInstance();
    % All sources have a name
    assert(source.hasProperty(nameprop));
    name = char(source.getPropertyValue(nameprop,[]));
    % Use the Title property if it's available.  Otherwise use the Name.
    if source.hasProperty(titleprop)
        title = char(source.getPropertyValue(titleprop,[]));
    else
        title = name;
    end
    if source.hasProperty(titleprop)
        shorttitle = char(source.getPropertyValue(shorttitleprop,[]));
    else
        shorttitle = title;
    end
    if source.hasProperty(dateprop)
        date = char(source.getPropertyValue(dateprop,[]).toString());
    else
        date = '';
    end
    if source.hasProperty(absnameprop)
        absname = char(source.getPropertyValue(absnameprop,[]));
    else
        absname = filename; % which might be empty, but that's OK
    end
    if strcmp(filename,name) && strcmp(filename,absname)
        % We've been given a fully qualified file name for both "name" and
        % "absname".  Remove the path from the name.  The full path will
        % still be shown for "absname".
        [~,n,e] = fileparts(filename);
        name = [n e];
    end
end


% This function creates the actual HTML output for the report.
function htmloutput = i_CreateHTML(source1,text1,filename1, ...
        source2,text2,filename2, ...
        showchars,ignore_whitespace)

% The diffcode algorithm makes an m-by-n matrix, where m is length(text1)
% and n is length(text2). If it gets too big, there are memory problems.
% Set this size limit to suit your hardware.
m = length(text1);
n = length(text2);
sizeLimit = 2.5e7;
sizeLimitExceeded = false;
softmarker = '  <span class="diffsoft">-</span>';
if m*n < sizeLimit
    [a1,a2] = diffcode(text1,text2);
else
    a1 = zeros(1,max(m,n));
    a2 = zeros(1,max(m,n));
    a1(1:m) = 1:m;
    a2(1:n) = 1:n;
    sizeLimitExceeded = true;
end

blankLine = char(32*ones(1,showchars));
f1n = [{blankLine}; text1];
f2n = [{blankLine}; text2];
a1Final = f1n(a1+1);
a2Final = f2n(a2+1);

isfile1 = ~isempty(filename1);
isfile2 = ~isempty(filename2);

%ignore_whitespace = com.mathworks.services.Prefs.getBooleanPref(...
%    'ComparisonPreferenceIgnoreWhitespace',false);

htmloutput = cell(numel(text1)+numel(text2)+1000,1); % reasonable maximum
currentline = 1; % index of current output line

function writeLine(str,varargin)
   htmloutput{currentline} = sprintf(str,varargin{:});
   currentline = currentline+1;
end

function writeModifiedLine(line1,a1,line2,a2)
    if isfile1
        leftlink = sprintf('<a href="javascript:openleft(%d);">%3d</a>',a1,a1);
    else
        leftlink = sprintf('%3d',a1);
    end
    if isfile2
        rightlink = sprintf('<a href="javascript:openright(%d);">%3d</a>',a2,a2);
    else
        rightlink = sprintf('%3d',a2);
    end
    % Take line1 and line2 and colorize into newline1 and newline2.
    [newline1,newline2] = linediff(line1,line2,showchars,ignore_whitespace);
    % A peculiarity of ICE's rendering means that this only aligns
    % properly if the span is inside the hyperlink.
    writeLine('<span class="diffleft">%s </span><span class="diffnomatch">%s x %s</span> <span class="diffany">%s</span>\n', ...
              leftlink,newline1,newline2,rightlink);
end

function writeUnmodifiedLine(line1,a1,line2,a2)
    if a1==0
        % This can happen when a whitespace-only line appears on one side
        % only.
        a1 = softmarker;
    else
        a1 = sprintf('%3d',a1);
    end
    line1 = formatLine(line1);
    if a2==0
        % This can happen when a whitespace-only line appears on one side
        % only.
        a2 = softmarker;
    else
        a2 = sprintf('%3d',a2);
    end
    line2 = formatLine(line2);
    writeLine('<span class="diffmatchleft">%s %s . %s %s</span>\n',...
        a1,line1,line2,a2);
end

function writeDeletedLine(line1,a1)
    % Text on left, blank on right.
    if isfile1
        leftlink = sprintf('<a href="javascript:openleft(%d);">%3d</a>',a1,a1);
    else
        leftlink = sprintf('%3d',a1);
    end
    writeLine('%s <span class="diffnew">%s &lt; </span><span class="diffold">%s</span> %s\n', ...
              leftlink,formatLine(line1),blankLine,softmarker);
end

function writeInsertedLine(line2,a2)
    % Blank on left, text on right.
    if isfile2
        rightlink = sprintf('<a href="javascript:rightleft(%d);">%3d</a>',a2,a2);
    else
        rightlink = sprintf('%3d',a2);
    end
    writeLine('%s <span class="diffold">%s</span><span class="diffnew"> &gt; %s</span> %s\n', ...
        softmarker,blankLine,formatLine(line2),rightlink);
end

% Replaces tabs with spaces, and HTML-escapes characters as necessary.
function newline = formatLine(oldline)
    newline = blankLine;
    lineContent = replacetabs(oldline);
    lineLen = min(length(lineContent),length(blankLine));
    newline(1:lineLen) = lineContent(1:lineLen);
    newline = code2html(newline);
end

% Escapes a string so that it can be used as a literal string in Javascript
function str = javascriptEscape(str)
    str = strrep(str,'\','\\');
    str = strrep(str,'"','\"');
end

% Converts a file name to a URL
function str = urlEscape(str)
    str = strrep(str,'\','\');
    str = [ 'file:///' strrep(str,'\','/') ];
end

[name1,title1,~,date1,absname1] = i_GetNames(source1,filename1);
[name2,title2,~,date2,absname2] = i_GetNames(source2,filename2);

% Generate the HTML
writeLine('%s\n',makeHtmlHeader);
% Title is used in the Find Dialog.
if ~isequal(name1, name2)
    title = i_string('TextdiffTitle2',title1,title2);
else
    title = i_string('TextdiffTitle1',title1);
end
writeLine('<title>%s</title>\n', title);

writeLine('<script type="text/javascript">\n');
js_var_line = currentline;
writeLine(''); % we'll fill this line in later.
if isfile1
    writeLine('var LEFT_FILE = "%s";\n', javascriptEscape(filename1));
end
if isfile2
    writeLine('var RIGHT_FILE = "%s";\n', javascriptEscape(filename2));
end
writeLine('</script>\n');

% Include a Javascript file in this directory.
jsfile = fullfile(matlabroot,'toolbox','shared','comparisons','private','diffreport.js');
writeLine('<script type="text/javascript" src="%s"></script>\n',urlEscape(jsfile));
writeLine('</head>');
writeLine('<body><a id="top"/>');

if sizeLimitExceeded
    writeLine('<span style="color:#FF0000;">%s</span>',...
              i_string('TextdiffMaxLen'));
end

% Report header, formatted as a table.
writeLine('<table cellpadding="0" cellspacing="0" border="0">');
% Top line: name
writeLine('<tr>\n');
if isfile1
    writeLine('<td></td><td><a href="matlab: edit(urldecode(''%s''))"><strong>%s</strong></a></td>\n', ...
        urlencode(filename1),name1);
else
    writeLine('<td></td><td><strong>%s</strong></td>\n', name1);
end
if isfile2
    writeLine('<td><a href="matlab: edit(urldecode(''%s''))"><strong>%s</strong></a></td>\n', ...
        urlencode(filename2),name2);
else
    writeLine('<td><strong>%s</strong></td>\n', name2);
end
writeLine('</tr>\n');
% Full paths, if different from names
if ~strcmp(absname1,name1) || ~strcmp(absname2,name2)
    writeLine('<tr>\n');
    writeLine('<td></td><td>%s</td><td>%s</td>\n',absname1,absname2);
    writeLine('</tr>\n');
end
% Dates
writeLine('<tr>\n');
writeLine('<td></td><td>%s</td><td>%s</td>\n',date1,date2);
writeLine('</tr>\n');
% Use whitespace in the cells of this column of the table to force the
% table to align with the preformatted text below it.
writeLine('<tr>\n');
writeLine('<td><pre>    </pre></td>\n');
writeLine('<td><pre>%s   </pre></td>\n',blankLine);
writeLine('<td><pre>%s</pre></td>\n',blankLine);
writeLine('</tr></table>\n');


% Some preliminary work before we start writing the main body of the
% report.

% Some names values to help below
NO_DIFFERENCE = 0;
INSERTION = 1;
DELETION = 2;
MODIFICATION = 3;

% Variables for use while generating the report
match = zeros(size(a1));
current_difference_type = NO_DIFFERENCE;
diffcount = 0;

header_line_index = currentline;
writeLine(''); % we'll come back and fill this line in later

% If we don't put this line in, ICE fails to find "diff0", and navigation
% doesn't work.  Not at all clear why.
writeLine('<br/><pre><div id="ignore"><a name="ignore"></div>\n');

for n = 1:length(a1Final)
    line1 = a1Final{n};
    line2 = a2Final{n};
    % Increment counters here
    if linesmatch(line1,line2,ignore_whitespace)
        match(n) = 1;
        if current_difference_type ~= NO_DIFFERENCE
            % We're at the end of a block of differences.
            writeLine('</div>');
        end
        current_difference_type = NO_DIFFERENCE;
        writeUnmodifiedLine(line1,a1(n),line2,a2(n));
    else
        if current_difference_type==NO_DIFFERENCE
            % Add an anchor so we can hyperlink to here from the previous
            % difference.  The div tag allows us to highlight this
            % section.
            writeLine('<div id="diff%d" onclick="select(''diff%d'')">',diffcount,diffcount);
            diffcount = diffcount + 1;
        end
        if a1(n)==0
            % Insertion; text on right-hand side only
            current_difference_type = INSERTION;
            writeInsertedLine(line2,a2(n));
        elseif a2(n)==0
            % Deletion; text on left-hand side only
            current_difference_type = DELETION;
            writeDeletedLine(line1,a1(n));
        else
            % Modification; text on both sides.  The formatting is handled
            % by writeModifiedLine.
            current_difference_type = MODIFICATION;
            writeModifiedLine(line1,a1(n),line2,a2(n));
        end
    end

end
writeLine('</pre>');

numMatch = sum(match);
matchstr = i_string('TextdiffNumMatches',numMatch);
writeLine('<a id="bottom"/><p>%s</p>\n',matchstr);

if diffcount==0
    htmloutput{header_line_index} = i_string('TextdiffNoDiffs');
    htmloutput{js_var_line} = sprintf('var LAST_DIFF_ID="top"\n');
else
    htmloutput{header_line_index} = i_string('TextdiffNumDiffs',diffcount);
    htmloutput{js_var_line} = sprintf('var LAST_DIFF_ID="diff%d";\n',diffcount-1);
    writeLine('<p>%s</p>\n', i_string('TextdiffNumDiffsLeft',numel(text1) - numMatch));
    writeLine('<p>%s</p>\n', i_string('TextdiffNumDiffsRight',numel(text2) - numMatch));
end

writeLine('</body></html>');

htmloutput = [htmloutput{1:currentline-1}];

end


function textCellArray = gettextfromfile(filename, bufferSize)
% Returns a cell array of the text in a file
%   textCellArray = gettextfromfile(filename)
%   textCellArray = gettextfromfile(filename, bufferSize)
% Throws an error if the file is binary (specifically,
% contains bytes with value zero).

    if nargin < 2
        bufferSize = 10000;
    end

    fid = fopen(filename,'r');
    if fid < 0
        pGetResource('error','MATLAB:Comparisons:FileReadError',filename)
    end
    % Now check for bytes with value zero.  For performance reasons,
    % scan a maximum of 10,000 bytes.  Prevent any "interpretation"
    % of data by reading uint8s and keeping them in that form.
    data = fread(fid,10000,'uint8=>uint8');
    isbinary = any(data==0);
    if isbinary
        fclose(fid);
        pGetResource('error','MATLAB:Comparisons:FileIsBinary',filename);
    end
    % No binary data found.  Reset the file pointer to the beginning of
    % the file and scan the text.
    fseek(fid,0,'bof');
    try
        txt = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',bufferSize);
        fclose(fid);
        textCellArray = txt{1};   
    catch exception
        %If the bufferSize is too small, textscan will throw an exception
        %in that case, just increase the buffer size and try again.
        fclose(fid);
        if strcmp(exception.identifier,'MATLAB:textscan:BufferOverflow')
            textCellArray = gettextfromfile(filename, bufferSize * 100);
        else 
           rethrow(exception)
        end
    end
end

function eq = linesmatch(line1,line2,ignore_whitespace)
     if ignore_whitespace
         line1 = strtrim(regexprep(line1,'\s+',' '));
         line2 = strtrim(regexprep(line2,'\s+',' '));
     end
     eq = strcmp(line1,line2);
end


function str = i_string(key,varargin)
    str = pGetResource('message',['MATLAB:Comparisons:' key],varargin{:});
end

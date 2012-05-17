function demowin(callback,product,label,body,base,keywords,overrideDefaultLang)
%DEMOWIN Display demo information in the Help window
%
%   This file is a helper function used by the Help Browser's Demo tab.  It is
%   unsupported and may change at any time without notice.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2010/05/03 16:09:23 $

if (nargin < 7)
    overrideDefaultLang = false;
end
if (nargin < 6)
    keywords = [];
end
if (nargin < 5)
    base = '';
end

% Some initializations
CR = sprintf('\n');

% Determine the function name.

% Start by assuming the callback is a function name and trim it down.
fcnName = char(com.mathworks.mde.help.DemoPageBuilder.getDemoFuncNameFromCallback(callback));

% Find where this function lives.
itemLoc = which(fcnName);
if ~isempty(itemLoc)
   [null fcnName] = fileparts(itemLoc);
else
   fcnName = '';
end

%%%% Build the main body of the page.

if ~isempty(body)
   % We've already got one.  Just use it.
   % Assume it has its own H1.
   label = '';
else
   helpStr = help(fcnName);
   if isempty(fcnName) || isempty(helpStr)
      body = '<p></p>';
   else
      % Build the HTML from the help.
      body = [markupHelpStr(helpStr,fcnName) CR];
   end
end

%%%% Determine the header navigation.

if isempty(callback)
   leftText = '';
   leftAction = '';
   rightText = '';
   rightAction = '';
elseif strncmp(callback,'playbackdemo',12)
   % Special case for Playback demos (temporary).
   leftText = getPrintString(overrideDefaultLang, 'Video tutorial');
   leftAction = '';
   rightText = getPrintString(overrideDefaultLang, 'Run this demo');
   rightAction = callback;
   msg = getPrintString(overrideDefaultLang, '<p>This video, which will play in your default web browser, requires Macromedia Flash Player (version 7 or later) and an Internet connection.</p>');
   if strcmp(body,'<p></p>')
       body = msg;
   else
       body = [body msg];
   end
elseif exist([fcnName '.mdl'],'file')
   leftText = [fcnName '.mdl'];
   leftAction = '';
   rightText = getPrintString(overrideDefaultLang, 'Open this model');
   rightAction = callback;
else
   leftText = getPrintString(overrideDefaultLang, 'Open %s.m in the Editor', fcnName);
   leftAction = ['edit ' fcnName];
   rightText = getPrintString(overrideDefaultLang, 'Run this demo');
   rightAction = callback;
end

%%%% Determine the header "h1" label.

if isempty(label)
   H1 = '';
else
   H1 = ['<h1>' label '</h1>'];
end

%%%% Assemble the page.

if ~isempty(fcnName)
    title = getPrintString(overrideDefaultLang, '%s Demo: %s', product, fcnName);
else
    title = getPrintString(overrideDefaultLang, '%s Demo', product);
end

htmlBegin = ['<html>' CR ...
      '<head>' CR ...
      '<title>' title '</title>' CR ...
      '<base href="' base '">' CR ...
      '<link rel="stylesheet" type="text/css" ' CR ...
      '  href="file:///' matlabroot '/toolbox/matlab/demos/private/style.css">' CR ...
      '</head>' CR ...
      '<body>'];

header = makeHeader(leftText,leftAction,rightText,rightAction);
htmlEnd = sprintf('\n</body>\n</html>\n');

outStr = [htmlBegin header CR '<div class="content">' CR ...
    H1 CR body CR '</div>' CR htmlEnd];

if (isempty(keywords))
    com.mathworks.mlservices.MLHelpServices.setDemoText(outStr);
else
    com.mathworks.mlservices.MLHelpServices.setHtmlTextAndHighlightKeywords(outStr, keywords);
end

%===============================================================================
function h = makeHeader(leftText,leftAction,rightText,rightAction)

% Left chunk.
leftData = leftText;
if ~isempty(leftAction)
   leftData = ['<a href="matlab:' leftAction '">' leftData '</a>'];
end

% Right chunk.
rightData = rightText;
if ~isempty(rightAction)
   rightData = ['<a href="matlab:' rightAction '">' rightData '</a>'];
end

h = ['<div class="header">' ...
    '<div class="left">' leftData '</div>' ...
    '<div class="right">' rightData '</div>' ...
    '</div>'];

%===============================================================================
function helpStr = markupHelpStr(helpStr,fcnName)

CR = sprintf('\n');
nameChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_/';
delimChars = [ '., ' CR ];

% Handle characters that are special to HTML
helpStr = strrep(helpStr, '&', '&amp;');
helpStr = strrep(helpStr, '<', '&lt;');
helpStr = strrep(helpStr, '>', '&gt;');

% Make "see also" references act as hot links.
seeAlso = 'See also';
lengthSeeAlso = length(seeAlso);
xrefStart = findstr(helpStr, 'See also');
if ~isempty(xrefStart)
   % Determine start and end of "see also" potion of the help output
   pieceStr = helpStr(xrefStart(1)+lengthSeeAlso : length(helpStr));
   periodPos = findstr(pieceStr, '.');
   overloadPos = findstr(pieceStr, 'Overloaded functions or methods');
   if ~isempty(periodPos)
      xrefEnd = xrefStart(1)+lengthSeeAlso + periodPos(1);
      trailerStr = pieceStr(periodPos(1)+1:length(pieceStr));
   elseif ~isempty(overloadPos)
      xrefEnd = xrefStart(1)+lengthSeeAlso + overloadPos(1);
      trailerStr = pieceStr(overloadPos(1):length(pieceStr));
   else
      xrefEnd = length(helpStr);
      trailerStr = '';
   end

   % Parse the "See Also" portion of help output to isolate function names.
   seealsoStr = '';
   word = '';
   for chx = xrefStart(1)+lengthSeeAlso : xrefEnd
      if length(findstr(nameChars, helpStr(chx))) == 1
         word = [ word helpStr(chx)];
      elseif (length(findstr(delimChars, helpStr(chx))) == 1)
         if ~isempty(word)
            % This word appears to be a function name.
            % Make link in corresponding "see also" string.
            fname = lower(word);
            seealsoStr = [seealsoStr '<a href="matlab:doc ' fname '">' fname '</a>'];
         end
         seealsoStr = [seealsoStr helpStr(chx)];
         word = '';
      else
         seealsoStr = [seealsoStr word helpStr(chx)];
         word = '';
      end
   end
   % Replace "See Also" section with modified string (with links)
   helpStr = [helpStr(1:xrefStart(1)+lengthSeeAlso -1) seealsoStr trailerStr];
end

% If there is a list of overloaded methods, make these act as links.
overloadPos =  findstr(helpStr, 'Overloaded functions or methods');
if ~isempty(overloadPos)
   pieceStr = helpStr(overloadPos(1) : length(helpStr));
   % Parse the "Overload methods" section to isolate strings of the form "help DIRNAME/METHOD"
   overloadStr = '';
   linebrkPos = find(pieceStr == CR);
   lineStrt = 1;
   for lx = 1 : length(linebrkPos)
      lineEnd = linebrkPos(lx);
      curLine = pieceStr(lineStrt : lineEnd);
      methodStartPos = findstr(curLine, ' help ');
      methodEndPos = findstr(curLine, '.m');
      if (~isempty(methodStartPos) ) && (~isempty(methodEndPos) )
         linkTag = ['<a href="matlab:doc ' curLine(methodStartPos(1)+6:methodEndPos(1)+1) '">'];
         overloadStr = [overloadStr curLine(1:methodStartPos(1)) linkTag curLine(methodStartPos(1)+1:methodEndPos(1)+1) '</a>' curLine(methodEndPos(1)+2:length(curLine))];
      else
         overloadStr = [overloadStr curLine];
      end
      lineStrt = lineEnd + 1;
   end
   % Replace "Overloaded methods" section with modified string (with links)
   helpStr = [helpStr(1:overloadPos(1)-1) overloadStr];
end

% Highlight occurrences of the function name
helpStr = strrep(helpStr,[' ' upper(fcnName) '('],[' <b>' lower(fcnName) '</b>(']);
helpStr = strrep(helpStr,[' ' upper(fcnName) ' '],[' <b>' lower(fcnName) '</b> ']);

helpStr = ['<pre><code>' helpStr '</code></pre>'];

% If we're overriding the user's default locale, we dont want to get the
% translated string from sprintf. Use regexprep instead.
function printString = getPrintString(overrideDefaultLang, str, varargin)

if overrideDefaultLang
   printString = regexprep(str, '\%s', varargin(:), 'once');
else
   printString = sprintf(str, varargin{:});
end

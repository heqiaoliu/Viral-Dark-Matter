function html = findhtmllinks(h,stream)
%  FINDHTMLLINKS  
%  This function will find all html links for diagnostic viewer
%  Copyright 1990-2008 The MathWorks, Inc.
  
%   $Revision: 1.1.6.7 $  $Date: 2009/11/19 16:45:34 $

  
  % first find the links
  [s, e, types] = find_links_l(h, stream);
  % Process the link and hyperlink them
  html = process_text(h, s, e, types, stream);
end

  function tf = is_in_a_hyperlink(s, sv_hl, ev_hl)
    tf = false;
    for i = 1:length(sv_hl)
      if s >= sv_hl(i) && s <= ev_hl(i)
        tf = true;
        break;
      end
    end
  end
  
%--------------------------------------------------------------------------
function [S, E, linkTypes] = find_links_l(h,stream)
%
%
%
contents = h.Contents;
switch contents.type,
case {'Lex', 'Parse'}, findFiles = 0;
otherwise,             findFiles = 1;
end;

S = [];
E = [];
linkTypes = {};
numFound = 0;

if ~ischar(stream), error('bad input'); end;
if nargin < 4, nag=[]; end;

try
    %
    % match standard Stateflow Ids
    % suppress multibyte character warnings
    %
    warningState = warning;
    warning('off', 'REGEXP:multibyteCharacters');
    pattern = '#\d+(\.\d+)*';
    [sv,ev] = regexp(stream, pattern);
    warning(warningState);
    for i=1:length(sv),
        s = sv(i);
        e = ev(i);
        if s>0 && s<e,
            S = [S;s];
            E = [E;e];
            linkTypes{numFound+1} = 'id';
            numFound = numFound + 1;
        end;
    end;
    
    if (0 && findFiles && ~isempty(nag) && contents.preprocessedFileLinks && ~isempty(nag.msg.links))
        % all the file links should be preprocessed so we should do it
        % again! Instead just return the preprocessed links
        s = [contents.links(:).si]';
        S = [S;s-1];
        
        e = [contents.links(:).ei]';
        E = [E;e+1];
        linkTypes = {linkTypes{:},contents.links(:).type};
    elseif findFiles
        %
        % match file/system paths in double or single quotes
        %
        % Part of fix for g470850: allow line feeds in
        % block paths.
        % Replace line feeds with spaces so following regular expression 
        % will work.
        streamx = strrep(stream, sprintf('\n'), ' ');
        % Find any quoted string that does not contains special
        % characters (<' '=\x20) other than line feeds.
        [sv, ev] = regexp(streamx, ...
          '("[^\x00-\x1F]*?")||(''[^\x00-\x1F]*?'')');
        %
        % Part of fix for G412322
        %
        % Find hyperlinks in raw messages, e.g., text of the form
        %   <a href="matlab: foo">do foo</a>
        % Use this info to exclude quoted strings in existing
        % hyperlinks from quoted string processing.
        %
        [sv_hl ev_hl] = regexp(stream, '(<a.*>)(.*?)(</a>)');
        %
        for i=1:length(sv),
            s = sv(i);
            e = ev(i);
            if s>0 && s<e && ~is_in_a_hyperlink(s, sv_hl, ev_hl)
                si = s+1;
                ei = e-1;
                if si<ei,
                    txt = stream(si:ei);
                    if is_absolute_path_l(txt)
                        [isFile, fileType] = is_a_file_l(txt);
                    else
                        fullFileName = fullfile(h.HyperRefDir,txt);
                        [isFile, fileType] = is_a_file_l(fullFileName);
                    end
                    if isFile,
                        S = [S; s];
                        E = [E; e];
                        linkTypes{numFound+1} = fileType;
                        numFound = numFound + 1;
                    end;
                end;
            end;
        end;
    end;
catch
    %%%% Error in hyperlink detection %%%% do not display thiss
end;

if ~isempty(S),
    S = S - 1;
    if any(S < 0) error('bad'); end;
end;

end

%-------------------------------------------------------------------------    
function htmlText = process_text(h, sv,ev,typesv,infoText)
htmlText = '';

[b indx] = sortrows(sv);
sv = sv(indx);
ev = ev(indx);
typesv = typesv(indx);

if (isempty(sv))
    htmlText = infoText;
else
    for i=1:length(sv),
        s = sv(i)+1;
        e = ev(i);
        linkType = typesv{i};
        
        % this makes the first part of the string
        if (i == 1)
            if (s ~= 1)
                firstPart = infoText(1:(s-1));
            else
                firstPart = '';
            end
        else
            firstPart = infoText(ev(i-1)+1:(s-1));
        end
        
        % This makes the link text part of the message
        linkText = infoText(s:e);
        linkOp = '';
        linkEnd = '</a>';
        linkBegin = '<a meval=';
        t = linkText;
        
        % remove all spaces
        if (isspace(t(1)))
            t(1)= [];
        end
        
        % Here deal with the first and or last
        % character
        if (isequal(linkType,'id'))
            t(1) = [];
        else  
            t([1 end]) = []; %remove quotes
        end
        
        % If you are dealing with a file
        % see if you have to use the full path
        % here
        if ((isequal(linkType,'txt')))
            if (is_absolute_path_l(t) ~= 1)
                t = [h.HyperRefDir,filesep,t];
            end
        end
        
        % Part of fix for g470850:
        % Remove line feeds from block paths.
        if isequal(linkType, 'mdl')
          t = strrep(t, sprintf('\n'), '');
          linkText = strrep(linkText, sprintf('\n'), '');
        end
        
        t = ['''',t,'''']; %put back in single quotes
        linkOp = ['"das_dv_hyperlink(''',linkType,''',',t,')"'];
        link = [linkBegin,linkOp,'>',linkText];
        
        % Here append all the necessary parts of this text
        %include 1) firstPart
        %        2) link
        %        3) linkEnd
        %htmlText = [htmlText, htmlBegin, link, linkEnd];
        htmlText = [htmlText, firstPart, link, linkEnd];   
    end  
end
if (~isempty(sv))
    lastLinkIndex = ev(end);
else
    lastLinkIndex = 0;
end

if (lastLinkIndex > 0 && lastLinkIndex < length(infoText))
    htmlText = [htmlText, infoText((lastLinkIndex+1):end)];    
end    
     
 %htmlText = [htmlText,'</html>'];
 
end
 
 %--------------------------------------------------------------------------
function [isFile, fileType] = is_a_file_l(file)
%
%
%
isFile = 0;
fileType = '';
oldWarn=warning;
warning('off');
file = strtrim(file);
switch exist(file,'file'),
case 0, % does not exist
    isFile = (exist(file, 'file') ~= 0 & file_has_good_extension(file));
    
    if isFile, 
        fileType = 'txt';
    else
	    prevslLastError = sllasterror;
        try
          get_param(file, 'handle');
          isFile = 1;
          fileType = 'mdl';
        catch
            % if it can't find file's handle, change '\' to '/' 
            % to see if it can find file's handle. This is for 
            % gecko 293348, which complained could not find hyperlink 
            % for PC. Since fullfile.m change file separator to '\' for PC.
            % But SL can only find block link with '/'
            try
                sllasterror(prevslLastError);
                file = strrep(file,'\','/');
                
                % Part of fix for g470850. Remove line feeds
                % from path before trying to get handle.
                file = strrep(file, sprintf('\n'), '');
                
                get_param(file, 'handle');
                isFile = 1;
                fileType = 'mdl';
            catch
                sllasterror(prevslLastError);
                if (evalin('base', ['exist(''' file ''', ''var'')']))
                    if (evalin('base', ['isa(' file ', ''Simulink.Bus'')']))
                        isFile = 1;
                        fileType = 'bus';
                    end
                end
            end
        end;
    end;
case 2, % is a file
    if file_has_good_extension(file) && ~isequal(exist(file),5), 
        isFile = 1;
        fileType = 'txt';
    end;
case 4, % is a MDL file on the path
    isFile = 1;
    fileType = 'mdl';
case 7, % is a directory
    x = dir(file);
    if ~isempty(x), % check that the system also thinks this is a directory 
    isFile = 1;
    fileType = 'dir';
    end;
end;

warning(oldWarn);

end


%--------------------------------------------------------------------------
function goodExt = file_has_good_extension(file)
%
%
%
goodExt = 1;
if length(file) > 4,
    k = findstr(file,'.');
    if (k > 0),
        ext = file(k+1:end);
        switch ext,
        case {'exe', 'dll', 'obj', 'lib', 'ilk', 'mat', 'fig', 'exp', 'res', 'zip'}, % add to exclude
            goodExt = 0;
        end;
    end;    
end;

end

%--------------------------------------------------------------------------
function isAbsPath = is_absolute_path_l(fileName)
isAbsPath = 0;
if(length(fileName)>=2)
    if(fileName(2)==':' || fileName(1)==filesep)
        isAbsPath = 1;
    end
    
else
    if( length(fileName)>=1 && (fileName(1)=='/' || fileName(1) == '\'))
        isAbsPath = 1;
    end
end

end


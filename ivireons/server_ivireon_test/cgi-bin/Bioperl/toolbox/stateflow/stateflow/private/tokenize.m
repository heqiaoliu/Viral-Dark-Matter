function [tokenList,errorStr] = tokenize(rootDirectory,str,description,searchDirectories)

%
%	Copyright 1995-2008 The MathWorks, Inc.
%  $Revision: 1.8.2.5 $  $Date: 2008/12/01 08:08:25 $

if(nargin<4)
    searchDirectories = {};
end
if(nargin<3)
    description = str;
end
tokenList = {};
errorStr = '';
if(isempty(str))
    return;
end

[str,errorStr] = process_dollars_and_seps(str,description);
if(~isempty(errorStr))
    return;
end


if(0)
    [tokenList,errorStr]  = tokenize_kernel_old(str,rootDirectory,description,searchDirectories);
    if(0)
        [tokenListNew,errorStr] = tokenize_kernel_new(str,rootDirectory,description,searchDirectories);

        if(~isequal(tokenList,tokenListNew))
            error('Stateflow:InternalError','New tokenization did not match old tokenization');
        end
    end
else
    [tokenList,errorStr] = tokenize_kernel_new(str,rootDirectory,description,searchDirectories);
end

function [tokenList,errorStr] = tokenize_kernel_old(str,rootDirectory,description,searchDirectories)
tokenList = {};
errorStr = '';
[tokenType,token] = sf('TokenizePath',str);
while(~isempty(token))
    [processedToken,errorStr] = process_token(token,rootDirectory,description,searchDirectories); %#ok<AGROW>
    if(~isempty(errorStr))
        return;
    end
    tokenList{end+1} = processedToken;
    [tokenType,token] = sf('TokenizePath');
end

function [tokenList,errorStr] = tokenize_kernel_new(str,rootDirectory,description,searchDirectories)
tokenList = {};
errorStr = '';
pat = '"[^"]+"|[^\n\t\f ;,]+';
rawTokens = regexp(str,pat,'match');
for i=1:length(rawTokens)
    token = rawTokens{i};
    [processedToken,errorStr] = process_token(token,rootDirectory,description,searchDirectories); %#ok<AGROW>
    if(~isempty(errorStr))
        return;
    end
    tokenList{end+1} = processedToken;
end

function [str,errorStr] = process_dollars_and_seps(str,description)

errorStr = '';
dollarLocs = find(str=='$');
if(length(dollarLocs)/2~=floor(length(dollarLocs)/2))
    errorStr = sprintf('Mismatched $ characters. Cannot proceed with\nsubstitution in %s.',description);
    return;
end

%% since we are modifying the newStr, lets traverse
%% the string backwards
if(~isempty(dollarLocs))
    newStr = str;
    for i=(length(dollarLocs)):-2:2
        s = dollarLocs(i-1);
        e = dollarLocs(i);
        evalStr = str(s+1:e-1);
        try
            evalStrValue = evalin('base',evalStr);
            if(~ischar(evalStrValue))
                errorStr = sprintf('$ encapsulated token ''%s'' is not a string in base workspace\nfor substitution in %s.',evalStr,description);
                return;
            end
        catch ME
            errorStr = sprintf('Error evaluating $ encapsulated token ''%s'' in base workspace\nfor substitution in %s.',evalStr,description);
            return;
        end

        if(s>1 && e<length(str))
            newStr = [newStr(1:s-1),evalStrValue,newStr(e+1:end)];
        elseif(s==1 && e<length(str))
            newStr = [evalStrValue,newStr(e+1:end)];
        elseif(s>1 && e==length(str))
            newStr = [newStr(1:s-1),evalStrValue];
        else
            % begin and end with a $
            newStr = evalStrValue;
        end
    end
    str = newStr;
end
if isunix
    wrongFilesepChar = '\';
    filesepChar = '/';
else
    wrongFilesepChar = '/';
    filesepChar = '\';
end

seps = find(str==wrongFilesepChar);
if(~isempty(seps))
    str(seps) = filesepChar;
end


function [token,errorStr] = process_token(token,rootDirectory,description,searchDirectories)

errorStr = '';
if(token(1)=='"')
    token = token(2:end-1);
end
% strip the trailing slash
% (for include directory paths this was causing problems for msvc make)
if(token(end)=='/' || token(end)=='\')
    token = token(1:end-1);
end
if(~isempty(token))
    if(token(1)=='.')
        % definitely a relative path
        token = fullfile(rootDirectory,token);
    else
        if(ispc && length(token)>=2)
            % absolute path son PC start with drive letter or \\(for UNC paths)
            isAnAbsolutePath = (token(2)==':') | (token(1)=='\' & token(2)=='\');
        else
            % absolute paths on unix start with '/'
            isAnAbsolutePath = token(1)=='/';
        end
        if(~isAnAbsolutePath)
            % if it is not an absolute path, check to see if
            % it exists in any of the searchDirectories
            if(~isempty(searchDirectories))
                found = 0;
                for i=1:length(searchDirectories)
                    fullToken = fullfile(searchDirectories{i},token);
                    if(exist(fullToken,'file'))
                        found = 1;
                        break;
                    end
                end
                if(found)
                    token = fullToken;
                else
                    errorStr = sprintf('%s specified in %s does not exist in any\nof the following search directories:',token,description);
                    for i=1:length(searchDirectories)
                        errorStr = sprintf('%s\n\t"%s"',errorStr,searchDirectories{i});
                    end
                    return;
                end
            else
                token = fullfile(rootDirectory,token);
            end
        end
    end
end

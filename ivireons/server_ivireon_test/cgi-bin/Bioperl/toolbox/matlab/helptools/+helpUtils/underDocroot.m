function fullpath = underDocroot(varargin)
% underDocroot - Find a file that is expected to be under the docroot.  
%   This function is primarily used to take localization into account - on 
%   Japanese machines, if the file does not exist under the jhelp directory
%   we will look for it in the help directory.  This method will return an 
%   empty array if the file is not found.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/24 18:30:35 $
fullpath = '';

testpath = fullfile(docroot,varargin{:});
if exist(testpath,'file')
    fullpath = testpath;
else
    lang = get(0,'language');
    if strncmpi(lang, 'ja', 2) && ~isempty(regexp(docroot,'help[/\\]ja_JP[/\\]?$','once'))
        engdocroot = regexprep(docroot,'help[/\\]ja_JP[/\\]?$','help');
        testpath = fullfile(engdocroot,varargin{:});
        if (exist(testpath,'file'))
            fullpath = testpath;
        end
    end
end

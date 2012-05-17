function playbackdemo(demoName,relativePath)
%PLAYBACKDEMO  Launch demo playback device
%   PLAYBACKDEMO(demoName) launches a playback demo in "$matlabroot/demos".
%
%   PLAYBACKDEMO(demoName,relativePath) specifies the relative path from
%   matlabroot to an arbitrary directory.
%
%   Example:
%      playbackdemo('desktop')

%   $Revision: 1.1.8.2.2.1 $  $Date: 2010/08/03 20:32:48 $
%   Copyright 1984-2010 The MathWorks, Inc.

% Define constants.
if (nargin < 2)
    relativePath = 'toolbox/matlab/web/demos';
else
    relativePath = strrep(relativePath,'\','/');
end
lang = lower(regexprep(get(0,'language'),'(..).*','$1'));

% See first if it is found locally under MATLABROOT.
url = findLocalFile(relativePath,lang,demoName);

% If not, build the URL to the web.
if isempty(url)
    product = regexp(relativePath,'(\w+)\/web\/demos$','tokens','once');
    if isempty(product)
        % The file isn't found and this directory it isn't a web directory.
        errordlg(sprintf('Can''t find %s',demoName));
        return
    else
        url = buildUrl(product{1},lang,demoName);
    end
end

% Launch browser
web(url,'-browser','-display');

%==========================================================================
function url = findLocalFile(relativePath,lang,demoName)
url = '';
htmlFilePaths = {
    fullfile(matlabroot,relativePath,lang,[demoName '.html']);
    fullfile(matlabroot,relativePath,[demoName '_' lang '.html']);
    fullfile(matlabroot,relativePath,[demoName '.html']);
    };
for iHtmlFilePaths = 1:numel(htmlFilePaths)
    htmlFilePath = htmlFilePaths{iHtmlFilePaths};
    if fileExists(htmlFilePath)
        url = filenameToUrl(htmlFilePath);
        break
    end
end

%==========================================================================
function tf = fileExists(html_file)
tf = exist(html_file,'file')==2;

%==========================================================================
function url = filenameToUrl(html_file)
url = ['file:///' html_file];

%==========================================================================
function url = buildUrl(product,lang,demoName)

switch lang
    case 'ja'
        urlbase = 'http://www.mathworks.co.jp/support';
    otherwise
        urlbase = 'http://www.mathworks.com/support';
end
release = version('-release');
if strcmp(product, 'des')
    product = 'desblks';
    % This is a special case for SimEvents. This should go away
    % when SimEvents moves to toolbox/simevents.
end
v = ver(product);
if isempty(v)
    wp = {urlbase,release,product,'demos',[demoName '.html']};
else
    productVersion = v.Version;
    wp = {urlbase,release,product,productVersion,'demos',[demoName '.html']};
end
url = join(wp,'/');
        
%==========================================================================
function s=join(c,d)
%JOIN combines a cell array of strings into a single string.
%   JOIN(CELLSTR,DELIMITER) returns a string of the elements of the cell array
%   joined together with DELIMITER between each.
%
%     >> join({'foo','bar','baz'},'MJS')
%
%     ans =
%
%     fooMJSbarMJSbaz

% Matthew J. Simoneau
% April 2003

c = c(:)';
ds = cell(size(c));
ds(:) = {d};
c = [c;ds];
c = c(1:end-1);
s = [c{:}];


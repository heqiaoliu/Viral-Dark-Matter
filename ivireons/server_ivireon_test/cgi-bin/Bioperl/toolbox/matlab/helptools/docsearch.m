function docsearch(varargin)
%DOCSEARCH Search HTML documentation in the Help browser.
%
%   DOCSEARCH, by itself, brings up the Help browser with the Search tab
%   selected.
%
%   DOCSEARCH TEXT brings up the Help browser with the Search tab selected,
%   and executes a full-text search of the documentation on the text.
%
%   Examples:
%      docsearch plot
%      docsearch plot unix
%      docsearch('plot unix')
%
%   See also DOC, HELPBROWSER.

%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2008/09/15 20:39:20 $

errormsg = javachk('mwt', 'The Help browser');
if ~isempty(errormsg)
	error('MATLAB:helpbrowser:UnsupportedPlatform', errormsg.message);
end

if nargin > 1
    text = deblank(sprintf('%s ', varargin{:}));    
elseif nargin == 1
    text = varargin{1};
else
    text = '';
end

com.mathworks.mlservices.MLHelpServices.docSearch(text);

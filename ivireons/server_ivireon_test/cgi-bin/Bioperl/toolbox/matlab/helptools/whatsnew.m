function whatsnew(arg)
%WHATSNEW Access Release Notes via the Help browser.
%   WHATSNEW displays the Release Notes in the Help browser, presenting 
%   information about new features, problems from previous releases that 
%   have been fixed in the current release, and known problems, all 
%   organized by product.
%
%   See also VER, INFO, HELP.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/06/21 19:33:45 $

% Make sure that we can support the whatsnew command on this platform.
errormsg = javachk('mwt', 'The whatsnew command');
if ~isempty(errormsg)
	error('MATLAB:whatsnew:UnsupportedPlatform', errormsg.message);
end

html_file = fullfile(docroot,'base','relnotes','relnotes_product_page.html');
web(html_file, '-helpbrowser');

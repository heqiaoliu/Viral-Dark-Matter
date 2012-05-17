function showdemo(fname)
%SHOWDEMO Open the HTML-file for a demo in the Help Browser.
%   SHOWDEMO(FNAME) locates the corresponding HTML-file for the M-file FNAME and
%   opens it in the Help Browser.

% Copyright 2005-2010 The MathWorks, Inc.

% Make sure that java is supported for 1) the call to get the localized
% demo file and 2) the Help browser.
errormsg = javachk('swing', 'The Help browser');
if ~isempty(errormsg)
    error('MATLAB:showdemo:UnsupportedPlatform', errormsg.message);
end

[demoDir,name] = fileparts(which(fname));
html = fullfile(demoDir,'html',[name '.html']);

html = char(com.mathworks.mlwidgets.help.DemoInfoUtils.getLocalizedDemoFilename(html));

if isempty(demoDir)
    error('MATLAB:showdemo:NotFound','"%s" not found.',fname);
elseif isempty(dir(html))
    error('MATLAB:showdemo:NotFound','"%s" not found.',html);
else
    web(html,'-helpbrowser');
end

function scdguihelp(topickey,varargin)
%SCDGUIHELP  Help support for Simulink Control Design GUIs.

%   Author(s): John Glass
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.6 $  $Date: 2009/02/06 14:27:38 $

% Get MAPFILE name
helpdir = docroot;
if ~isempty(helpdir)
    mapfile = scdmapfile;
else
    mapfile = '';
end

if nargin==1
    % Pass help topic to help browser
    try
        helpview(mapfile,topickey,varargin{:},'CSHelpWindow');
    catch Ex %#ok<NASGU>
        errordlg(sprintf('Help topic %s is not found or help is not installed.',topickey))
    end
elseif (nargin == 2 && (isa(varargin{1},'com.mathworks.mlwidgets.help.HelpPanel')))
    % Set the help topic in a help panel
    javaMethodEDT('displayTopic',varargin{1},mapfile,topickey);
elseif (nargin == 2 && (isa(varargin{1},'javax.swing.JDialog')|| isa(varargin{1},'javax.swing.JFrame')))
    topicMap = com.mathworks.mlwidgets.help.CSHelpTopicMap(mapfile);
    if topicMap.isQE
        help_path = char(topicMap.mapID(topickey));
        topicMap.setQEHelpPath(help_path);
    else
        % Launch CSH Help relative to a Java panel or dialog
        javaMethodEDT('cshDisplayTopic',com.mathworks.mlservices.MLHelpServices,varargin{1}, mapfile, topickey);
    end
elseif (nargin == 2 && strcmp(varargin{1},'HelpBrowser'))
    helpview(mapfile,topickey)
end

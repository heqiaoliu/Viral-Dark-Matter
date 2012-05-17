function aboutcommtlbx
%ABOUTCOMMSTLBX Render About Communications Toolbox window.
%   ABOUTCOMMSTLBX Displays the version number of the Communications
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2007/11/07 18:17:00 $ 

icon = load('aboutctb.mat');
tlbx = ver('comm');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1996-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'custom',icon.eyediagram,hot(64),'modal');

%-------------------------------------------------------------------------------
% [EOF]

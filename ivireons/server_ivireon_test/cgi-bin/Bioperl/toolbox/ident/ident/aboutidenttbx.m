function aboutidenttbx
%ABOUTIDENTTBX About System Identification Toolbox.
%   ABOUTIDENTTBX Displays the version number of System Identification
%   Toolbox and the copyright notice in a modal dialog box.

%   Copyright 1988-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $ $Date: 2007/05/18 05:05:30 $ 

tlbx = ver('ident');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1988-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'modal');

% [EOF] aboutidenttbx.m

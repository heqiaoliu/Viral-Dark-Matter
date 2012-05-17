function aboutslfixpoint
%ABOUTSLFIXPOINT About Simulink Fixed Point.
%   ABOUTSLFIXPOINT displays the version number and the copyright notice in
%   a modal dialog box.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2007/07/31 19:57:34 $ 

tlbx = ver('fixpoint');
str = sprintf([tlbx.Name ' ' tlbx.Version '\n',...
	'Copyright 1994-' datestr(tlbx.Date,10) ' The MathWorks, Inc.']);
msgbox(str,tlbx.Name,'modal');


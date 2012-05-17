function figw=iduilay2(nobut)
%IDUILAY2 Computes window width based on the number of buttons.
%   figw = figure width
%   nobut = number of buttons

%   L. Ljung 10-10-94
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2006/09/30 00:19:54 $

idlayoutscript
figw = 2*mEdgeToFrame+nobut*mStdButtonWidth+(nobut+1)*mFrameToText;
function f = getIdentGUIFigure
%GETIDENTGUIFIGURE returns a handle to System Identification Tool's main figure.
% This is a GUI utlitity.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2006/11/17 13:29:50 $

persistent IdentGUIFigureHandle

if isempty(IdentGUIFigureHandle) || ~ishandle(IdentGUIFigureHandle)
    IdentGUIFigureHandle = findall(0,'tag','sitb16','type','figure');
end

f = IdentGUIFigureHandle;

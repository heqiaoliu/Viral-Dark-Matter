function h = CardPanelViewer(MainPanel)
% CardPanelViewer constructor for cardpanelviewer
% 

%   Author(s): C Buhr
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:14:13 $

h = ctrluis.CardPanelViewer;

h.MainPanel = handle(MainPanel);

h.buttonpanel;


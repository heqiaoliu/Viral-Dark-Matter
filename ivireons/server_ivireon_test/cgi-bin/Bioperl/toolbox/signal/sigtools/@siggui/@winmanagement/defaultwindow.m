function win = defaultwindow(hManag)
%DEFAULTWINDOW Instantiate a default window specifications object

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.3 $  $Date: 2009/03/09 19:35:37 $

% Instantiate window specifications object
win = siggui.winspecs;

% Generate a default name
nb_win = get(hManag, 'Nbwin');
defaultname = ['window_',num2str(nb_win+1)];

% Instantiate default window object
defaultwin = sigwin.hamming;

% Set state of winspecs object
win.Window = defaultwin;
win.Name = defaultname;

apply(win);

% [EOF]

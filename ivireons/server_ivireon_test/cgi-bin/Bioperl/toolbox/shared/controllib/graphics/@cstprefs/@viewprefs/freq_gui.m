function Main = wrap_gui(h)
%WRAP_GUI  GUI for editing phase wrap properties of h

%   Author(s): C. Buhr
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/04/21 21:45:17 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(ctrlMsgUtils.message('Controllib:gui:strFrequencyResponse'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

PhaseWrapping = wrap_gui(h);
MinGainLimit = mingain_gui(h);

Main.add(MinGainLimit,com.mathworks.mwt.MWBorderLayout.NORTH);
Main.add(PhaseWrapping,com.mathworks.mwt.MWBorderLayout.SOUTH);
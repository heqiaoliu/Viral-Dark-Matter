function data = generate(hWin)
%Generate(hWin) Generates the Taylor Window.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2008/07/09 18:13:53 $

data = taylorwin(hWin.Length, hWin.Nbar, -hWin.SidelobeLevel);



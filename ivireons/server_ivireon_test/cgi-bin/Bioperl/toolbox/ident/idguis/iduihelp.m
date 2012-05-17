function iduihelp(file,title)
%IDUIHELP Wrapper function to hthelp.

%   L. Ljung 4-4-95
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2008/05/19 23:03:44 $

nr = find(file=='.');
file = [file(1:nr) 'htm'];

%stat = 1;
htfile=which(file);
stat=web(htfile);
if stat==2
   disp(['Could not launch Web browser. Please make sure that' ...
         sprintf('\n') 'you have enough free memory to launch the browser.']);
elseif (stat)
   disp(['Could not load HTML file into Web browser. Please make sure that'...
  sprintf('\n') 'you have a Web browser properly installed on your system.']);
end
if stat 
    web(file);
end

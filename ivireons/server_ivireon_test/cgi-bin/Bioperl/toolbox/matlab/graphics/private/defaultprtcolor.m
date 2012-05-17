function color = defaultprtcolor
%DEFAULTPRTCOLOR Retrieve  color mode for the default printer (1=color; 0=mono)

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2006/06/27 23:04:04 $

% Retrieve default printer device
[pcmd, in_dev] = printopt;  
dev = in_dev(3:end);

% For windows drivers, default color mode is based on default printer
if ispc && strncmp(dev,'win',3)
	color = system_dependent('getprintercolor');
% For all other drivers, determine color mode from printopt value
else
	[ options, devices, extensions, classes, colorDevs, ...
           destinations] = printtables;
	color = 'C' == colorDevs{find(strcmp(dev,devices))};
	
end

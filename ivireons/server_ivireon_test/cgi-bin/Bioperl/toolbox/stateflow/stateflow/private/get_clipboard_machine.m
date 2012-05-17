function clipboardId = get_clipboard_machine
%GET_CLIPBOARD_MACHIHE

%	Jay R. Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.9.2.3 $  $Date: 2008/12/01 08:06:05 $

	clipboardId = sf('find','all','machine.name','$$Clipboard$$');
	switch(length(clipboardId)),
		case 0, 
			warning('Stateflow:UnexpectedError','No clipboard machine found, creating new one.');
			clipboardId = sf('new', 'machine', '.name', '$$Clipboard$$');
		case 1, return;
		otherwise, 
			warning('Stateflow:UnexpectedError','Multiple clipboards in memory.');
			sf('delete', clipboardId(2:end));
			clipboardId = clipboardId(1);
	end;

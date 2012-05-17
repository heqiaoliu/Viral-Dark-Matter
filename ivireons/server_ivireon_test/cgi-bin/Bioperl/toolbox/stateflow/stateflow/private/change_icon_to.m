function change_icon_to(blockH, cmd)
%
% Updates a Stateflow block's icon.

%   Jay Torgerson
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.10.2.3 $  $Date: 2008/12/01 08:05:00 $

	%
	% if you can't modify this icon, then just bail.
	%
	if strcmpi( get_param(blockH,'MaskSelfModifiable'),'off'), return; end;
	r = bdroot(blockH);
	if strcmpi(get_param(r, 'lock'),'on'), return; end;

	switch(cmd),
	  case 'block',
	    % Allow any foreground color for normal Stateflow blocks
	    % Stateflow library links are always blue.
	  case 'blockAfterLinkBreak',
	    currentFG = get_param(blockH, 'Foreground');
	    if currentFG == 4, % blue RESERVERD FOR LINKS ONLY
		set_param(blockH, 'Foreground', 0);
	    end;
	  case 'link'
	    set_param(blockH, 'Foreground', 4);
	  otherwise, error('Stateflow:UnexpectedError','bad arg passed to change_icon_to()');
	end;

	%
	% Force an update of the icon to get the link string
	%
    try
        set_param(blockH,'MaskIconUnits','autoscale');
    catch ME
    end

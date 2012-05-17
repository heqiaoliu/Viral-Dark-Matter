function sf_menu_mode(mode, fig)
%SF_MENU_MODE( MODE, FIG )

%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.11.2.2 $  $Date: 2007/09/21 19:18:00 $

	editH	= findobj(fig, 'type','uimenu','label','&Edit');
	addH	= findobj(fig, 'type','uimenu','label','&Add');

	switch(mode),
		case 'iced',	set([editH addH], 'enable','off');
		case 'normal',	set([editH addH], 'enable','on');
		otherwise, error('Stateflow:UnexpectedError','Bad mode passed to sf_menu_mode()');
	end;






			


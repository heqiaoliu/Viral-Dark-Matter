function Focus = getfocus(Editor)
%GETFOCUS  Computes scale-aware X focus.

%   Copyright 1986-2010 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $ $Date: 2010/05/10 16:59:09 $

Focus = Editor.FreqFocus;
if ~isempty(Focus)
    if strcmp(Editor.Axes.XScale,'log')
        % Round to entire decade in current units
        % RE: This avoids irritating Y clipping when X focus is extended to
        %     nearest decade
        Focus = unitconv(Focus,'rad/sec',Editor.Axes.XUnits);
        Focus = log10(Focus);
        Focus = 10.^[floor(Focus(1)),ceil(Focus(2))];
        Focus = unitconv(Focus,Editor.Axes.XUnits,'rad/sec');
    end
end

function Panel = getPanelForType(this,Type)
% return panel of specified model Type
%Type - 'idnlarx' or 'idnlhw'

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2007/02/06 19:51:55 $

if strcmpi(Type,'idnlarx')
    Panel = this.NlarxPanel;
else
    Panel = this.Nlhwpanel;
end

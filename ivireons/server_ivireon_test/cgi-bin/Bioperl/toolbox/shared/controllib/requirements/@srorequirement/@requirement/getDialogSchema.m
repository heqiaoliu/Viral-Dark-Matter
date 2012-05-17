function pnl = getDialogSchema(this) 
% GETDIALOGSCHEMA  Method to create DDG schema for requirement
%
% Returned DDG structure is embedded in a parent DDG 
 
% Author(s): A. Stothert 22-Jun-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:14 $

pnl.Type    = 'panel';
pnl.Tag     = 'pnlAbstractReq';
pnl.Name    = '';
pnl.RowSpan = [1 1];
pnl.ColSpan = [1 1];

txt.Type = 'text';
txt.Tag  = 'txtAbstract';
txt.Name = sprintf('Abstract DDG (%s)',class(this));
txt.RowSpan = [1 1];
txt.ColSpan = [1 1];

%Add widgets to panel
pnl.Items      = {txt};
pnl.LayoutGrid = [1 1];
pnl.RowStretch = 1;
pnl.ColStretch = 1;

function scopext(ext)
%SCOPEXT Register scope extension.
%   EXT is a uiservices.ExtRegDb database object.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $  $Date: 2007/11/17 22:41:56 $

%% Define extension Types
%
% Note that Types don't need to be pre-defined, unless special properties
% are specified such as Constraint and Position.
%
% Core extensions are "always on", and constitute base scope services
% Core type should appear first in dialog
%
% We must have the General extensions instantiated first since other
% extensions usually count on these services (i.e., install a UI into the
% base UI), so the Position attribute is set (3rd arg to the .addtype
% method below, or we can set explicit property).
% (We also want these Types to appear first, and in a certain order, in the
% configuration edit-dialog, so Position influences that.)
%
% Other Types will appear AFTER these unless their position is explicitly
% set.
%
% ext.addtype('magzoom', 'EnableOne');
%

ext.addtype('Core', 'EnableAll', -4);

ext.addtype('Sources', 'EnableAtLeastOne', -3);

ext.addtype('Visuals', 'EnableOne', -2);

ext.addtype('Tools', 'EnableAny', -1);

%% General scope extensions
%
% We must also have the 'User I/O' instantiate first, so we set
% the Position attribute accordingly (lower # = earlier)
%
h = ext.add('Core','General UI','uiscopes.UserIntfExt','Scope user interface settings');
h.Order = 0; % want this one to instantiate first
h = ext.add('Core','Source UI','uiscopes.SrcOptsExt','Common source settings');
h.Order = 1;

% [EOF]

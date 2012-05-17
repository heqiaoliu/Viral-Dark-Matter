function T = recordon(Constr)
%RECORDON  Starts recording Edit Constraint transaction.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:52 $

T = ctrluis.transaction(Constr.Data,'Name',xlate('Edit Constraint'),...
    'OperationStore','on','InverseOperationStore','on');


function recordoff(Constr,T)
%RECORDON  Starts recording Edit Constraint transaction.

%   Authors: P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:31:51 $

if ~isempty(Constr.Elements.Children) && ~isempty(T.Transaction.Operations)
    % Commit and stack transaction
    % RE: Only when something changed! (FocusLost listener triggers even w/o touching data)
    Constr.EventManager.record(T);
else
    delete(T);
end

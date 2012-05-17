function redo(t)
%REDO  Redoes transaction.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2006/06/02 20:11:38 $

% Redo transaction
for k=1:length(t.ObjectsCell)
    t.ObjectsCell{k}.TsValue = t.FinalValue{k};
end

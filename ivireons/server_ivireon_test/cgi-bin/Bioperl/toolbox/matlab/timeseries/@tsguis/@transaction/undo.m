function undo(t)
%UNDO  Undo transaction.

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $ $Date: 2006/06/02 20:11:41 $

for k=1:length(t.ObjectsCell)
    t.ObjectsCell{k}.TsValue = t.InitialValue{k};
end


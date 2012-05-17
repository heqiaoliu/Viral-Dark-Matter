function undo(h)
%UNDO   Undo the transaction.

%   Author(s): D. Foti & J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/12/04 23:24:36 $

if ~isempty(h.Property),
    try
        set(h.Object, fliplr(h.Property), fliplr(h.OldValue));
    catch ME
        if ~strcmp(ME.identifier, 'MATLAB:class:SetDenied')
            throwAsCaller(ME);
        end
    end
end


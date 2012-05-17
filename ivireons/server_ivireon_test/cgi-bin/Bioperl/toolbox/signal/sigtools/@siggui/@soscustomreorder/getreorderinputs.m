function reorderinputs = getreorderinputs(this)
%GETREORDERINPUTS   Returns the reorder inputs.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:26:20 $

reorderinputs{1} = evaluatevars(this.NumeratorOrder);

opts = set(this, 'DenomOrdSource');

if strcmpi(this.DenomOrdSource, opts{1}),
    if strcmpi(this.ScalevOrdSource, opts{2}),
        reorderinputs{2} = reorderinputs{1};
        reorderinputs{3} = evaluatevars(this.ScaleValuesOrder);
    end
else
    reorderinputs{2} = evaluatevars(this.DenominatorOrder);
    if strcmpi(this.ScaleVOrdSource, opts{2}),
        reorderinputs{3} = evaluatevars(this.ScaleValuesOrder);
    end
end

% [EOF]

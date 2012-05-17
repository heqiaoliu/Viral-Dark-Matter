function variables = checkoptimizescalevalues(this,variables)
%CHECKOPTIMIZESCALEVALUES check if optimize scale values is possible

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 03:10:02 $


issvnoteq2one = this.issvnoteq2one;
if this.OptimizeScaleValues && ~all(issvnoteq2one),
    % Unit scale values cannot be skipped when specified through a port
    warning(generatemsgid('UnitScaleValues'), ...
        ['Unable to optimize unit scale values when specified through a port. ', ...
        'Consider setting the OptimizeScaleValues property to false to ensure ', ...
        'the generated block and the filter object are functionally equivalent.']);
    that = copy(this);
    that.OptimizeScaleValues = false;
    g = that.privScaleValues.';
    variables{3} = g;
end


% [EOF]

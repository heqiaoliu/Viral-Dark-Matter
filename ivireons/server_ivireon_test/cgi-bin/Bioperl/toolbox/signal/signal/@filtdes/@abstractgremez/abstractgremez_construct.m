function abstractgremez_construct(h, varargin)
%ABSTRACTGREMEZ_CONSTRUCT

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:01:25 $

schema.prop(h, 'FIRType', 'gremezFIRType');
schema.prop(h, 'SinglePointBands', 'posint_vector');
schema.prop(h, 'ForcedFreqPoints', 'posint_vector');
schema.prop(h, 'IndeterminateFreqPoints', 'posint_vector');

dynMinOrder_construct(h, varargin{:});

% [EOF]

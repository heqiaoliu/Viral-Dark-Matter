function classiciir_construct(this)
%CLASSICIIR_CONSTRUCT   Constructor for the classiciir

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:04:00 $

schema.prop(this, 'MatchExactly', getmatchexactlytype(this));

set(this, 'MatchExactly', 'passband');

dynMinOrder_construct(this);

% [EOF]

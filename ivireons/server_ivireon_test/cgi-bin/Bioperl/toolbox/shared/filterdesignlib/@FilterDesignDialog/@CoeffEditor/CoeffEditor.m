function this = CoeffEditor(Hd)
%COEFFEDITOR   Construct a COEFFEDITOR object.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:00:58 $

error(nargchk(1,1,nargin,'struct'));

this = FilterDesignDialog.CoeffEditor;

set(this, 'FixedPoint', FilterDesignDialog.FixedPoint, ...
    'FilterObject', Hd);

% [EOF]

function h = labelsandvalues(varargin)
%LABELSANDVALUES  Constructor for this class

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2003/03/02 10:27:46 $

% built-in constructor
h = siggui.labelsandvalues;

set(h, varargin{:});

% Set the version and tag
set(h, 'version', 1.0);
settag(h);

% [EOF]

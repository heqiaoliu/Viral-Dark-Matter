function s = designopts(this, varargin)
%DESIGNOPTS   Abstract method.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:37:04 $

s = get(this);

s = rmfield(s, 'DesignAlgorithm');

s = thisdesignopts(this, s, varargin{:});

% [EOF]

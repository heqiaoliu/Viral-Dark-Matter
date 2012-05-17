function Hd = kaiserwin(this, varargin)
%KAISERWIN   Design a kaiser-window filter.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:27:20 $

Hd = design(this, 'kaiserwin', varargin{:});


% [EOF]

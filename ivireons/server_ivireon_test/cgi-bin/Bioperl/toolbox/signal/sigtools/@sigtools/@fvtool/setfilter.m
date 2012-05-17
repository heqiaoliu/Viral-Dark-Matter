function setfilter(this, varargin)
%SETFILTER Set the filter to FVTool

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2004/04/13 00:30:56 $

% FINDFILTERS is now done in SETFCN.
% filters = findfilters(this, varargin{:});

set(this, 'Filters', varargin)

% [EOF]

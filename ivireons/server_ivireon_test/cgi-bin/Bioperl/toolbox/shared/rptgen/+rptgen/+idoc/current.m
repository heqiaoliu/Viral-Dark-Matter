function idoc = current(varargin)
%   Returns current document
%

%    Copyright 2009 The Mathworks, Inc.

persistent CURRENT_IDOC

if ~exist('CURRENT_IDOC', 'var')
    CURRENT_IDOC = [];
end

if ((nargin > 0) && isa(varargin{1}, 'rptgen.idoc.Document'))
    CURRENT_IDOC = varargin{1};
end

idoc = CURRENT_IDOC;

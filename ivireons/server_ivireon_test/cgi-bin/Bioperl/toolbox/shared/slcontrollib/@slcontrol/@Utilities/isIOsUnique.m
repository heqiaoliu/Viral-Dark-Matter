function bool = isIOsUnique(this,io)
% ISACTIVEIOSUNIQUE returns true if all io have unique
% block/port combinations. This is used by LINEARIZE and FRESTIMATE
%

% Author(s): Erman Korkut 26-Feb-2009
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2009/03/30 23:57:57 $

bool = true;
io_str = cell(size(io));
for dt = length(io):-1:1
    io_str{dt} = sprintf('%s-%d',io(dt).Block,io(dt).Port);
end
if numel(io) ~= numel(unique(io_str))
    bool = false;
end

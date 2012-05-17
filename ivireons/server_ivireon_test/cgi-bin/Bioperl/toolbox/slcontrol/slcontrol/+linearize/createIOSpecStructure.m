function iospec = createIOSpecStructure(io)
% CREATEIOSPECSTRUCTURE  Create the MATLAB structure that represents I/O
% set to be used for linearization to pass to the jacobian engine.
 
% Author(s): Erman Korkut 05-Mar-2010
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2010/05/20 03:25:55 $

if isempty(io)
    iospec = [];
    return;
end
iospec = struct('Block','blk','Port',num2cell(ones(1,numel(io))));
for ct = 1:numel(io)
    iospec(ct).Block = io(ct).Block;
    iospec(ct).Port = io(ct).PortNumber;
    iospec(ct).Type = io(ct).Type;
    iospec(ct).OpenLoop = strcmp(io(ct).OpenLoop,'on');
end


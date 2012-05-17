function iostruct = createSCDPotentialLinearizationIOsStructure(io)
% CREATESCDPOTENTIALLINEARIZATIONIOSSTRUCTURE  Create the MATLAB structure
% to set the model parameter "SCDPotentialLinearizationIOs". This structure
% will be distributed among models in model reference scenarios.
 
% Author(s): Erman Korkut 18-Dec-2009
% Copyright 2005-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2010/02/25 08:33:57 $
iostruct = struct('Block','blk','Port',num2cell(ones(1,numel(io))));
for ct = 1:numel(io)
    iostruct(ct).Block = io(ct).Block;
    iostruct(ct).Port = io(ct).PortNumber;
end


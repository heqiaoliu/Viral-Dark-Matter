function [validIO, invalidIO] = checkModelIOPoints(models,ios)
% CHECKMODELOPOINTS Utility method to check that the passed ios are valid.
%
% [validIO, invalidIO] = checkModelIOPoints(models,ios)
%
% Inputs:
%   models - cell array of models where the ios are expected to be
%   ios    - array of linio objects to check
%
% Outputs:
%   validIO   - subset of the ios input argument that are valid for the 
%               specified model(s)
%   invalidIO - subset of the ios input argument that are not defines for
%               the specified model(s)
 
% Author(s): A. Stothert 16-Dec-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:53:38 $

% Make sure that all of the ios are valid
idxValid = true(size(ios));
for ct = numel(ios):-1:1
    % Make sure that the block and ports exist
    try
       ph = get_param(ios(ct).Block,'PortHandles');
    catch E %#ok<NASGU>
       idxValid(ct) = false;
       continue
    end
    try
       ph.Outport(ios(ct).PortNumber);
    catch E %#ok<NASGU>
       idxValid(ct) = false;
       continue
    end
    if ~isscalar(ios(ct).PortNumber)
       idxValid(ct) = false;
       continue
    end
    % Make sure that the IO is in the top model or in one of the model
    % references
    if ~strcmp(bdroot(ios(ct).Block),models)
       idxValid(ct) = false;
    end
end
validIO = ios(idxValid);
invalidIO = ios(~idxValid);
end
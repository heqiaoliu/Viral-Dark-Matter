function [dataRunID, dataRunIndex] = createRun(this, varargin)
    
    % Copyright 2009-2010 The MathWorks, Inc.
    
    if (nargin == 2)
        dataRunID = this.sigRepository.createEmptyRun(varargin{1},...
                                                      this.instanceID);
        dataRunIndex = this.getRunCount();
    else
        [dataRunID,...
         dataRunIndex] = this.createRunFromBaseWorkspace(varargin{:});
    end
    this.newRunIDs = dataRunID;
end
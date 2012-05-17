 function setMdlRefEnable(this, modelRefEnable)

%   Copyright 2010 The MathWorks, Inc.

    this.modelRefEnable = modelRefEnable; 
    if this.modelRefEnable 
        if isempty(this.covModelRefExcluded)
            this.covModelRefEnable = 'all';
        else
            this.covModelRefEnable = 'filtered';
        end
    else
        this.covModelRefEnable = 'off';
    end


    if ~this.modelRefEnable 
        SlCov.CovSettings.mdlRefClose(this);
    end
    
function this = CovSettings(modelH)

% Copyright 2009-2010 The MathWorks, Inc.


this = SlCov.CovSettings;
this.modelH = modelH;
this.getModelParams;
this.setCovPathStatus(this.covPath);
this.setMdlRefSelStatus
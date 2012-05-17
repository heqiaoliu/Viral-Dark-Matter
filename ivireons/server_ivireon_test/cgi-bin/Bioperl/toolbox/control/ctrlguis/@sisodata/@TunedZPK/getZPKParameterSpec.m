function Value = getZPKParameterSpec(this)
%

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:46:31 $

if isempty(this.ZPKParamSpec.GainSpec) || this.ZPKParamSpec.Dirty
    this.ZPKParamSpec.GainSpec = this.createGainSpec;
end

if this.ZPKParamSpec.Dirty
    this.ZPKParamSpec.PZGroupSpec = this.createPZGroupSpec;
    this.ZPKParamSpec.Dirty = false;
end

Value = struct('GainSpec',this.ZPKParamSpec.GainSpec, ...
               'PZGroupSpec',this.ZPKParamSpec.PZGroupSpec);
 function [tag desc] = getFilterPropertyValues(this)

%   Copyright 2009-2010 The MathWorks, Inc.

propNameIdx = this.filterPropertyNameIdx + 1;
tag = this.propMap(propNameIdx).valueTag;
desc = this.propMap(propNameIdx).valueDesc;



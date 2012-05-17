function [status, str] = postApply(this)

%   Copyright 2010 The MathWorks, Inc.

status  = true;
str = '';
state = {};

for idx = 1 : numel(this.filterState.keys)
    cv = this.filterState(idx);
    propName = this.propMap(idx).name;
    state.(propName){1} = this.propMap(idx).value{1} ;
    for vidx = 2:numel(cv)
       state.(propName){end+1} = this.propMap(idx).value{vidx} ;
    end
end
this.saveFilter(this.covFilter, state);




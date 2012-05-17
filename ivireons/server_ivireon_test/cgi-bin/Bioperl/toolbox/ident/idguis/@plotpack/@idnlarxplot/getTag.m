function tagstr = getTag(this)
% get uicomponent's tag

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:55 $

v = this.Current.OutputComboValue;
str = this.getOutputComboString;

if v==1 && ~this.isGUI
    tagstr = sprintf('%s:multi',str{v});
else
    tagstr = sprintf('%s',str{v});
end

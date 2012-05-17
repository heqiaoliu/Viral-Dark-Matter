function [b, str] = postApply(this)

%   Copyright 2010 The MathWorks, Inc.

b = true;
str = '';
if ~isempty(this.m_selectedItem)
    this.m_selectedItem(1:numel(get_param(this.m_callerSource.modelH, 'name'))) = [];
end
if isempty(this.m_selectedItem)
    this.m_selectedItem = '/';
else
     this.m_selectedItem(1) = [];
end
this.m_callerSource.setCovPathStatus(this.m_selectedItem);

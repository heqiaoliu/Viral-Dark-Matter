function this = MEView(name, desc)

%   Copyright 2009-2010 The MathWorks, Inc.

this = DAStudio.MEView;
this.Name        = name;
this.Description = desc;
this.InternalName = '';
this.GroupName = '';
this.SortName = '';
this.SortOrder = '';
% keep the ME & MEViewManager in sync with MEView changes
%this.enableLiveliness;
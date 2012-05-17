function varargout = parse4obj(this)
%PARSE4OBJ Utility used when exporting objects.

% This should be a private method

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:22:43 $

lbls = {};
names = {};

if nargin == 1,
    % Get variable labels and names
    for n = 1:length(this.Data)       
        newinfo = exportinfo(this.data);     
        lbls =  {lbls{:},newinfo.exportas.objectvariablelabel{:}};
        names = {names{:},newinfo.exportas.objectvariablename{:}};
    end
end 

if length(lbls) == length(this.DefaultLabels)
    lbls = this.DefaultLabels;
end

% Make the variable names and labels unique (if not already)
lbls = interspace(genvarname(lbls));
names = genvarname(names);

names = formatnames(this, lbls, names);

% Make the variable names and labels unique (if not already)
lbls = interspace(genvarname(lbls));
names = genvarname(names);

if nargout,
    varargout = {lbls, names};
else
    % Set the destination object specific properties
    set(this,'VariableLabels',lbls,...
        'VariableNames',names);
end

% [EOF]

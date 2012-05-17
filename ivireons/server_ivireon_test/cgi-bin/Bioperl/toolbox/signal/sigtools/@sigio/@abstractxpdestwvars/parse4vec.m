function varargout = parse4vec(this,varargin)
%PARSE4VEC Utility used when exporting vectors.

%   This should be a private method.

%   Author: P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:22:44 $

% If labels and variable names are specified explicitly.
if nargin > 2,  lbls = varargin{1}; end
if nargin > 3, names = varargin{2}; end

lbls = {};
names = {};
isvecobj = false;

if nargin == 1,
    
    % Form a cell array of handles to the objects to be exported (to be
    % able to call their respective exportinfo methods).
    if isempty(this.data), return; end
    data = cell(this.data);
    
    if isa(data{1},'sigutils.vector');
        data = cell(data{1});
        isvecobj = true;
    end
    
    % Get variable labels and names
    for n = 1:length(data),

        if isvecobj,
            % Call the vector/exportinfo method for each element contained
            % in the sigutils.vector object.
            newinfo = exportinfo(this.data);
        else
            % Call the class specific exportinfo
            newinfo = exportinfo(data{n});
        end
        
        lbls =  [lbls newinfo.variablelabel];
        names = [names newinfo.variablename];
    end
end 

if length(lbls) == length(this.DefaultLabels)
    lbls = this.DefaultLabels;
end

% Make the variable names and labels unique (if not already)
lbls  = interspace(genvarname(lbls));
names = genvarname(names);

names = formatnames(this, lbls, names);

if nargout,
    varargout = {lbls, names};
else
    % Set the destination object specific properties
    set(this,'VariableLabels',lbls,...
        'VariableNames',names);
end
   
% [EOF]
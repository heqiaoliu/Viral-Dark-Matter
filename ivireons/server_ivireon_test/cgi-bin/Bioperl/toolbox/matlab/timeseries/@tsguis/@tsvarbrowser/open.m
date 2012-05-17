function changeFlag = open(h, varargin)

% OPEN  Opens the varbrowser in the current state for 2d variables

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2007/06/14 05:13:01 $

% Extra argument controls the size of variables seen

import com.mathworks.toolbox.timeseries.*;
import java.util.*;
changeFlag = true;

% refresh veriable viewer
if ~isempty(h.filename) % file and pathname supplied
    xx = whos('-file',h.filename);
else
    xx = evalin('base','whos');
end

% Assemble variables structure
varStruc = repmat(struct('varname','','objclass','','objname','','objsize',''),...
    [0 1]);
ind = 1;
for k=1:length(xx)
    if any(strcmpi(xx(k).class,h.typesallowed))
        varStruc(ind).varname = xx(k).name;
        varStruc(ind).objclass = xx(k).class;
        varStruc(ind).objname = xx(k).name;
        varStruc(ind).objsize = xx(k).size;
        ind = ind+1;
    end
end

% If a varbrowser exists update it, else create it    
if ~isempty(h.javahandle) && isjava(h.javahandle) 
    % Abort if nothing has changed
    if ~isempty(h.variables) && ~isempty(varStruc) && ...               
       isequal({varStruc.('varname')},{h.variables.('varname')}) && ...
       isequal({varStruc.('varname')},{h.variables.('objclass')}) && ...
       isequal({varStruc.('varname')},{h.variables.('objname')}) && ...
       isequal({varStruc.('varname')},{h.variables.('objsize')})
        changeFlag = false;
        return
    end    
else
    if nargin>=2
        h.Model = ImportModel(varargin{1});
    else
        h.Model = ImportModel;
    end
    if ~isempty(h.ListSelectionMode)
        h.javahandle = ImportView(h.Model,h.ListSelectionMode);
    else
        h.javahandle = ImportView(h.Model);
    end
end
% Reassemble the new varbrowser table model
varVector = Vector;
for k=1:length(varStruc)   
    varVector.addElement({varStruc(k).varname, ...
        varStruc(k).objclass, varStruc(k).objname, mat2str(varStruc(k).objsize)});
end
h.variables = varStruc;
h.Model.resetData(varVector,{varStruc.('objclass')});
h.javahandle.refresh;    



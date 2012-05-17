function setIONames(this)
% update and store the IO names

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:37 $

unv = {};
ynv = {};
for k = 1:length(this.ModelData)
    if ~this.ModelData(k).isActive
        % skip inactive models
        continue;
    end
    modelk = this.ModelData(k).Model;
    un = modelk.uname;
    for  i = 1:length(un)
        if ~any(strcmp(unv,un{i}))
            unv = [unv;un{i}];
        end
    end
    yn = modelk.yname;
    for  i = 1:length(yn)
        if ~any(strcmp(ynv,yn{i}))
            ynv = [ynv;yn{i}];
        end
    end
end

% store the set of all I/O names
this.IONames.u = unv;
this.IONames.y = ynv;

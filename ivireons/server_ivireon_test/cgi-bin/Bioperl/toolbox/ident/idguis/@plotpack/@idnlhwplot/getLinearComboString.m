function [str,tag] = getLinearComboString(this,uname,yname)
%Construct the combo box list of strings for the linear I/O selection.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:56:27 $

if nargin<2
    str = cell(0,1);
    tag = cell(0,2);
    for k = 1:length(this.ModelData)
        if ~this.ModelData(k).isActive
            % skip inactive models
            continue;
        end
        modelk = this.ModelData(k).Model;
        unames = modelk.uname;
        ynames = modelk.yname;
        for ky = 1:length(ynames)
            for ku = 1:length(unames)
                thispair = sprintf('%s->%s',unames{ku},ynames{ky});
                if ~any(strcmp(str,thispair))
                    str{end+1,:} = thispair;
                    tag(end+1,:) = {unames{ku},ynames{ky}};
                end
            end
        end
    end

    %[str1,I,J] = unique(str,'first');
    %str = str1(J);

    if ~this.isGUI
        str = ['<all channels>';str];
        tag = [{'',''};tag];
    end
else
    str = sprintf('%s->%s',uname,yname);
end
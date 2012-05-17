function javaData = matlab2java(matlabData,Type)
% Convert two dimensional cell arrays to Java arrays
% Type: 'vector' or 'matrix'

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:50:37 $

if ~iscell(matlabData) || isempty(matlabData)
    javaData = javaArray('java.lang.Object', 1, 1);
    return
end

% Initialize java objects
if nargin<2 || strcmpi(Type,'matrix')
    sizes    = size(matlabData);
    javaData = javaArray('java.lang.Object',  sizes);

    for i = 1:sizes(1)
        for j = 1:sizes(2)
            current = matlabData{i,j};

            if ischar(current)
                javaData(i,j) = java.lang.String(current);
            elseif islogical(current)
                javaData(i,j) = java.lang.Boolean(current);
            elseif isa(current, 'double')
                javaData(i,j) = java.lang.Double(current);
            elseif ishandle(current)
                javaData(i,j) = java(current);
            else
                ctrlMsgUtils.error('Ident:utility:matlab2java1')
            end
        end
    end
else
    len =  length(matlabData);
    javaData = javaArray('java.lang.Object',len);
    for i = 1:len
        current = matlabData{i};
        if ischar(current)
            javaData(i) = java.lang.String(current);
        elseif islogical(current)
            javaData(i) = java.lang.Boolean(current);
        elseif isa(current, 'double')
            javaData(i) = java.lang.Double(current);
        elseif ishandle(current)
            javaData(i) = java(current);
        else
            ctrlMsgUtils.error('Ident:utility:matlab2java1')
        end
    end
end
function createobjstr(T,objname,h)

% Copyright 2004 The MathWorks, Inc.

%% Static method to create a string representing construction of a
%% specific object

props = fields(get(h));
T.addbuffer([objname ' = ' class(h) ';']);
for k=1:length(props)
    thisprop = get(h,props{k});
    if ~isequal(h.findprop(props{k}).FactoryValue,thisprop)
        if ischar(thisprop)
            T.addbuffer(['set(' ,objname, ',''' ,props{k}, ''',''' ,thisprop, ''')']);
        elseif isnumeric(thisprop)
            if length(thisprop)==1
                T.addbuffer(['set(' ,objname, ',''' ,props{k}, ''',' ,num2str(thisprop) ,')']);
            elseif length(thisprop)>1 
                T.addbuffer(['set(' ,objname, ',''' ,props{k}, ''',[' ,num2str(thisprop), '])']);
            end
        end
    end
end
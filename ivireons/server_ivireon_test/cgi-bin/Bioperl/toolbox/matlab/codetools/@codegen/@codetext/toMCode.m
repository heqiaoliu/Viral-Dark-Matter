function toMCode(hCodeLine,hText)
% Generates code based on input codetext object

% Copyright 2006 The MathWorks, Inc.

var = get(hCodeLine,'Text');
txt = [];
for n = 1:length(var)
    val = var{n};
    if ischar(val)
        try
            txt = [txt,val];
        catch
        end
    else
        hObj = val;
        if ~isprop(hObj,'Ignore') || ~get(hObj,'Ignore')
            try
                txt = [txt,get(hObj,'String')];
            catch
            end
        end
    end
end

hText.addln(txt);

function goToFunction(obj, functionName)
%editorservices.matlab.goToFunction Move to function in MATLAB program.
%   editorservices.matlab.goToFunction(EDITOROBJ, FUNCTION) highlights the
%   first line of the specified function in the open Editor document 
%   associated with EDITOROBJ. The document must contain MATLAB code. If 
%   the document contains more than one function with the same name, 
%   goToFunction scrolls to the first occurrence.
%
%   If openAndGoToFunction cannot find the function, it throws a
%   MATLAB:editorservices:NoSuchFunction exception.
%
%   Example: Open taxdemo.m and highlight the computeTax function.
%
%      taxDoc = editorservices.open(which('taxdemo.m'));
%      editorservices.matlab.goToFunction(taxDoc, 'computeTax');
%
%   See also editorservices.openAndGoToFunction, editorservices.EditorDocument/goToLine.

% Copyright 2009 The MathWorks, Inc.

checkInput(obj, 'com.mathworks.widgets.text.mcode.MLanguage', 'scalar')

text = obj.Text;
tree = mtree(text);
functions = Fname(tree);
[isFunction, fcnIndex] = ismember(functionName, strings(functions));
if ~isFunction
    error('MATLAB:editorservices:NoSuchFunction',...
        '%s is not a valid function name.', functionName);
end

functionIndices = functions.indices;
nodeIndex = functionIndices(fcnIndex);
fcnLine = lineno( functions.select(nodeIndex) );
goToLine(obj, fcnLine);
end

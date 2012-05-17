function newvalue = replacedlg

newvalue = [];
answer = inputdlg({'Specify a scalar to replace brushed data:'},...
    'Replace Brushed Data',1,{'0'}); 
if ~isempty(answer)
    try
        newvalue = eval(answer{1});
    catch %#ok<CTCH>
        newvalue = [];
    end
    if ~isscalar(newvalue)
        errordlg('Replacement must be a numeric scalar.', 'MATLAB', 'modal');
        return
    end
else
    return
end
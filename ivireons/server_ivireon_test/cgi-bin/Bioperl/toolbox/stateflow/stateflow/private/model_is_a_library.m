function result = model_is_a_library(modelH)
if strcmpi(get_param(modelH,'BlockDiagramType'),'library')
    result = 1;
else
    result = 0;
end;

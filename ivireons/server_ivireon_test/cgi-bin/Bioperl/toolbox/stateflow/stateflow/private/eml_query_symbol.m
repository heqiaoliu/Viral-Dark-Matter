%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = eml_query_symbol(objectId, pos)
% query_symbol is used by editor UI to display data value in tooltip

%   Copyright 2007-2009 The MathWorks, Inc.

result = [];

hEditor = eml_man('get_editor');
if isempty(hEditor)
    return;
end

try 
    answer = query_symbol_impl(objectId, pos);
    hEditor.documentDisplayTooltipSymbol(objectId, answer);

catch ME
    % If the editor is open, we MUST send the tooltip to it, as it is waiting.
    hEditor.documentDisplayTooltipSymbol(objectId, []);
    rethrow(ME);
end

return;

function valStr = query_symbol_impl(objectId, pos)

MAX_DISPLAY_DIMS = 2;
MAX_DISPLAY_ELEMS = 200;

valStr = [];

if is_eml_script(objectId)
    textBuf = sf('get', objectId, 'script.script');
else
    textBuf = sf('get', objectId, 'state.eml.script');
end
    
symbolName = extract_symbol_from_pos(textBuf, pos);

if ~isempty(symbolName)
  if is_eml_script(objectId)
      machineId = sf('get', objectId, 'script.activeMachineId');
  else
      chartId = sf('get',objectId,'state.chart');
      machineId = actual_machine_referred_by(chartId);
  end
  if machineId ~= 0
      dataVal = sfdebug('mex', 'watch_data', machineId, symbolName);
    displayMsg = [];
    if ndims(dataVal) > MAX_DISPLAY_DIMS
      displayMsg = ...
          sprintf('Number of dimensions too large (>%d) to display symbol value in tooltip.',MAX_DISPLAY_DIMS);
    elseif numel(dataVal) > MAX_DISPLAY_ELEMS
      displayMsg = ...
          sprintf('Number of elements too large (>%d) to display symbol value in tooltip.',MAX_DISPLAY_ELEMS);
    end
    
    if isempty(displayMsg)
      if ~ischar(dataVal) || ~strcmp(dataVal, 'Unrecognized symbol.')
        if ischar(dataVal)
          dataVal = sprintf('"%s"', dataVal);
        end
        valStr = evalc('disp(dataVal)');
        valStr = [symbolName ' =' 10 valStr(1:end-1)];
      end
    else
      dataValSizes = size(dataVal);
      str = ['[' int2str(dataValSizes(1))];
      for i=2:ndims(dataVal)
        str = [str 'x' int2str(dataValSizes(i))];          
      end          
      str = [str ' ' class(dataVal) ']'];
      valStr = [symbolName ' =' 10 str 10 displayMsg];
    end
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_alphanumeric(ch)

result = false;

if (ch >= 'a' && ch <= 'z') || ...
   (ch >= 'A' && ch <= 'Z') || ...
   (ch >= '0' && ch <= '9') || ...
   (ch == '_')
   result = true;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = extract_symbol_from_pos(textBuf, pos)

result = '';

if(pos > length(textBuf) || pos < 1)
  return;
end

% pos is often to the left by 1/2 a character so give us some 
% slack.  We should consider a smaller pos if possible.
if(pos>1 && ~is_alphanumeric(textBuf(pos)))
  pos = pos-1;
end

% Get the lower boundary
pl = pos;
while pl > 0 && is_alphanumeric(textBuf(pl))
    pl = pl - 1;
end
pl = pl + 1;

if pl > pos || (textBuf(pl) >= '0' && textBuf(pl) <= '9')
    % Either current pos is not alphanumeric, or the word begins with 0-9
    return;
end

% Get the upper boundary
pu = pos;
bufLen = length(textBuf);
while pu <= bufLen && is_alphanumeric(textBuf(pu))
    pu = pu + 1;
end
pu = pu - 1;

result = textBuf(pl:pu);
return;

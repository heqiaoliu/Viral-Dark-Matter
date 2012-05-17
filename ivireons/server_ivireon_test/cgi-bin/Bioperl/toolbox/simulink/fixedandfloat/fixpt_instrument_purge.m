function res = fixpt_instrument_purge(modelName,interactive,justLoad)
%FIXPT_INSTRUMENT_PURGE removes corrupt fixed-point instrumentation from a model
%
% The Fixed-Point Settings interface and the fixed-point autoscaling tool add
% callbacks to a model. For example, the Fixed-Point Settings interface
% appends commands to model-level callbacks.
%    StopFcn      ";fxptdlg('fxptdlg_store_cb');"
% These callbacks make the Fixed-Point Settings interface respond to simulation 
% events. In addition, the autoscaling tool adds instrumentation to some 
% parameter values.
%    OutDataType  "stealparameter(sprintf('sys/Gain'),'OutDataType',sfix(16))"
% This instrumentation gathers needed information.
%
% Normally, this instrumentation is removed. The Fixed-Point Settings interface
% removes its instrumentation when the model is closed. The autoscaling tool
% removes its instrumentation shortly after it is added. Removal of the
% instrumentation is robust to many error conditions, but there are cases
% where abnormal termination leaves fixed-point instrumentation in a model.
% 
% The purpose of this function is to find and remove fixed-point
% instrumentation left over from an abnormal termination.
%
% Usage
%  res = fixpt_instrument_purge(modelName,interactive);
%
%   interactive defaults to true which prompts for each change
%               false means all changes are automatically made.
  
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  
% $Date: 2007/06/18 23:33:45 $

res.countStaleInstrumentationFound   = 0;
res.countStaleInstrumentationChanged = 0;

firstTimeHelp(true);

if nargin < 1
  modelName = bdroot;
end

if nargin < 2
  interactive = true;
end

if nargin < 3
  justLoad = false;
end

if interactive
  actionMode = 'ask';
else
  actionMode = 'yes_all';
end

if justLoad
  load_system(modelName);
else
  open_system(modelName);
end

%
% remove uses of stealparameter function
%
blks = find_system(modelName,...
                   'LookUnderMasks','all',...
                   'Type','block');

nblks = length(blks);

undesiredStr = 'stealparameter(';
    
for iBlk = 1:nblks
  
  curBlk = blks{iBlk};

  dialogParams = get_param(curBlk, 'ObsoleteDialogParameters');
  
  if isempty(fieldnames(dialogParams))
      dialogParams = get_param(curBlk,'DialogParameters');
  end

  UDTParams = find_system(curBlk, 'BlockParamType', 'DataTypeStr');
  if isempty(UDTParams)
      UDTParamNames = {};
  else
      UDTParams = UDTParams.get;
      UDTParamNames = {UDTParams(:).ParameterName};
  end
  
  if isempty(dialogParams)
    continue;
  end
  
  fn = fieldnames(dialogParams);
  
  for iParam = 1:length(fn)
    
    curParamName = fn{iParam};
    
    % Skip unified data type parameters
    if ismember(curParamName, UDTParamNames)
        continue;
    end
    
    curParamInfo = dialogParams.(curParamName);
    
    if ~strcmp(curParamInfo.Type,'string')
      continue
    end
    
    curStr = get_param(curBlk,curParamName);
    
    % Look for something like this
    %    stealparameter(sprintf('sys/Gain'),'OutDataType',sfix(16))
    %
    if ~isempty(strfind(curStr,undesiredStr))

      % Find the param_name
      %    stealparameter(sprintf('sys/Gain'),'OutDataType',sfix(16))
      %                                        ^^^^^^^^^^^
      %                                        here find this above
      idxCurStr = strfind(curStr,curParamName);
      
      if isempty(idxCurStr)
        
        error('simulink:fixedpoint:fixpt_instrument_purge',...
              ['Could not remove call to stealparameter from block %s ' ...
               'because of inconsistent parameter names.  Open the ' ...
               'block and manually change the parameters.'], ...
              curBlk);
      end
      
      % want to keep last part
      %    stealparameter(sprintf('sys/Gain'),'OutDataType',sfix(16))
      %                                                     ^^^^^^^^
      %                                                     keep above
      idxStart = max(idxCurStr) + length(curParamName) + 2; % for quote and comma
      
      newStr = curStr(idxStart:end);
      
      % Remove extra trailing parentheses
      %    sfix(16))
      %            ^
      %            kill
      remove = sum(newStr==')') - sum(newStr=='(');
      
      newStr = newStr(1:(end-remove));
      
      [res,actionMode] = handleChange(res,curBlk,undesiredStr,curParamName,curStr,newStr,actionMode);
      switch actionMode
       case {'quit'}
          % If user wants to quit
        return;
      end
    
    end
  end
end

%
% remove model level callbacks to fixed-point settings dialog
%
curRoot = modelName;

allFields = fieldnames(get_param(curRoot,'objectparameters'));

undesiredStr = 'fxptdlg(';
      
for iField = 1:length(allFields)
  %
  % find fields that end in "Fcn"
  % these should be callbacks
  %
  curParamName = allFields{iField};

  if length(curParamName) > 2

    if strcmp( curParamName((-2:0)+end), 'Fcn')

      curStr = get_param( curRoot, curParamName );

      if ~isempty(strfind(curStr,undesiredStr))

        newStr = removeFxptdlg(curStr);
      
        [res,actionMode] = handleChange(res,curRoot,undesiredStr,curParamName,curStr,newStr,actionMode);
        switch actionMode
         case {'quit'}
          % If user wants to quit
          return;
        end
    
      end
    end
  end
end


function [doChange,actionMode] = askChoice(actionMode_in)
 
  doChange = 'ask';
  
  actionMode = actionMode_in;
  
  if firstTimeHelp
    lastResponse = 'help';
  else
    lastResponse = '';
  end

  while strcmp(doChange,'ask')
    
    if ~strcmp(lastResponse,'')
      
      disp(sprintf('Valid choices are:'))
      disp(sprintf('  y     yes'))
      disp(sprintf('  n     no'))
      disp(sprintf('  a     yes to all changes'))
      disp(sprintf('  q     quit'))
      disp(sprintf('  help  display valid response definitions'))
    end          
    
    lastResponse = input('Accept proposed change? ([y], n, a, q, or help) ','s');
    
    switch lower(lastResponse)
      
     case {'','y'}
      
      doChange = 'yes';
      
     case 'n'
      
      doChange = 'no';
      
     case 'a'
      
      doChange = 'yes';
      
      actionMode = 'yes_all';
      
     case 'q'
      
      doChange = 'no';
      
      actionMode = 'quit';
      
     otherwise
      disp('Unrecognized response')
      
    end
  end
  
  
function newStr = removeFxptdlg(curStr)
  
  newStr = removeFxptdlgStrRecursive(curStr);

  tempStr = '';

  while ~strcmp(newStr,tempStr)

    tempStr = newStr;
    newStr = strrep(tempStr,';;',';');
  end

  if strcmp(newStr,';')
    newStr = '';
  end
  
function newStr = removeFxptdlgStrRecursive(curStr)
  
  newStr = curStr;

  undesiredStr = 'fxptdlg(';
      
  idxCurStr = strfind(curStr,undesiredStr);
      
  if isempty(idxCurStr)
    % stops recursion
    return;
  end
    
  idxStart = min(idxCurStr);

  idxCheck = idxStart + length(undesiredStr) - 1; % keep open paren
  
  tempStr = curStr(idxCheck:end);
  
  % consider case
  %    'fxptdlg((stuff)(stuff2)); (other_stuff_to_keep)'
  % when cumsum first gets to zero, thats the closing
  % paren for the fxptdlg stuff
  %
  parenCount = cumsum( (tempStr=='(') - (tempStr==')') );
  
  idxEnd = idxCheck - 1 + min(find(parenCount==0));  %#ok don't use find-last, code to be used in old versions too
  
  newStr(idxStart:idxEnd)=[];
  
  newStr = removeFxptdlgStrRecursive(newStr);

  
function [res,actionMode] = handleChange(res_in,curObj,curCrud,curParamName,curStr,newStr,actionMode_in)
  
  res = res_in;
  actionMode = actionMode_in;

  res.countStaleInstrumentationFound = res.countStaleInstrumentationFound + 1;

  switch actionMode
    
   case {'yes_all'}
    
    doChange = 'yes';
  
   case {'quit'}

    return;

   otherwise
    
    doChange = 'ask';
  
  end

  curRoot = bdroot(curObj);
    
  curIsLibrary = strcmp(get_param(curRoot,'BlockDiagramType'), 'library');
  
  if curIsLibrary
    curIsLocked = strcmp('on',get_param(curRoot, 'Lock'));
  else
    curIsLocked = false;
  end
  
  if strcmp(doChange,'ask')
    
    disp(sprintf('\nLeft over call to\n     %s)\nwas found in model \n     %s',curCrud,curRoot))
    if curIsLibrary
      if curIsLocked
        disp(sprintf('Caution: this is a locked library.'))
      else
        disp(sprintf('Note: this is an unlocked library.'))
      end
    end
    disp(sprintf('The path to the object to be modified is\n     %s',curObj))
    disp(sprintf('The parameter name is\n     %s',curParamName))
    disp(sprintf('The proposal is to change the parameter from\n     ''%s''\nto\n     ''%s''',curStr,newStr))
    
    [doChange,actionMode] = askChoice(actionMode);
    
    switch actionMode
     case {'quit'}
      return;
    end
  end    
  
  if strcmp(doChange,'yes')
    
    if curIsLibrary
      if curIsLocked
        set_param(curRoot, 'Lock', 'off');
      end
    end
    
    set_param(curObj,curParamName,newStr);
  
    res.countStaleInstrumentationChanged = res.countStaleInstrumentationChanged + 1;
  end
  
function retVal = firstTimeHelp(doReset)  
 
persistent giveHelp;

if nargin < 1
  doReset = false;
end

if doReset
  retVal = 1;
  giveHelp = 1;
else
  retVal = giveHelp; 
  giveHelp = 0;
end


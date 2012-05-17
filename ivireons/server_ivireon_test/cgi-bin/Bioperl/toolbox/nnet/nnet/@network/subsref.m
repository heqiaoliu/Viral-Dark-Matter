function [v,out2,out3]=subsref(vin,subscripts)
%SUBSREF Reference fields of a neural network.

%  Mark Beale, 11-31-97
%  Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.7.4.7 $

% Assume no error
err = '';

% Evaluate network
if isa(vin,'network') && strcmp(subscripts(1).type,'()')
   subs = subscripts(1).subs;
   [v,out2,out3] = sim(vin,subs{:});
   return
end

% Call method
if subscripts(1).type == '.'
  subs1 = subscripts(1).subs;
  if strmatch(subs1,...
      {'adapt','configure','gensim','init',...
      'perform','sim','train','view','unconfigure'})
    if length(subscripts) == 1
      feval(subs1,vin);
    else
    end
    return
  end
end
v = vin;

% Short hand fields
%type = subscripts(1).type;
%subs = subscripts(1).subs;

% For each level of subscripts
for i=1:length(subscripts)

  type = subscripts(i).type;
  subs = subscripts(i).subs;
  
  switch type
  
  % Parentheses
  case '()'
    try
      eval('v=v(subs{:});');
    catch me
      err = me.message;
    end
  
  % Curly bracket
  case '{}'
    try
      eval('v=v{subs{:}};');
    catch me
      err = me.message;
    end
  
  % Dot
  case '.'
    % NNET 5.0 Compatibility
    if strcmpi(subs,'numTargets')
      subs = 'numOutputs';
      nnerr.obs_use(mfilename,'"numTargets" is obsolete.',...
        'Use "numOutputs" to determine numbers of outputs and targets.');
    elseif strcmpi(subs,'targetConnect')
      subs = 'outputConnect';
      nnerr.obs_use(mfilename,'"targetConnect" is obsolete.',...
        'Use "outputConnect" to determine connections for outputs and targets.');
    elseif strcmpi(subs,'targets')
      subs = 'outputs';
      nnerr.obs_use(mfilename,'"targets" is obsolete.',...
        'Use "outputs" to determine properties of outputs and targets.');
    end
      
    if isa(v,'cell')
      if nn_iscellstruct_field(v,subs)
        v = nn_cellstruct_select(v,subs);
        moresubs = subscripts(i+1:end);
        if ~isempty(moresubs)
          for j=1:numel(v)
            v{j} = subsref(v{j},moresubs);
          end
        end
        return
      end
    end
    
    if isa(v,'struct') || isa(v,'network')
      subs = matchfield(subs,v);
    end

    try
      v = v.(subs);
    catch me
      err = me.message;
    end
  end
  
  % Error message
  if ~isempty(err)
    
    % Work around: remove any reference to variable V
    ind = findstr(err,' ''v''');
    if (ind)
      err(ind+(0:3)) = [];
    end
    
  nnerr.throw('Args',err)
  end
end

function field = matchstring(field,strings)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

for i=1:length(strings)
  if strcmpi(field,strings{i})
    field = strings{i};
    return;
  end
end
field = [];

function field = matchfield(field,structure)
% MATCHFIELD replaces FIELD with any field belonging to STRUCTURE
% that is the same when case is ignored.

field = matchstring(field,fieldnames(structure));

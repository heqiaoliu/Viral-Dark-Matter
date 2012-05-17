function SimOpt = evalForm(this,ModelWS,ModelWSVars)
% Evaluates literal optimization settings in appropriate workspace.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.4 $ $Date: 2007/11/09 21:02:19 $
%   Copyright 1986-2004 The MathWorks, Inc.

fields = fieldnames(this)';
junk = cell(size(fields));
createFlds = {fields{:}; junk{:}};
createFlds = {createFlds{:}};
SimOpt = struct(createFlds{:});

% Transfer text fields
% Evaluate numeric settings
NumFields = {'AbsTol','FixedStep','InitialStep','MaxStep','MinStep','RelTol'};
%for ct=1:length(NumFields)
for ct=1:numel(fields)
  if ismember(fields{ct},NumFields)
    f = NumFields{ct};
    if strcmp(this.(f),'auto')
      SimOpt.(f) = 'auto';
    else
      [v,Fail] = utEvalModelVar(this.(f),ModelWS,ModelWSVars);
      if Fail
        ctrlMsgUtils.error( 'SLControllib:slcontrol:InvalidSettingNoVariable', ...
                            f, this.(f) )
      end
      SimOpt.(f) = v;
    end
  else
    SimOpt.(fields{ct}) = this.(fields{ct});
  end
end

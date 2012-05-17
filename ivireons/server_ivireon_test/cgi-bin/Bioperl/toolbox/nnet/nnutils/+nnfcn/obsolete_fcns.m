function mfcns = obsolete_fcns

% Copyright 2010 The MathWorks, Inc.

mfiles = nn_obs_mfiles;
mfcns = nn_path2mfcn(mfiles);
i = strmatch('Contents',mfcns,'exact');
if ~isempty(i)
  mfcns(i) = [];
end

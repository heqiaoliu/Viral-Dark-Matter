function varname = addbuffervar(h,I)

% Copyright 2004 The MathWorks, Inc.

%% Creates a new variable for the index array I and assigns it to
%% the specified MAT file. The name of the variable is returned 
%% to be used in cinstructing the M code for the buffer

filepath = fullfile(h.Path,h.Filename);
matfilepath = sprintf('%s.mat',filepath);

%% If there is no MAT file or no data has been previoisly saved
%% - create one, write the index variable into it with variable name I1
if ~exist(matfilepath) || strcmp(h.Saveddata,'off')
    h.Saveddata = 'on'; % MAT file has been used for storage
    varname = 'I1';
    I1 = I;
    eval(sprintf('save %s %s',matfilepath,varname));
    return
end

%% Get a cell array of variables in the current MAT file
vars = whos('-file',matfilepath);
varnames = {vars.('name')};

%% Find a variable name which is not already stored in this MAT file
k = 2;
while any(strcmp(sprintf('I%d',k),varnames))
    k=k+1;
end
varname = sprintf('I%d',k);

%% Append the new variable to the MAT file
eval(sprintf('%s=I;',varname));
eval(sprintf('save -append %s %s',matfilepath,varname));

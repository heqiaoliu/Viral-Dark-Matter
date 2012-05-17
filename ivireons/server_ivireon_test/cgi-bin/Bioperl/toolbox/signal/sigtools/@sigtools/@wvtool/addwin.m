function addwin(hV, winobjs, winvects, AddReplaceMode, currentindex, names)
%ADDWIN Add windows to WVTool.
%
%   ADDWIN(HV, WINOBJS) adds the WINOBJS sigwin.window objects in the 
%   HV instance of WVTOOL.
%
%   ADDWIN(HV, WINOBJS, WINVECTS) adds the WINOBJS sigwin.window
%   objects and the WINVECTS window vectors (cell array) into WVTool.
%
%   ADDWIN(HV, WINOBJS, WINVECTS, ADDREPLACEMODE) the ADDREPLACEMODE can be 
%   'Add' or 'Replace'(default).
%
%   ADDWIN(HV, WINOBJS, WINVECTS, ADDREPLACEMODE, CURRENTINDEX) allow the user to specify
%   which window is the current one (bold and measured). By default, CURRENTINDEX = 1.

%   Author(s): V.Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.4 $  $Date: 2009/03/09 19:35:49 $

if ~isrendered(hV),
    error(generatemsgid('notRendered'), 'WVTool internal error: object not rendered.');
end
if nargin<4, AddReplaceMode = 'Replace'; end
if nargin<5, currentindex = 1; end

oldM = 0;
oldN = 0;

% Get the current line handles in the "Time domain" plot
htline = findall(get(hV, 'FigureHandle'), 'Tag' , 'tline');
 
% Replace mode replaces the current (last) window
if strcmpi(AddReplaceMode, 'Replace') && ~isempty(htline),
    htline(1) = [];
end

% Reverse order to keep the same colors
htline = htline(end:-1:1);

% Get the size of the datas (oldN lines of oldM points)
if ~isempty(htline),
    oldM = length(get(htline(1), 'YData'));
    oldN = length(htline);
end
   
% Number of new windows
newNObj = length(winobjs);
newNVect = length(winvects);
newN = newNObj+newNVect;

% Define the maximum length of the new windows
winlength = zeros(1, newNObj)+newNVect;
for i=1:newNObj,
    winlength(i) = length(generate(winobjs(i)));
end
for i=1:newNVect,
    winlength(newNObj+i) = length(winvects{i});
end
newM = max(winlength);

% Generate a matrix of NaN that can contains all the datas
M = max(oldM, newM);
N = oldN+newN;
data = NaN*ones(M,N);

% Put the old datas in the matrix
% Each window is store in a column of the data matrix
for i = 1:oldN,
    data(1:oldM,i) = get(htline(i), 'YData')';
    if nargin < 6
        names{i} = ['window#',num2str(i)];
    end
end

% Concatenate the new datas with the old ones in the matrix
% Each window is store in a column of the data matrix
for i = 1:newN,
    if i<=newNObj,
        vect = generate(winobjs(i));
        data(1:winlength(i),oldN+i) = vect(:);
    else
        vect = winvects{i-newNObj};
        data(1:winlength(i),oldN+i) = vect(:);
    end
    if nargin < 6
        names{oldN+i} = ['window#',num2str(oldN+i)];
    end
end

names = strrep(names, '_', '\_');

% Plot the data in the viewer
hView = getcomponent(hV, '-class', 'siggui.winviewer');

% Specify the names used for the legend 
set(hView, 'Names', names);

% Compute the spectral window
[t, f, fresp] = spectralwin(hView, data);

% Plot
plot(hView, t, data, f, fresp);

% Bold the first (current) window
boldcurrentwin(hView, currentindex);

% Measure the current window
[FLoss, RSAttenuation, MLWidth] = measure_currentwin(hView, 1);

% Display the measurements
display_measurements(hView, FLoss, RSAttenuation, MLWidth);

% [EOF]

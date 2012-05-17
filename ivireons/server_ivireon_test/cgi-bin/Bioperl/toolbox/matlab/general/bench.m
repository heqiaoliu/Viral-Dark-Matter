function times = bench(count)
%BENCH  MATLAB Benchmark
%   BENCH times six different MATLAB tasks and compares the execution
%   speed with the speed of several other computers.  The six tasks are:
%
%    LU       LAPACK.                  Floating point, regular memory access.
%    FFT      Fast Fourier Transform.  Floating point, irregular memory access.
%    ODE      Ordinary diff. eqn.      Data structures and functions.
%    Sparse   Solve sparse system.     Sparse linear algebra.
%    2-D      plot(fft(eye)).          2-D line drawing graphics.
%    3-D      MathWorks logo.          3-D animated OpenGL graphics.
%
%   A final bar chart shows speed, which is inversely proportional to
%   time.  Here, longer bars are faster machines, shorter bars are slower.
%
%   BENCH runs each of the six tasks once.
%   BENCH(N) runs each of the six tasks N times.
%   BENCH(0) just displays the results from other machines.
%   T = BENCH(N) returns an N-by-6 array with the execution times.
%
%   The comparison data for other computers is stored in a text file:
%     fullfile(matlabroot, 'toolbox','matlab','general','bench.dat')
%   Updated versions of this file are available from <a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=1836&objectType=file#','-browser')">MATLAB Central</a>
%   Note the link above opens your system web browser as defined by WEB.
%
%   Fluctuations of five or 10 percent in the measured times of repeated
%   runs on a single machine are not uncommon.  Your own mileage may vary.
%
%   This benchmark is intended to compare performance of one particular
%   version of MATLAB on different machines.  It does not offer direct
%   comparisons between different versions of MATLAB.  The tasks and
%   problem sizes change from version to version.
%
%   The 2-D and 3-D tasks measure graphics performance, including software
%   or hardware support for OpenGL.  The command
%      opengl info
%   describes the OpenGL support available on a particular machine.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.4.3.4.1 $  $Date: 2010/08/03 18:55:01 $

if nargin < 1, count = 1; end;
times = zeros(count,6);
fig1 = figure;
set(fig1,'pos','default','menubar','none','numbertitle','off', ...
    'name','MATLAB Benchmark')
hax1 = axes('pos',[0 0 1 1],'parent',fig1);
axis(hax1,'off');
%text(.5,.5,'MATLAB Benchmark','horizontal','center','fontsize',18)
text(.5,.6,'MATLAB Benchmark','parent',hax1,'horizontalalignment','center','fontsize',18)
task = text(.50,.42,'','parent',hax1,'horizontalalignment','center','fontsize',18);
drawnow
pause(1);

% Use a private stream to avoid resetting the global stream
stream = RandStream('mt19937ar');

problemsize = zeros(1, 4);

bench_lu(stream);
bench_fft(stream);
bench_ode;
bench_sparse;
bench_2d('Off');
bench_3d(false);    

for k = 1:count
    
    % LU, n = 1000.
    set(task,'string','LU')
    drawnow
    [times(k,1), problemsize(1)] = bench_lu(stream);
    
    % FFT, n = 2^20.    
    set(task,'string','FFT')
    drawnow
    [times(k,2), problemsize(2)] = bench_fft(stream);
    
    % ODE. van der Pol equation, mu = 1
    set(task,'string','ODE')
    drawnow
    [times(k,3), problemsize(3)] = bench_ode;
    
    % Sparse linear equations
    set(task,'string','Sparse')
    drawnow
    [times(k,4), problemsize(4)] = bench_sparse;
    
    % 2-D graphics
    set(task,'string','2-D')
    drawnow
    pause(1)
    times(k,5) = bench_2d('On');
 
    % 3-D graphics. Vibrating logo.
    set(task,'string','3-D')
    drawnow
    pause(1)
    times(k,6) = bench_3d(true);    
    
end  % loop on k

% Compare with other machines.  Get latest data file, bench.dat, from
% MATLAB Central at the URL given in the help at the beginning of bench.m

if exist('bench.dat','file') ~= 2
    warning('MATLAB:bench:noDataFileFound', 'The bench.dat data file that contains comparison data is not available.')
    return
end
fp = fopen('bench.dat', 'rt');

% Skip over headings in first six lines.
for k = 1:6
    fgetl(fp);
end

% Read the comparison data

specs = {};
T = [];
details = {};
g = fgetl(fp);
m = 0;
desclength = 61;
while length(g) > 1
    m = m+1;
    specs{m} = g(1:desclength); %#ok<AGROW>
    T(m,:) = sscanf(g((desclength+1):end),'%f')'; %#ok<AGROW>
    details{m} = fgetl(fp); %#ok<AGROW>
    g = fgetl(fp);
end

% Close the data file
fclose(fp);

% Determine the best 10 runs (if user asked for at least 10 runs)
if count > 10
    warning('MATLAB:bench:display10BestTrials', '%s\n%s\n%s%d%s', ...
        'BENCH will only display the 10 best times on the comparison graph and in the table of results', ...
        'in the figure window, to prevent the graph and table from being overcrowded.', ...
        'However, the output argument of BENCH will contain data from all ', ...
        count, ' trials.');
    totaltimes = 100./sum(times, 2);
    [~, timeOrder] = sort(totaltimes, 'descend'); 
    selected = timeOrder(1:10);
else
    selected = 1:count;
end

meanValues = mean(T, 1);

% Add the current machine and sort
T = [T; times(selected, :)];
this = [zeros(m,1); ones(length(selected),1)];
if count==1
    % if a single BENCH run
    specs(m+1) = {['This machine' repmat(' ', 1, desclength-12)]};
    details{m+1} = ['It''s your machine running MATLAB ',  version];
else
    for k = m+1:size(T, 1)
        ind = k-m; % this varies 1:length(selected)
        sel = num2str(selected(ind));
        specs(k) = {['This machine (run ', sel, ')' repmat(' ', 1, desclength-18-length(sel))]}; %#ok<AGROW>
        details{k} = ['It''s your machine running MATLAB ' version ', run ' sel]; %#ok<AGROW>
        
    end
end
scores = mean(bsxfun(@rdivide, T, meanValues), 2);
m = size(T, 1);

% Normalize by the sum of meanValues to bring the results in line with
% earlier implementation 
speeds = (100/sum(meanValues))./(scores);
[speeds,k] = sort(speeds);
specs = specs(k);
details = details(k);
T = T(k,:);
this = this(k);

% Horizontal bar chart. Highlight this machine with another color.

clf(fig1)

% Stretch the figure's width slightly to account for longer machine
% descriptions
units1 = get(fig1, 'Units');
set(fig1, 'Units', 'normalized');
pos1 = get(fig1, 'Position');
set(fig1, 'Position', pos1 + [-0.1 -0.1 0.2 0.1]);
set(fig1, 'Units', units1);

hax2 = axes('position',[.4 .1 .5 .8],'parent',fig1);
barh(hax2,speeds.*(1-this),'y')
hold(hax2,'on')
barh(hax2,speeds.*this,'m')
set(hax2,'xlim',[0 max(speeds)+.1],'xtick',0:4:max(speeds))
title(hax2,'Relative Speed')
axis(hax2,[0 max(speeds)+.1 0 m+1])
set(hax2,'ytick',1:m)
set(hax2,'yticklabel',specs,'fontsize',9)

% Display report in second figure
fig2 = figure('pos',get(fig1,'pos')+[50 -150 50 0], 'menubar','none', ...
    'numbertitle','off','name','MATLAB Benchmark (times in seconds)');

% Defining layout constants - change to adjust 'look and feel'
% The names of the tests
TestNames = {'LU', 'FFT', 'ODE', 'Sparse', '2-D', '3-D'};
testDatatips = {sprintf('LU of a %d-by-%d matrix', problemsize(1), problemsize(1)), ...
    sprintf('FFT of a %d-element vector', problemsize(2)), ...
    sprintf('Solution from t=0 to t=%g', problemsize(3)), ...
    sprintf('Solving a %d-by-%d sparse linear system', problemsize(4), problemsize(4)), ...
    'Bernstein polynomial graph', ...
    'Animated L-shaped membrane'};
% Number of test columns
NumTests = size(TestNames, 2);
NumRows = m+1;      % Total number of rows - header (1) + number of results (m)
TopMargin = 0.05; % Margin between top of figure and title row
BotMargin = 0.20; % Margin between last test row and bottom of figure
LftMargin = 0.03; % Margin between left side of figure and Computer Name
RgtMargin = 0.03; % Margin between last test column and right side of figure
CNWidth = 0.40;  % Width of Computer Name column
MidMargin = 0.03; % Margin between Computer Name column and first test column
HBetween = 0.005; % Distance between two rows of tests
WBetween = 0.015; % Distance between two columns of tests
% Width of each test column
TestWidth = (1-LftMargin-CNWidth-MidMargin-RgtMargin-(NumTests-1)*WBetween)/NumTests;
% Height of each test row
RowHeight = (1-TopMargin-(NumRows-1)*HBetween-BotMargin)/NumRows;
% Beginning of first test column
BeginTestCol = LftMargin+CNWidth+MidMargin;
% Retrieve the background color for the figure
bc = get(fig2,'Color');
YourMachineColor = [0 0 1];

% Create headers

% Computer Name column header
uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
    'Position', [LftMargin 1-TopMargin-RowHeight CNWidth RowHeight],...
    'String', 'Computer Type', 'BackgroundColor', bc, 'Tag', 'Computer_Name','FontWeight','bold');

% Test name column header
for k=1:NumTests
    uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
        'Position', [BeginTestCol+(k-1)*(WBetween+TestWidth) 1-TopMargin-RowHeight TestWidth RowHeight],...
        'String', TestNames{k}, 'BackgroundColor', bc, 'Tag', TestNames{k}, 'FontWeight', 'bold', ...
        'TooltipString', testDatatips{k});
end
% For each computer
for k=1:NumRows-1
    VertPos = 1-TopMargin-k*(RowHeight+HBetween)-RowHeight;
    if this(NumRows - k)
        thecolor = YourMachineColor;
    else
        thecolor = [0 0 0];
    end
    % Computer Name row header
    uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
        'Position', [LftMargin VertPos CNWidth RowHeight],...
        'String', specs{NumRows-k}, 'BackgroundColor', bc, 'Tag', specs{NumRows-k},...
        'TooltipString', details{NumRows-k}, 'HorizontalAlignment', 'left', ...
        'ForegroundColor', thecolor);
    % Test results for that computer
    for n=1:NumTests
        uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
            'Position', [BeginTestCol+(n-1)*(WBetween+TestWidth) VertPos TestWidth RowHeight],...
            'String', sprintf('%.4f',T(NumRows-k, n)), 'BackgroundColor', bc, ...
            'Tag', sprintf('Test_%d_%d',NumRows-k,n), 'ForegroundColor', thecolor);
    end
end

% Warning text
uicontrol(fig2, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.01 0.01 0.98 BotMargin-0.02], 'BackgroundColor', bc, 'Tag', 'Disclaimer', ...
    'String', sprintf('%s\n%s\n%s','Place the cursor near a computer name for system and version details.  Before using', ...
    'this data to compare different versions of MATLAB, or to download an updated timing data file,',...
    'see the help for the bench function by typing ''help bench'' at the MATLAB prompt.'));

set([fig1 fig2], 'NextPlot', 'new');
end
% ----------------------------------------------- %
function B = bernstein(x,n)
% BERNSTEIN  Generate Bernstein polynomials.
% B = bernstein(x,n) is a length(x)-by-n+1 matrix whose columns
% are the Bernstein polynomials of degree n evaluated at x,
% B_sub_k(x) = nchoosek(n,k)*x.^k.*(1-x).^(n-k), k = 0:n.

x = x(:);
B = zeros(length(x),n+1);
B(:,1) = 1;
for k = 2:n+1
    B(:,k) = x.*B(:,k-1);
    for j = k-1:-1:2
        B(:,j) = x.*B(:,j-1) + (1-x).*B(:,j);
    end
    B(:,1) = (1-x).*B(:,1);
end
end
% ----------------------------------------------- %
function [t n] = bench_lu(stream)
% LU, n = 1000.
n = 1000;
reset(stream,0);
A = randn(stream,n,n);
tic
lu(A); 
t = toc;
end
% ----------------------------------------------- %
function [t n] = bench_fft(stream)
% FFT, n = 2^20.
n = 2^20;
reset(stream,1);
x = randn(stream,1,n);
tic;
fft(x); 
fft(x); 
t = toc;
end
% ----------------------------------------------- %
function [t n] = bench_ode
% ODE. van der Pol equation, mu = 1
F = @vdp1;
y0 = [2; 0]; 
tspan = [0 eps];
[s,y] = ode45(F,tspan,y0);  %#ok Used  to preallocate s and  y   
tspan = [0 400];
n = tspan(end);
tic
[s,y] = ode45(F,tspan,y0); %#ok Results not used -- strictly for timing
t = toc;
end
% ----------------------------------------------- %
function [t n] = bench_sparse
% Sparse linear equations
n = 300;
A = delsq(numgrid('L',n));
n = size(A, 1);
b = sum(A)';
tic
A\b; %#ok Result not used -- strictly for timing
t = toc;
end
% ----------------------------------------------- %
function t = bench_2d(isVisible)
% 2-D graphics. Vibrating logo.
x = (0:1/256:1)';
hh = figure('doublebuffer','on', 'Visible', isVisible);
aa = axes('parent',hh);
plot(aa,x,bernstein(x,0))
drawnow
tic
for j = 1:2
    for n = [1:12 11:-1:2]
        plot(aa,x,bernstein(x,n))
        drawnow
    end
end
t = toc;
close(hh)
end
% ----------------------------------------------- %
function t = bench_3d(isVisible)
% 3-D graphics. Vibrating logo.
% Gouraud lighting allows smooth motion with OpenGL.
L1 = 40*membrane(1,25);
L2 = 10*membrane(2,25);
L3 = 10*membrane(3,25);
mu = sqrt([9.6397238445, 15.19725192, 2*pi^2]);
n = 40;

evalc('logo');
if isVisible
    set(logoFig,'color',[.8 .8 .8])
else
    set(logoFig,'color',[.8 .8 .8], 'Visible', 'Off')
end
s = findobj(logoFig, 'type','surf', 'tag', 'TheMathWorksLogo');
set(s,'facelighting','gouraud')

tic
for j = 0:n
    t = 0.5*(1-j/n);
    L = cos(mu(1)*t)*L1 + sin(mu(2)*t)*L2 + sin(mu(3)*t)*L3;
    set(s,'zdata',L)
    drawnow
end
t = toc;
if isVisible
    pause(1)
end
close(logoFig)
end

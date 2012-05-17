function txt = guiDisplay(nlsys,Name)
%guiDisplay  Get HTML formatted string for short display of model characteristics
% in GUI.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/12/04 22:34:58 $

if nargin<2
    Name = inputname(1);
end
    
txt = cell(0,1);

% model name
txt{end+1,1} = sprintf('<body style="font-size:100%%">Hammerstein-Wiener model <b>%s</b>:<br>',Name);

% input and output names:
[ny,nu] = size(nlsys);

if nu>1
  txt{end+1,1} = '<b>Input names:</b> ';
else
  txt{end+1,1} = '<b>Input name:</b> ';
end

uname = pvget(nlsys, 'InputName');
txtu = '';
for k = 1:nu
  txtu = [txtu sprintf('%s, ', uname{k})];
end
txt{end+1,1} =  sprintf('%s<br>', txtu(1:end-2));

if ny>1
  txt{end+1,1} = '<b>Output names:</b> ';
else
  txt{end+1,1} = '<b>Output name:</b> ';
end

yname = pvget(nlsys, 'OutputName');
txty = '';
for k = 1:ny
  txty = [txty sprintf('%s, ', yname{k})];
end
txt{end+1,1} =  sprintf('%s<br>', txty(1:end-2));

% Orders
txt{end+1,1} = sprintf('<b>Orders:</b><br>');
txt{end+1,1} = sprintf('&nbsp;&nbsp;nb = %s<br>',mat2str(get(nlsys,'nb')));
txt{end+1,1} = sprintf('&nbsp;&nbsp;nf = %s<br>',mat2str(get(nlsys,'nf')));
txt{end+1,1} = sprintf('&nbsp;&nbsp;nk = %s<br>',mat2str(get(nlsys,'nk')));

% Input nonlinearity
nl = pvget(nlsys,'InputNonlinearity');
if nu>1
    txt{end+1,1} = sprintf('<b>Input nonlinearity estimators:</b><br>');
    for k = 1:nu
        txt{end+1,1} = sprintf('&nbsp;&nbsp;For input %d: %s.<br>',k,getInfoString(nl(k)));
    end
else
    txt{end+1,1} = sprintf('<b>Input nonlinearity estimator:</b> %s.<br>',getInfoString(nl));
end

% Output Nonlinearity
nl = pvget(nlsys,'OutputNonlinearity');
if ny>1
    txt{end+1,1} = sprintf('<b>Output nonlinearity estimators:</b><br>');
    for k = 1:ny
        txt{end+1,1} = sprintf('&nbsp;&nbsp;For output %d: %s.<br>',k,getInfoString(nl(k)));
    end
else
    txt{end+1,1} = sprintf('<b>Output nonlinearity estimator:</b> %s.<br>',getInfoString(nl));
end

%txt{end+1,1} =  newline; 

txt{end+1,1} =  sprintf('For more information, right-click on the model icon named "%s" in the model board.</body>',Name);

    
    
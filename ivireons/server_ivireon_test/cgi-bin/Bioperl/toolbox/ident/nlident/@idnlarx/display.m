function txt = display(sys)
%DISPLAY  display for IDNLARX objects

% Copyright 2005-2007 The MathWorks, Inc.
% $Revision: 1.1.8.5 $ $Date: 2007/12/14 14:47:10 $

% Author(s): Qinghua Zhang

[ny, nu] = size(sys);

txt = sprintf('IDNLARX model with %d output%s and %d input%s\n', ny, wend(ny), nu, wend(nu));

% I/O names
if nu>1
  txt = [txt, 'Input names: '];
else
  txt = [txt, 'Input name: '];
end
uname = pvget(sys, 'InputName');
for k=1:nu
  txt = [txt sprintf('%s, ', uname{k})];
end
txt =  sprintf('%s\n', txt(1:end-2));
if ny>1
  txt = [txt, 'Output names: '];
else
  txt = [txt, 'Output name: '];
end
yname = pvget(sys, 'OutputName');
for k=1:ny
  txt = [txt sprintf('%s, ', yname{k})];
end
txt =  sprintf('%s\n', txt(1:end-2));


% Orders
if nu==1 && ny==1
  txt =  [txt sprintf('Standard regressors corresponding to the orders\n')];
  txt =  [txt sprintf('  na = %d, nb = %d, nk = %d\n', sys.na, sys.nb, sys.nk)];
else
  txt =  [txt sprintf('Standard regressors corresponding to the orders:\n')];
  na = sys.na;
  nb = sys.nb;
  nk = sys.nk;
  
  tna = 'na = [';
  tnb = 'nb = [';
  tnk = 'nk = [';
  for ky=1:ny
    tna = [tna, sprintf('%d ', na(ky,:))];
    tna = [tna(1:end-1), '; ']; 
    
    tnb = [tnb, sprintf('%d ', nb(ky,:))];
    tnb = [tnb(1:end-1), '; ']; 
    
    tnk = [tnk, sprintf('%d ', nk(ky,:))];
    tnk = [tnk(1:end-1), '; '];   
  end
  tna = [tna(1:end-2), ']'];
  tnb = [tnb(1:end-2), ']'];
  tnk = [tnk(1:end-2), ']'] ;
  
  if isempty(nb)
    tnb = 'nb = []';
  end
  if isempty(nk)
    tnk = 'nk = []';
  end
  txt =  [txt, sprintf('  %s\n  %s\n  %s\n', tna, tnb,tnk)];
end

% Call subfunctions
if ny==1
  txt = [txt soDisplay(sys)];
elseif ny>1
  txt = [txt moDisplay(sys, ny, nu)];
end

estinfo = sys.EstimationInfo;
if ~isempty(estinfo.LossFcn)
  txt = [txt sprintf('Loss function: %s\n', num2str(estinfo.LossFcn))];
end
txt = [txt sprintf('Sampling interval:  %s\n',  num2str(pvget(sys, 'Ts')))];
txt = [txt estinfo.Status];

if nargout==0
  disp(txt)
end

%====================================
function txt = soDisplay(sys)
txt = '';

% Custom regressors
cregind = nlregstr2ind(sys, 'custom');  
if isempty(cregind)
  txt =  [txt sprintf('No custom regressor\n')];
else
  nr = numel(cregind);
  txt =  [txt sprintf('Custom regressor%s:\n',wend(nr))];
  if nr==1
    txt = txt(1:end-1);
  end
  
  allregstr = getreg(sys);
  cregstr = allregstr(cregind);
  for k=1:nr
    txt =  [txt sprintf('  %s\n', cregstr{k})];
  end
end

% Nonlinear regressors
regs = getreg(sys, 'nonlinear');
txt =  [txt sprintf('Nonlinear regressor%s:\n',wend(length(regs)))];
if isempty(regs)
  txt = [txt, sprintf('  none\n')];
else
  for kr=1:numel(regs)
    txt = [txt, sprintf('  %s\n',regs{kr})];
  end
end

% Nonlinearity
nlobj = sys.Nonlinearity;

if isa(nlobj, 'linear')
  txt = [txt, sprintf('Model output is linear in regressors.\n')];
else
  txt = [txt, sprintf('Nonlinearity estimator: %s', class(nlobj))];
  if ~isunitless(nlobj)
    numofu = nlobj.NumberOfUnits;
    if isnumeric(numofu) && ~isempty(numofu)
      txt = [txt, sprintf(' with %d unit%s', numofu,wend(numofu))];
    end
    
  elseif isa(nlobj, 'poly1d')
    txt = [txt, sprintf(' of degree %d', nlobj.Degree)];
    
  end
  txt = [txt, sprintf('\n')];
end

%------------------------------------
function txt = moDisplay(sys, ny, nu)
txt = '';

% Custom regressors
cregind = nlregstr2ind(sys, 'custom');  

if all(cellfun(@isempty,cregind))
  txt =  [txt sprintf('No custom regressor\n')];
else
  allregstr = getreg(sys);
  txt =  [txt sprintf('Custom regressors:\n')];
  for ky=1:ny
    txt = [txt, sprintf('  For output %d:', ky)];
    if isempty(cregind{ky})
      txt = [txt, sprintf(' none\n')];
    else
      cregindky = cregind{ky};
      allregstrky = allregstr{ky};
      for kr=1:numel(cregindky)
        if any(cellfun(@numel, cregind)>1)
          txt = [txt, sprintf('\n    ')];
        else
          txt = [txt, sprintf(' ')];
        end
        txt = [txt, sprintf('%s', allregstrky{cregindky(kr)})];
      end
      txt = [txt, sprintf('\n')];
    end
  end
end

% Nonlinear regressors
regs = getreg(sys, 'nonlinear');
txt =  [txt sprintf('Nonlinear regressors:\n')];
for ky=1:ny
  txt = [txt, sprintf('  For output %d:\n', ky)];
  if isempty(regs{ky})
    txt = [txt, sprintf('    none\n')];
  else
    for kr=1:numel(regs{ky})
      txt = [txt, sprintf('    %s\n',regs{ky}{kr})];
    end
  end
end

% Nonlinearity
nlobj = sys.Nonlinearity;

if isall(nlobj, 'linear')
  txt = [txt, sprintf('Model outputs are linear in their regressors\n')];
else
  txt = [txt, sprintf('Nonlinearity estimators:\n')];
  for ky=1:ny
    txt = [txt, sprintf('  For output %d: %s', ky, class(nlobj(ky)))];
    if ~isunitless(nlobj(ky)) && isnumeric(nlobj(ky).NumberOfUnits)
      nunits = nlobj(ky).NumberOfUnits;
      txt = [txt, sprintf(' with %d unit%s\n', nunits, wend(nunits))];
      
    elseif isa(nlobj(ky), 'poly1d')
      txt = [txt, sprintf(' of degree %d\n', nlobj(ky).Degree)];
      
    else
      txt = [txt, sprintf('\n')];
    end
  end
end

%------------------
function c = wend(num)
% Word end
if num>1
  c = 's';
else
  c = '';
end
% FILE END
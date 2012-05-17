function txt = display(sys)
%DISPLAY  display for IDNLHW objects

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2007/06/07 14:44:10 $

% Author(s): Qinghua Zhang

[ny, nu] = size(sys);

txt = sprintf('IDNLHW model with %d output%s and %d input%s\n', ny, wend(ny), nu, wend(nu));

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
nb = pvget(sys, 'nb');
nf = pvget(sys, 'nf');
nk = pvget(sys, 'nk');

if nu==1 && ny==1
  txt =  [txt sprintf('Linear transfer function corresponding to the orders ')];
  txt =  [txt sprintf('nb = %d, nf = %d, nk = %d\n', nb, nf, nk)];
else
  txt =  [txt sprintf('Linear transfer function matrix corresponding to the orders:\n')];
  tnb = 'nb = [';
  tnf = 'nf = [';
  tnk = 'nk = [';
  for ky=1:ny
    tnb = [tnb, sprintf('%d ', nb(ky,:))];
    tnb = [tnb(1:end-1), '; ']; 
    
    tnf = [tnf, sprintf('%d ', nf(ky,:))];
    tnf = [tnf(1:end-1), '; ']; 
    
    tnk = [tnk, sprintf('%d ', nk(ky,:))];
    tnk = [tnk(1:end-1), '; '];   
  end
  tnb = [tnb(1:end-2), ']'];
  tnf = [tnf(1:end-2), ']'];
  tnk = [tnk(1:end-2), ']'] ;
  txt =  [txt, sprintf('  %s\n  %s\n  %s\n', tnb, tnf,tnk)];
end

% Nonlinearities
clear ky

unlobj = sys.InputNonlinearity;
ynlobj = sys.OutputNonlinearity;

if nu==1
  txt = [txt, 'Input nonlinearity estimator: '];
  if isa(unlobj,'unitgain')
    txt = [txt, sprintf('absent\n')];
  else
    txt = [txt, sprintf('%s', class(unlobj))];
    if ~isunitless(unlobj)
      numofu = unlobj.NumberOfUnits;
      if  isnonnegintscalar(numofu)
        txt = [txt, sprintf(' with %d unit%s', numofu,wend(numofu))];
      end
      
    elseif isa(unlobj, 'poly1d')
      txt = [txt, sprintf(' of degree %d', unlobj.Degree)];
      
    end
    txt = [txt, sprintf('\n')];
  end
else
  txt = [txt, sprintf('Input nonlinearity estimators:\n')];
  for k=1:nu
    txt = [txt, sprintf('  For input %d: ', k)];
    if isa(unlobj(k),'unitgain')
      txt = [txt, sprintf('absent\n')];
    else
      txt = [txt, sprintf('%s', class(unlobj(k)))];
      
      if ~isunitless(unlobj(k)) && isnonnegintscalar(unlobj(k).NumberOfUnits)
        nunits = unlobj(k).NumberOfUnits;
        txt = [txt, sprintf(' with %d unit%s\n', nunits, wend(nunits))];
        
      elseif isa(unlobj(k), 'poly1d')
        txt = [txt, sprintf(' of degree %d\n', unlobj(k).Degree)];

      else
        txt = [txt, sprintf('\n')];
      end
    end
  end
end

if ny==1
  txt = [txt, 'Output nonlinearity estimator: '];
  if isa(ynlobj,'unitgain')
    txt = [txt, sprintf('absent\n')];
  else
    txt = [txt, sprintf('%s', class(ynlobj))];
    if ~isunitless(ynlobj)
      numofu = ynlobj.NumberOfUnits;
      if isnonnegintscalar(numofu) 
        txt = [txt, sprintf(' with %d unit%s', numofu,wend(numofu))];
      end

    elseif isa(ynlobj, 'poly1d')
      txt = [txt, sprintf(' of degree %d', ynlobj.Degree)];

    end
    txt = [txt, sprintf('\n')];
  end
else
  txt = [txt, sprintf('Output nonlinearity estimators:\n')];
  for k=1:ny
    txt = [txt, sprintf('  For output %d: ', k)];
    if isa(ynlobj(k),'unitgain')
      txt = [txt, sprintf('absent\n')];
    else
      txt = [txt, sprintf('%s', class(ynlobj(k)))];
      
      if ~isunitless(ynlobj(k)) && isnonnegintscalar(ynlobj(k).NumberOfUnits)
        nunits = ynlobj(k).NumberOfUnits;
        txt = [txt, sprintf(' with %d unit%s\n', nunits, wend(nunits))];
        
      elseif isa(ynlobj(k), 'poly1d')
        txt = [txt, sprintf(' of degree %d\n', ynlobj(k).Degree)];
 
      else
        txt = [txt, sprintf('\n')];
      end
    end
  end  
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
function c = wend(num)
% Word end
if num>1
  c = 's';
else
  c = '';
end
% FILE END
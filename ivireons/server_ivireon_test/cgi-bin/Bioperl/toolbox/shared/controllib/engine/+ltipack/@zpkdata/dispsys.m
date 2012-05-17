function dispsys(D,Inames,Onames,LineMax,LeftMargin,ch,dispType,Variable)
%DISPLAY  Pretty-print for zero/pole/gain models.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:28 $
Zero = D.z;
Pole = D.p;
Gain = D.k;
Ts = D.Ts;
[p,m] = size(Gain);
Td = getIODelay(D,'total');  % total I/O delay

Istr = '';  Ostr = '';  Ending = ':';
LeftMargin = reshape(LeftMargin,[1 length(LeftMargin)]);
NoInames = isequal('','',Inames{:});
NoOnames = isequal('','',Onames{:});
relprec = 0.0005;  % 1+relprec displays as 1

if m==1 && NoInames,
   % Single input and no name
   if p>1 || ~NoOnames,
      Istr = sprintf(' %s',xlate('from input'));
   end
else
   for i=1:m, 
      if isempty(Inames{i}),
         Inames{i} = int2str(i); 
      else
         Inames{i} = ['"' Inames{i} '"'];
      end
   end
   Istr = sprintf(' %s ',xlate('from input'));
end

if p>1,
   for i=1:p, 
      if isempty(Onames{i}), Onames{i} = ['#' int2str(i)]; end
   end
   Ostr = sprintf(' %s...',xlate('to output'));
   Ending = '';
elseif ~NoOnames,
   % Single output with name
   Ostr = sprintf(' %s ',xlate('to output'));
   Onames{1} = ['"' Onames{1} '"'];
else
   % Single unnamed output, but several inputs
   Onames = {''};
   if ~isempty(Istr),  
      Ostr = sprintf(' %s',xlate('to output'));
   end
end


% REVISIT: Possibly make a matrix gain display as a simple matrix
i = 1; j = 1;
while j<=m,
   disp(' ');
   
   % Display header for each new input
   if i==1,
      str = [xlate('Zero/pole/gain') Istr Inames{j} Ostr];
      if p==1,  
         str = [str Onames{1}];   %#ok<AGROW>
      end
      disp([LeftMargin str Ending])
   end
   
   % Set output label
   if p==1,
      OutputName = LeftMargin;
   else
      OutputName = sprintf('%s %s:  ',LeftMargin,Onames{i});
   end
   
   kij = Gain(i,j);
   if kij~=0,
      
      %Note pole2str returns a gainScale to account for changes in the gain
      %scale factor that occur when the DisplayFormat is not in 'roots' (roots) form
      [s1 gainScaleZ] = pole2str(Zero{i,j},ch,dispType, Ts);
      [s2 gainScaleP] = pole2str(Pole{i,j},ch,dispType, Ts);
      %No need to worry about gainScaleP==0, by design its >eps*1e4   
      kij = kij*gainScaleZ/gainScaleP;
      GainStr = num2str(kij);
      if ~isreal(kij)
         GainStr = sprintf('(%s)',GainStr);
      end
      
      if strcmp(ch,'z^-1')
         % Add appropriate power of 1/z
         reldeg = length(Zero{i,j})-length(Pole{i,j});
         absr = abs(reldeg);
         if absr==1,
            str = [ch ' '];
         elseif absr~=0
            str = ['z^-' int2str(absr) ' '];
         end
         if reldeg<0,
            s1 = [str s1]; %#ok<AGROW>
         elseif reldeg>0,
            s2 = [str s2]; %#ok<AGROW>
         end
      end
      
      % Add delay time
      if Td(i,j),
         if Ts==0,
            OutputName = [OutputName , sprintf('exp(-%.2g*%s) * ',Td(i,j),ch)]; %#ok<AGROW>
         else 
            % Variables z,w,z^-1 all displayed as z^-tau
            OutputName = [OutputName , ...
               sprintf('%s^(-%d) * ',strrep(ch(1),'w',Variable),Td(i,j))]; %#ok<AGROW>
         end
      end
      loutname = length(OutputName);
      
      % Handle long lines and case |kij|=1
      maxchars = max(floor(LineMax/2),LineMax-loutname);
      if isempty(s1)
         s1 = GainStr;
      elseif abs(kij-1)<relprec,
         s1 = sformat(s1,'(',maxchars); 
      elseif abs(kij+1)<relprec,
         s1 = sformat(['- ' s1],'(',maxchars); 
      else
         s1 = sformat([GainStr ' ' s1],'(',maxchars); 
      end
      s2 = sformat(s2,'(',maxchars);  
      
      [m1,l1] = size(s1);
      b = ' ';
      if isempty(s2);
         disp([[OutputName ; b(ones(m1-1,loutname))],s1])
      else
         [m2,l2] = size(s2);
         if m1>1 || m2>1, disp(' '); end
         sep = '-';
         extra = fix((l2-l1)/2);
         disp([b(ones(m1,loutname+max(0,extra))) s1]);
         disp([OutputName sep(ones(1,max(l1,l2)))]);
         disp([b(ones(m2,loutname+max(0,-extra))) s2]);
      end
   else
      disp([OutputName '0']);
   end
   
   i = i+1;  
   if i>p,  
      i = 1;  j = j+1; 
   end
end

disp(' ');

function [s, gainScale] = pole2str(p,ch,varargin)
% S = POLE2STR(P,'s') or S=POLE2STR(P,'z') returns a string S
% consisting of the poles in the vector P subtracted from the
% transform variable 's' or 'z' and then multiplied out.
%
% Example: POLE2STR([1 0 2],'s') returns the string  's^2 + 2'. 
s = '';
gainScale = 1;

polyType = 'roots';
if nargin>=3 && ~isempty(varargin{1})
   polyType = varargin{1};
   if nargin>3 && ~isempty(varargin{2})
      Ts = abs(varargin{2}); % use abs to convert -1 to 1
   end
end
if isempty(p),
   return
else
   p = mroots(p,'roots',1e-6);  % Denoise multiple roots for nicer display
end

% Formats for num to char conversion
[formatString, dispTol, relTol, absTol] = deltaParameters; %#ok<ASGLU>

if strcmp(ch,'z^-1'),
   ch = 'a';  % use single character placeholder
end

% Put real roots first
[trash,ind] = sort(abs(imag(p))); %#ok<ASGLU>
p = -p(ind);

% Recognize cts time integrators and discrete time delays
p(abs(p) < absTol) = 0;
% Recognize dist time integrators
if ~any(strcmp(ch,{'s','p'})) %not continuous time system
   p(abs(p-1) < absTol) = 1;
end


while ~isempty(p),
   p1 = p(1);
   cmplxpair = false;
   if isreal(p1)
      ind = find(abs(p-p1) <= relTol*abs(p1));   
      pow = length(ind);      
   else
      sgn = sign(imag(p1));
      ind = find(sgn*imag(p)>0 & abs(p-p1)<absTol);
      indcjg = find(sgn*imag(p)<0 & abs(p-conj(p1)) < absTol);
      pow = length(ind);
      if abs(imag(p1)) < relTol * abs(p1),
         % Display as real
         p1 = real(p1);
         ind = [ind indcjg]; %#ok<AGROW>
         pow = pow + length(indcjg);
      elseif length(ind)>=1 && length(indcjg)>=1    
         pow = min(length(ind),length(indcjg));
         cmplxpair = true;
         ind = [ind(1:pow) indcjg(1:pow)];
      end
   end
   p(ind) = [];
   switch [ch polyType(1)]
      case 'ar'  % variable z^-1 (only compatible with 'roots')
         [tmp,thisFactorGainScale] = qsRoots2str(p1, ch, cmplxpair);
      case {'sr','pr','zr','qr'}
         [tmp,thisFactorGainScale] = rsRoots2str(p1, ch, cmplxpair);
      case {'wt','pt','st'} %variable s,p,w
         [tmp,thisFactorGainScale] = tRoots2str(p1, ch, Ts, cmplxpair);
      case {'wf','sf','pf'}
         [tmp,thisFactorGainScale] = fRoots2str(p1, ch, Ts, cmplxpair);
   end    
   
   % Raise tmp to right power
   if pow~=1 && ~isempty(tmp),
      tmp = [tmp '^' int2str(pow)]; %#ok<AGROW>
   end
   
   % Add to s and remove elements from p
   if isempty(s),
      s = tmp;
   elseif p1==0,
      s = [tmp  ' ' s]; %#ok<AGROW>
   else
      s = [s  ' ' tmp]; %#ok<AGROW>
   end
   gainScale = gainScale*thisFactorGainScale^pow;
end

% Take care of ch='z^-1'
if strcmp(ch,'a'),
   s = strrep(s,'a^','z^-');
   s = strrep(s,'a','z^-1');
end

% end pole2str


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signx,valx] = xprint(x,form)
%NICEDISP  Returns sign and value of real or complex number coefficient x 
%          as strings

[formatString, dispTol] = deltaParameters; %#ok<ASGLU>

rx = real(x);
ix = imag(x);
if ix==0 || rx==0
   % Real or pure imaginary
   v = rx+ix;
   if v>=0
      signx = '+';
   else
      signx = '-';
   end
   if abs(abs(v)-1) > dispTol 
      valx = sprintf(form,abs(v));
      if rx==0
         valx = [valx 'i'];
      end
   elseif ix==0
      valx = '';
   else
      valx = 'i';
   end
else
   % General complex
   if rx>0
      signx = '+';
      valx = ['(' num2str(x,form) ')'];
   else
      signx = '-';
      valx = ['(' num2str(-x,form) ')'];
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [signx,valx] = rprint(x,form)
%NICEDISP  Returns sign and reciprocal value of a real or complex number x 
%          as strings

[formatString, dispTol] = deltaParameters; %#ok<ASGLU>

rx = real(x);
ix = imag(x);
if ix==0 || rx==0
   % Real or pure imaginary
   if rx+ix>=0
      signx = '+';
   else
      signx = '-';
   end
   if ix==0
      if abs(abs(rx)-1) > dispTol 
         valx = ['/' sprintf(form,abs(rx))];
      else
         valx = '';
      end
   else
      if abs(abs(ix)-1) > dispTol 
         valx = ['/' sprintf(form,abs(ix)) 'i'];
      else
         valx = '/i';
      end
   end
else
   % General complex
   if rx>0
      signx = '+';
      valx = ['/(' num2str(x,form) ')'];
   else
      signx = '-';
      valx = ['/(' num2str(-x,form) ')'];
   end
end   
      

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp, gainScale] = qsRoots2str(p1, ch , cmplxpair)
% DisplayFormat = 'roots', Variable = q or z^-1
gainScale = 1;
[formatString, dispTol, relTol, absTol] = deltaParameters; %#ok<ASGLU>

if p1==0
   tmp = '';
   return
end
if isreal(p1),    % string of the form (1 +/- p * ch)   
   [sp1,val1] = xprint(p1,formatString);
   tmp = ['(1' sp1 val1 ch ')']; 
elseif cmplxpair,      % string (1+2*real(p1)*ch+abs(p1)^2*ch^2)
   rp1 = 2*real(p1);
   tmp = '(1';
   
   if abs(rp1)>absTol
       [srp1,val1] = xprint(rp1,formatString);
       if abs(abs(rp1)-1) > dispTol
           tmp = [tmp ' ' srp1 ' ' val1 ch ]; %' '
       else
           tmp = [tmp ' ' srp1 ' ' ch];
       end
   end
    
   if abs(abs(p1*p1')-1) < dispTol
      tmp = [tmp ' + ' ch '^2)'];
   else
      tmp = [tmp ' + ' sprintf(formatString,p1*p1') ch '^2)'];
   end
else
   [sgn1,val1] = xprint(p1,formatString);
   tmp = ['(1 ' sgn1 ' ' val1 ch ')'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tmp,thisFactorGainScale] = fRoots2str(p1, ch, Ts,cmplxpair)  
% DisplayFormat = 'frequency', Variable = s,p,w
% Factor is displayed as 1+s/f or 1+a*(s/f)+(s/f)^2
[formatString, dispTol, relTol, absTol] = deltaParameters; %#ok<ASGLU>

if Ts==0 && p1==0
   % Special handling of s=0 (f=0)
   thisFactorGainScale = 1;
   tmp = ch;
elseif Ts~=0 && abs(p1+1)/Ts<=absTol 
   % Special handling of z=1 (f=0)
   if cmplxpair % w^2
      thisFactorGainScale = Ts^2;
      tmp = [ch '^2'];
   else  % w
      thisFactorGainScale = Ts;
      tmp = ch;
   end
else
   if cmplxpair
      % Compute a,f parameters
      if Ts==0  % s,p
         f = abs(p1);
         a = 2*real(p1)/f;
         thisFactorGainScale = p1*conj(p1);  
      else  % w
         alpha = 2*real(p1);
         beta = abs(p1)^2;
         phi = alpha+beta+1; %Note, phi = |1+p1|^2
         a = (alpha+2)/sqrt(phi); %=2(re(p1)+1)/|p1+1|
         f = sqrt(phi)/Ts; %=|1+p1|/Ts > absTol
         thisFactorGainScale = phi;
      end
      
      % var/f term
      [srp2,val2] = rprint(f,formatString); %#ok<ASGLU>
      varf = [ch val2];
      
      % Constant term
      tmp = '(1';
      % Linear term a(s/f)
      [srp1,val1] = xprint(a,formatString);
      if abs(a) > absTol
         if abs(f-1) > dispTol
            tmp = [tmp ' ' srp1 ' ' val1 '(' varf ')'];
         else
            tmp = [tmp ' ' srp1 ' ' val1  varf];
         end
      end
      % Quadratic term
      if abs(f-1) > dispTol 
         tmp = [tmp ' + (' varf ')^2)'];
      else
         tmp = [tmp ' + ' varf '^2)'];
      end
   else
      if Ts==0
         thisFactorGainScale = p1;
         [sgn,val] = rprint(p1,formatString);
      else
         thisFactorGainScale = 1+p1;
         [sgn, val] = rprint((1+p1)/Ts,formatString);
      end
      tmp = ['(1' sgn ch  val ')']; % (1 + s/k)
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp,thisFactorGainScale] = tRoots2str(p1, ch, Ts, cmplxpair)  
% DisplayFormat = 'frequency', Variable = s,p,w
% Factor is displayed as 1+ts or 1+a*(ts)+(ts)^2
[formatString, dispTol, relTol, absTol] = deltaParameters; %#ok<ASGLU>

if Ts==0 && p1==0
   % Special handling of s=0 (f=0)
   thisFactorGainScale = 1;
   tmp = ch;
elseif Ts~=0 && abs(p1+1)/Ts<=absTol 
   % Special handling of z=1 (f=0)
   if cmplxpair % w^2
      thisFactorGainScale = Ts^2;
      tmp = [ch '^2'];
   else  % w
      thisFactorGainScale = Ts;
      tmp = ch;
   end
else
   if cmplxpair
      % Compute a,t parameters
      if Ts==0  % s,p
         t = 1/abs(p1);
         a = 2*real(p1)*t;
         thisFactorGainScale = p1*conj(p1);  
      else  % w
         alpha = 2*real(p1);
         beta = abs(p1)^2;
         phi = alpha+beta+1; %Note, phi = |1+p1|^2
         a = (alpha+2)/sqrt(phi); %=2(re(p1)+1)/|p1+1|
         t = Ts/sqrt(phi); %=|1+p1|/Ts > absTol
         thisFactorGainScale = phi;
      end
      
      % t[var] term
      [srp2,val2] = xprint(t,formatString); %#ok<ASGLU>
      tvar = [val2 ch];
      
      % Constant term
      tmp = '(1';
      % Linear term a(ts)
      [srp1,val1] = xprint(a,formatString);
      if abs(a) > absTol
         if abs(t-1) > dispTol
            tmp = [tmp ' ' srp1 ' ' val1 '(' tvar ')'];
         else
            tmp = [tmp ' ' srp1 ' ' val1  tvar];
         end
      end
      % Quadratic term
      if abs(t-1) > dispTol 
         tmp = [tmp ' + (' tvar ')^2)'];
      else
         tmp = [tmp ' + ' tvar '^2)'];
      end
   else
      if Ts==0
         thisFactorGainScale = p1;
         [sgn,val] = xprint(1/p1,formatString);
      else
         thisFactorGainScale = 1+p1;
         [sgn,val] = xprint(Ts/(1+p1),formatString);
      end
      tmp = ['(1' sgn val ch ')']; % (1 + ts)
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [tmp, gainScale] = rsRoots2str(p1, ch, cmplxpair)  
%case {'sr','pr','zr'}

[formatString, dispTol, relTol, absTol] = deltaParameters; %#ok<ASGLU>

gainScale = 1;

if p1==0
   tmp = ch;
elseif cmplxpair               
   % string (ch^2+2*real(p1)*ch+abs(p1)^2)
   rp1 = 2*real(p1);
   tmp = ['(' ch '^2'];
   
   %middle term
   if abs(rp1)>absTol
       [srp1,val1] = xprint(rp1,formatString);
       if abs(abs(rp1)-1) > dispTol
           tmp = [tmp ' ' srp1 ' ' val1 ch ]; %' '
       else
           tmp = [tmp ' ' srp1 ' ' ch];
       end
   end
   
   %last term
   tmp = [tmp ' + ' sprintf(formatString,p1*p1') ')'];
else
   % string of the form (ch +/- p) 
   [sgn,val] = xprint(p1,formatString);
   if isempty(val),
      val = '1';
   end
   tmp = ['(' ch  sgn val  ')'];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [formatString, displayPrecision, relativeTol, integratorTol] = deltaParameters

formatString = '%.4g';
displayPrecision = 0.0005;   % 1+displayPrecision displays as nothing
relativeTol = eps^0.4;      % tolerance for relaitve comparisons
integratorTol = 1000*eps;    % tolerance for detecting integrators


function sout = sformat(s,sep,linemax)
% Splits a long string S into several lines of maximum 
% length LINEMAX.  The line break occur after the 
% delimiters defined in SEP
sout='';
s = strrep(s,'e+','e');
ls = length(s);
if ls<=linemax+10,  sout = s;  return,  end

while ls>linemax+10,
  if any(s(linemax+1)==sep),
    endline = '';  rmdr = s(linemax+1:ls);
  else
    % Find first occurrence of SEP delimiters
    [endline,rmdr] = strtok(s(linemax+1:ls),sep);
    if any(endline(length(endline))=='^e'), 
       % Handle e-** and ^-** strings
       [end2,rmdr] = strtok(rmdr(2:end),sep);
       endline = [endline , '-' , end2]; %#ok<AGROW>
    end
  end
  % Add new line to SOUT
  sout = strvcat(sout,[s(1:linemax) , endline],' '); %#ok<VCAT>
  s = [blanks(8) , rmdr];
  ls = length(s);
end

if any(s~=' '),
    sout = strvcat(sout,[blanks(linemax+10-ls) s],...
                                    blanks(~isempty(sout))); %#ok<VCAT>
end

function dispsys(D,Inames,Onames,LineMax,LeftMargin,ch)
%DISPLAY  Pretty-print for transfer functions.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:33 $
Num = D.num;
Den = D.den;
Ts = D.Ts;
[p,m] = size(Num);
% Total I/O delay
Td = getIODelay(D,'total');

Istr = '';  Ostr = '';  Ending = ':';
LeftMargin = reshape(LeftMargin,[1 length(LeftMargin)]);
NoInames = all(cellfun(@isempty,Inames));
NoOnames = all(cellfun(@isempty,Onames));

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
   num = Num{i,j};
   den = Den{i,j};
   % Make DEN(1) positive
   ind = find(den);  ind = ind(1);
   if length(num)==1 && length(den)==1
       num = num/den;   den = 1;
   elseif isreal(den(ind)) && den(ind)<0,  
      num = -num;  den = -den;  
   end
   
   disp(' ');
   % Display header for each new input
   if i==1,
      str = [xlate('Transfer function') Istr Inames{j} Ostr];
      if p==1,  str = [str Onames{1}];  end
      disp([LeftMargin str Ending])
   end
   
   % Set output label
   if p==1,
      OutputName = LeftMargin;
   else
      OutputName = sprintf('%s %s:  ',LeftMargin,Onames{i});
   end
   
   % Add delay time
   if any(num) && Td(i,j)>0,
      if Ts==0,
         OutputName = [OutputName , sprintf('exp(-%.3g*%s) * ',Td(i,j),ch)]; %#ok<AGROW>
      else 
         % Variables z,w,z^-1 all displayed as z^-tau
         OutputName = [OutputName , ...
            sprintf('%s^(-%d) * ',strrep(ch(1),'w','z'),Td(i,j))]; %#ok<AGROW>
      end
   end
   loutname = length(OutputName);
   
   % Generate data display
   maxchars = max(floor(LineMax/2),LineMax-loutname);
   s1 = poly2str(num,ch);
   s1 = sformat(s1,'+-',maxchars);  % Handle long lines
   
   if ~strcmp(s1,'0'),
      s2 = poly2str(den,ch);
      s2 = sformat(s2,'+-',maxchars); 
   end
   
   [m1,l1] = size(s1);
   b = ' ';
   if strcmp(s1,'0') || strcmp(s2,'1'),
      if ~strcmp(s1,'0') && Td(i,j)
         s1 = sprintf('(%s)',s1);
      end
      disp([[OutputName ; b(ones(m1-1,loutname))],s1])
   else
      % Generate display
      [m2,l2] = size(s2);
      if m1>1 || m2>1, disp(' '); end
      sep = '-';
      extra = fix((l2-l1)/2);
      disp([b(ones(m1,loutname+max(0,extra))) s1]);
      disp([OutputName sep(ones(1,max(l1,l2)))]);
      disp([b(ones(m2,loutname+max(0,-extra))) s2]);
   end
   
   i = i+1;  
   if i>p,  
      i = 1;  j = j+1;
   end
end

disp(' ');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = poly2str(p,ch)
%POLY2STR Return polynomial as string.
%       S = POLY2STR(P,ch) where ch is 's', 'z', 'z^-1', or 'q'
%       returns a string S consisting of the polynomial coefficients 
%       in the vector P multiplied by powers of the transform variable 
%       's', 'z', 'z^-1', or 'q'.  Quite similar to old poly2str.
%
%       Example: POLY2STR([1 0 2],'s') returns the string  's^2 + 2'. 

form = '%.4g';
relprec = 0.0005;   % 1+relprec displays as 1


ind = find(p);
if isempty(ind),
   s = '0';
   return
elseif length(p)==1,
   % Quick exit if constant gain
   s = LocalDisplayDouble(p,form);
   return
end

if strcmp(ch,'z^-1'),
   ch = 'a';  % remap to single character for convenience
end

if strcmp(ch,'a'),
   % Ascending powers
   pow = 0:length(p)-1;
else
   % Descending power
   pow = length(p)-1:-1:0;
end
pow = pow(ind);
s = '';
% For each non-zero element of the polynomial ...
for i=1:length(ind),
   pi = pow(i);
   el = p(ind(i));
   % ... if it's not the first non-zero element of the polynomial ...
   if real(el)<0
      el = -el;
      % Add a minus sign if the element is negative
      if i==1
         s = [s '-'];
      else
         s = [s ' - '];
      end
   elseif i~=1,
      % Add a plus sign if the element has positive real part
      s = [s ' + '];
   end
   % If the element isn't 1 or power is zero
   if abs(el-1)>relprec || (pi==0),
      % Add element value
      s = [s LocalDisplayDouble(el,form) blanks(pi~=0)];
   end
   % Note: in following clause, never print "ch" to 0th power
   if pi==1,
      % Positive powers don't need exponents if to the 1st power
      s = [s ch];
   elseif pi~=0,
      % As long as the power is non-zero add "ch" raised to power
      s = [s ch '^' int2str(pi)];
   end
end

% Take care of ch='z^-1'
if strcmp(ch,'a'),
   s = strrep(s,'a^','z^-');
   s = strrep(s,'a','z^-1');
end

% end poly2str


function s = LocalDisplayDouble(el,form)
% Display double number with positive real part
if ~isreal(el)
   if imag(el)>0
      form = sprintf('(%s+%si)',form,form);
   else
      form = sprintf('(%s-%si)',form,form);
   end
   s = sprintf(form,real(el),abs(imag(el)));
elseif el==round(el) && el < 1e6,
   s = int2str(el);
else
   s = sprintf(form,el);
end


function sout = sformat(s,sep,linemax)
% SFORMAT    Splits a long string S into several lines of maximum
%            length LINEMAX.  The line break occur after the
%            delimiters defined in SEP
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
         endline = [endline , '-' , end2];
      end
   end
   % Add new line to SOUT
   sout = strvcat(sout,[s(1:linemax) , endline],' ');
   s = [blanks(8) , rmdr];
   ls = length(s);
end

if any(s~=' '),
   sout = strvcat(sout,[blanks(linemax+10-ls) s],blanks(~isempty(sout)));
end



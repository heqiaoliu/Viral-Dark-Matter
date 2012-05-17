function changed = dfsetconflev(dffig,clev)
%DFSETCONFLEV Set confidence level for curve fitting

%   $Revision: 1.1.8.2 $  $Date: 2010/04/24 18:31:46 $
%   Copyright 2003-2004 The MathWorks, Inc.

% Get new value
oldlev = dfgetset('conflev');
if isempty(clev)
   ctxt = inputdlg({'Confidence level (in percent):'},...
                   'Set Confidence Level',1,{num2str(100*oldlev)});
   if isempty(ctxt)
      clev = oldlev;
   else
      ctxt = ctxt{1};
      clev = str2double(ctxt);
      if ~isfinite(clev) || ~isreal(clev) || clev<=0 || clev>=100
         errordlg(sprintf(...
             ['Bad confidence level "%s".\n' ...
              'Must be a percentage larger than 0 and smaller than 100.\n' ...
              'Keeping old value %g.'],...
             ctxt,100*oldlev),...
             'Error','modal');
         clev = oldlev;
      else
         clev = clev/100;
      end
   end
end
changed = (oldlev~=clev);
if changed
   dfgetset('conflev',clev);
   
   % Update any existing data sets and fits
   dsdb = getdsdb;
   ds = down(dsdb);
   while(~isempty(ds))
      ds.confLev = clev;
      ds = right(ds);
   end
   fitdb = getfitdb;
   ft = down(fitdb);
   while(~isempty(ft))
      ft.confLev = clev;
      ft = right(ft);
   end
   dfupdateylim;
end

% Check the appropriate menu item
h = [findall(dffig,'Type','uimenu','Tag','conflev90');
     findall(dffig,'Type','uimenu','Tag','conflev95');
     findall(dffig,'Type','uimenu','Tag','conflev99');
     findall(dffig,'Type','uimenu','Tag','conflevOther')];
set(h,'Checked','off');
verysmall = sqrt(eps);
if abs(clev-.90)<verysmall
   set(h(1),'Checked','on');
elseif abs(clev-.95)<verysmall
   set(h(2),'Checked','on');
elseif abs(clev-.99)<verysmall
   set(h(3),'Checked','on');
else
   set(h(4),'Checked','on');
end


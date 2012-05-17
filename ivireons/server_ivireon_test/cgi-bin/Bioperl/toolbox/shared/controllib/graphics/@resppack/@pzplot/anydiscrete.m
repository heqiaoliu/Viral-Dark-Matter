function boo = anydiscrete(this)
%ANYDISCRETE  Returns true if plot contains Z-domain pole/zero data.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:22:48 $
boo = false;
if length(this.Responses)
   for r=find(this.Responses,'Visible','on')'
      VisView = strcmp(get(r.View,'Visible'),'on');
      Ts = get(r.Data(VisView),{'Ts'});
      if length(Ts) & any([Ts{:}]~=0)
         boo = true;
         return
      end
   end
end



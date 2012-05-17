function n = idordch(SS,n,arg,def_order,ny,auxord,nu,Ncap,R,XIDplotw,nk)
% Order selection dialog (used by n4sid, n4sid_f)

% Copyright 2002-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:34:54 $

dS = diag(SS);
if length(dS)<max(n)
   ctrlMsgUtils.error('Ident:estimation:n4sidHighMaxOrderSelect')
end
%n = n(1:min(length(n),length(dS)));
dS = dS(n);
nmax = max(n);
testo = log(dS); 
try
   I = find(testo>(max(testo)+min(testo))/2, 1, 'last');
   ndef = max(min(n),min(nmax,n(I)));
catch
    ctrlMsgUtils.error('Ident:estimation:n4sidCheck9')
end

newfig = [];
if ~def_order
    [~,~,~,xx,yy] = makebars(n,log(dS)');
    mdS = floor(min(log(dS)));
    zer = find(yy==0);
    yy(zer) = mdS*ones(size(zer));
    if ~strcmp(arg,'gui')
        newfig = figure;
        handax = gca;
    else
        handax = get(XIDplotw(10,1),'userdata');handax=handax(3);
        set(handax,'vis','off');axes(handax),cla
        %[nR,nC]=size(R);
        hh=findobj(XIDplotw(10,1),'label',menulabel('&Help'));
        set(hh,'userdata',{[ny,auxord,nu,Ncap],R,nk});
    end
    axes(handax)
    line(xx,yy,'color','y');%%
    ylabel('Log of Singular values');xlabel('Model order')
    title('Model singular values vs order')
    text(0.97,0.95,['Red: Default Choice (',num2str(ndef),')'],'units','norm','fontsize',10,...
        'HorizontalAlignment','right');
    ndefloc = find(n==ndef,1);
    ni = min(nmax,floor(size(xx,1)/5));
    patch(xx(1:ndefloc*5-3),yy(1:ndefloc*5-3),'y');%%
    patch(xx(5*ndefloc-3:5*ndefloc),yy(5*ndefloc-3:5*ndefloc),'r');%%%
    patch(xx(5*ndefloc:ni*5+1),yy(5*ndefloc:ni*5+1),'y');%%
    set(handax,'vis','on')

    if strcmp(arg,'gui')
        set(XIDplotw(10,3),'userdata',[[ndef,n];[dS(ndefloc),dS']]);
        n = [];
        return
    end
    title('Select model order in Command Window.')
    n=-1;
    while ~isscalar(n) || ~isreal(n) || ~isfinite(n) || n<=0 || n>nmax
        n = input('Select model order:(''Return'' gives default) ');
        n = floor(n);
        if isempty(n)
            n = ndef;
            disp(['Order chosen to ',int2str(n)]);
        end
        if n<=0,disp('Order must be a positive integer.'),end
        if n>nmax,disp(['Order must be less than ',int2str(nmax+1),'.']),end
    end
else
    n = ndef;
end  % if def_order

close(newfig)

if isempty(n)
    ctrlMsgUtils.error('Ident:estimation:n4sidfemptyOrderSelect')
end

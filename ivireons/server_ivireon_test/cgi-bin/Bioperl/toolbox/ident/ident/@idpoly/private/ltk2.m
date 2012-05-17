function dec = ltk2(y,u,ecb,c,nc,tstart,na,nb,nk,nobs,ec)
%LTK2  private function

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/10/02 18:49:07 $

npar = na + sum(nb) + nc;
tslut = length(y);

x= [];
for i= 1:na;
    x= [x; y(tslut-i:-1:tstart-i).']; 	% y is reversed in the input
end;
for ku = 1:length(nb)
    for i= nk(ku):nb(ku)+nk(ku)-1;
        x= [x; -u(tslut-i:-1:tstart-i,ku).']; 	% u is reversed in the input
    end;
end
for i= 1:nc;
    x= [x; [zeros(1,i) -ecb(1:nobs-i).']]; 	% ecb is already reversed
end;
decb= vfilter(1,c,x,zeros(npar,nc),[]);
% Step 3 dwc(tstart-1)..dwc(tstart-nc)
dwc= vfilter(c,1,zeros(npar,nc),[],decb(:,nobs-nc+1:nobs));
x= zeros(npar-nc,nc);
for i= 1:nc;
    x= [x; [ecb(nobs-i+1:nobs).' zeros(1,nc-i)]];
end;
dwc= dwc+x;
% Step 4 dec(tstart-nc)..ec(tstart-1)
x= zeros(npar-nc,nc);
for i= 1:nc;
    x= [x; [zeros(1,i) ec(1:nc-i)]];
end;
dec= vfilter(1,c,dwc(:,nc:-1:1)-x,zeros(npar,nc),[]); % dwc is reversed in the input


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y= vfilter(b,a,u,yi,ui)
% y(t)= -a1*y(t-1)- ... -ana*y(t-na)
%       +b0*u(t)+b1*u(t-1)+ ... +bnb*u(t-nb)

% b= b0, b1, ... , bnb
% a= 1, a1, ... , ana
% u; m x n
% y; m x n
% yi; m x na
% ui; m x nb


[m,n]= size(u);
y=zeros(m,n);
nb= length(b)-1;
na= length(a)-1;
ai=-a(length(a):-1:2);bi=b(length(b):-1:2);
[ryi,cyi]=size(yi);[tui,cui]=size(ui);
for j=1:m
    if ~isempty(yi)
        yii=yi(j,cyi:-1:1);
    else
        yii=[];
    end
    if ~isempty(ui)
        uii=ui(j,cui:-1:1);
    else
        uii=[];
    end
    ziy=filter(ai,1,yii);
    ziu=filter(bi,1,uii);
    zi=zeros(1,max(na,nb));
    zi(1:na)=ziy(length(ziy):-1:1);
    zi=zi+[ziu(length(ziu):-1:1),zeros(1,max(na,nb)-nb)];
    y(j,:)=filter(b,a,u(j,:),zi);
end

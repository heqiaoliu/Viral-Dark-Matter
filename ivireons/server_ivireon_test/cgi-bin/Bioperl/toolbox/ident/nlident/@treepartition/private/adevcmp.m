function z=adevcmp(x,ht,nobs,thrp,nv)
% ADEVCMP computes the "1-step" prediction for the X matrix.
% Low level: the treepartition structure should be loaded in the memory.
% Usage:
%	Z=ADEVCMP(X,treepartition,nobs,thrsh)
% Input: X, a NxDIMINP matrix which contains N points where the estimate 
%	is to be computed
% Output: Z, Nx1 vector, the computed estimate.
% Comments:
%	can be compiled

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:55:50 $

% Author(s): Anatoli Iouditski

diminp=size(x,2);
maxstep=size(ht.LocalizingVectors,1);
lmax=ht.TreeLevelPntr(maxstep);

if isempty(ht.LocalizingVectors)
    ctrlMsgUtils.error('Ident:idnlmodel:emptyTree')
else
    dsize=size(x,1);
    dl0=sqrt(2*log(nobs));
    if dsize==1, % scalar operation
        x=[1,x];
        ntptr=1;
        for j=1:lmax,
            ldelta=dl0/thrp*sqrt(nv*sum(x'.*(v2mat(ht.LocalCovMatrix(ntptr,:))*x')));
            lfmax(j)=ht.LocalParVector(ntptr,:)*x'+ ldelta;
            lfmin(j)=lfmax(j)- 2*ldelta;
            if any(ht.LocalizingVectors(ntptr,:)),
                cprt=ht.LocalizingVectors(ntptr,2:diminp+1)*x(2:diminp+1)';
                if cprt<ht.LocalizingVectors(ntptr,1),
                    ntptr=ht.AncestorDescendantPntr(ntptr,2);
                else
                    ntptr=ht.AncestorDescendantPntr(ntptr,3);
                end
            elseif j<lmax,
                lfmax(j+1:lmax)=lfmax(j);
                lfmin(j+1:lmax)=lfmin(j);
                break;
            end
        end
        for j=lmax-1:-1:1
            lfmax(j)=min(lfmax(j+1),lfmax(j));
            lfmin(j)=max(lfmin(j+1),lfmin(j));
        end;
        lind=sum(lfmax<lfmin)+1;
        z=(lfmax(lind)+lfmin(lind))'/2;
        %lrsk=(lfmax(lind)-lfmin(lind))'/2;
        %
        
    else % vector operation
        pntr=[1:dsize];
        dpntr=[1,dsize];
        xx=x;
        % onlyz=max(sum(ht.LocalizingVectors~=zeros(size(ht.LocalizingVectors))));
        for i=1:maxstep
            if any(ht.LocalizingVectors(i,:)),
                lwin=dpntr(i,1);
                rwin=dpntr(i,2);
                if (lwin~=0)&&(rwin~=0)
                    x=xx(lwin:rwin,:);
                    tmpntr=pntr(lwin:rwin);
                    [tmp1,pntx]=sort(ht.LocalizingVectors(i,2:diminp+1)*x');
                    cpntx=sum(tmp1<=ht.LocalizingVectors(i,1));
                    if (cpntx<=rwin-lwin)&&(cpntx>0)
                        dpntr=[dpntr;[lwin,cpntx+lwin-1];[cpntx+lwin,rwin]];
                    elseif (cpntx==rwin-lwin+1)
                        dpntr=[dpntr;[lwin,rwin];[0,0]];
                    elseif (cpntx==0)
                        dpntr=[dpntr;[0,0];[lwin,rwin]];
                    end
                    pntr(lwin:rwin)=tmpntr(pntx);
                    xx(lwin:rwin,:)=x(pntx,:);

                else
                    dpntr=[dpntr;[0,0];[0,0]];
                end;
            end;
            if (dpntr(i,1)~=0)&&(dpntr(i,2)~=0)
                x=xx(dpntr(i,1):dpntr(i,2),:);
                x=[ones(size(x,1),1),x];
                ldelta=dl0/thrp*sqrt(nv*sum(x'.*(v2mat(ht.LocalCovMatrix(i,:))*x')));
                if any(ht.LocalizingVectors(i,:))
                    lfmax(ht.TreeLevelPntr(i),tmpntr(pntx))=...
                        ht.LocalParVector(i,:)*x'+ ldelta;
                    lfmin(ht.TreeLevelPntr(i),tmpntr(pntx))=...
                        lfmax(ht.TreeLevelPntr(i),tmpntr(pntx))- 2*ldelta;
                else
                    lfmax(ht.TreeLevelPntr(i):lmax,pntr(dpntr(i,1):dpntr(i,2)))=...
                        ones(lmax-ht.TreeLevelPntr(i)+1,1)*(ht.LocalParVector(i,:)*x'+ ldelta);
                    lfmin(ht.TreeLevelPntr(i):lmax,pntr(dpntr(i,1):dpntr(i,2)))=...
                        ones(lmax-ht.TreeLevelPntr(i)+1,1)*(ht.LocalParVector(i,:)*x'- ldelta);
                end
            end;
        end

        for i=lmax-1:-1:1
            lfmax(i,:)=min(lfmax(i+1,:),lfmax(i,:));
            lfmin(i,:)=max(lfmin(i+1,:),lfmin(i,:));
        end;
 
        %
        lind=sum(lfmax<lfmin);

        lind=lind+(1:lmax:lmax*(dsize-1)+1);

        z=(lfmax(lind)+lfmin(lind))'/2;
        %lrsk=(lfmax(lind)-lfmin(lind))'/2;
        %
    end
end
% end adevcmp 

function [Uout,Sout,Vout] = svd(A,economy)
%Embedded MATLAB Library Function

%   Copyright 2002-2009 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(isa(A,'float'), ...
    ['Function ''svd'' is not defined for values of class ''' class(A) '''.']);
ONE = ones(eml_index_class);
aZERO = eml_scalar_eg(A);
for k = ONE:eml_numel(A)
    if ~isfinite(A(k))
        eml_error('MATLAB:svd:matrixWithNaNInf', ...
            'Input to SVD must not contain NaN or Inf.');
    end
end
wantv = nargout == 3;
wantu = nargout >= 2;
if nargin == 1,
    econ = -1;
else
    eml_assert(eml_is_const(economy), ...
        'Second argument must be a constant 0 or constant string ''econ''');
    if ischar(economy) && strcmp(economy,'econ')
        econ = 1;
    elseif isscalar(economy) && (economy == 0),
        econ = 0;
    else
        eml_assert(false, ...
            'Use svd(X,0) or svd(X,''econ'') for economy size decomposition.');
    end
end
n = cast(size(A,1),eml_index_class);
p = cast(size(A,2),eml_index_class);
nru = n;
ncS = p;
nrv = p;
ncv = p;
ns = min(eml_index_plus(n,1),p);
minnp = min(n,p);
if econ == -1
    ncu = n;
    nrS = n;
else
    ncu = minnp;
    nrS = minnp;
end
s = eml_expand(aZERO,[ns,1]);
e = eml_expand(aZERO,[p,1]);
work = eml_expand(aZERO,[n,1]);
if wantu
    U = eml_expand(aZERO,[nru,ncu]);
end
if wantv
    V = eml_expand(aZERO,[nrv,ncv]);
end
if isempty(A)
    if wantu
        for ii = 1:min(nru,ncu)
            U(ii,ii) = 1;
        end
    end
    if wantv
        for ii = 1:min(nrv,ncv)
            V(ii,ii) = 1;
        end
    end
else
    % Reduce A to bidiagonal form, storing the diagonal elements
    % in s and the super-diagonal elements in e.
    nrt = min(eml_index_minus(max(p,2),2),n);
    nct = min(eml_index_minus(max(n,1),1),p);
    nrtp1 = eml_index_plus(nrt,1);
    nctp1 = eml_index_plus(nct,1);
    for q = 1:max(nct,nrt)
        qp1 = eml_index_plus(q,1);
        qm1 = eml_index_minus(q,1);
        qq = eml_index_plus(q,eml_index_times(n,qm1));
        nmq = eml_index_minus(n,q);
        nmqp1 = eml_index_plus(nmq,1);
        if q <= nct
            % Compute the transformation for the q-th column and
            % place the q-th diagonal in s(q).
            % s(q) = norm(A(q:n,q));
            nrm = eml_xnrm2(nmqp1,A,qq,1);
            if nrm == 0
                s(q) = 0;
            else
                s(q) = csign(nrm,A(qq));
                % A(q:n,q) = A(q:n,q)/s(q)
                A = eml_xscal(nmqp1,eml_div(1,s(q)),A,qq,ONE);
                A(qq) = A(qq) + 1;
                s(q) = -s(q);
            end
        end
        for jj = qp1:p
            qjj = eml_index_plus(q,eml_index_times(n,eml_index_minus(jj,1)));
            if (q <= nct) && (s(q) ~= 0)
                % Apply the transformation.
                % t = -A(q:n,q)'*A(q:n,jj)/A(q,q);
                t = eml_xdotc(nmqp1,A,qq,ONE,A,qjj,ONE);
                t = -eml_div(t,A(q,q));
                % A(q:n,jj) = A(q:n,jj) + t*A(q:n,q);
                A = eml_xaxpy(nmqp1,t,[],qq,ONE,A,qjj,ONE);
            end
            % Place the q-th row of A into e for the
            % subsequent calculation of the row transformation.
            e(jj) = conj(A(qjj));
        end
        if wantu && (q <= nct)
            % Place the transformation in U for subsequent back multiplication.
            for ii = q:n
                U(ii,q) = A(ii,q);
            end
        end
        if q <= nrt
            pmq = eml_index_minus(p,q);
            % Compute the q-th row transformation and place the
            % q-th super-diagonal in e(q).
            % e(q) = norm(e(qp1:p));
            nrm = eml_xnrm2(pmq,e,qp1,1);
            if nrm == 0
                e(q) = 0;
            else
                e(q) = csign(nrm,e(qp1));
                % e(qp1:p) = e(qp1:p)/e(q);
                e = eml_xscal(pmq,eml_div(1,e(q)),e,qp1,ONE);
                e(qp1) = e(qp1) + 1;
            end
            if isreal(e)
                e(q) = -e(q);
            else
                e(q) = complex(-real(e(q)),imag(e(q))); % -conj(e(q))
            end
            if (qp1 <= n) && (e(q) ~= 0)
                % Apply the transformation.
                for ii = qp1:n
                    work(ii) = 0;
                end
                for jj = qp1:p
                    % work(qp1:n) = work(qp1:n) + e(jj)*A(qp1:n,jj);
                    qp1jj = eml_index_plus(qp1,eml_index_times(n,eml_index_minus(jj,1)));
                    work = eml_xaxpy(nmq,e(jj),A,qp1jj,ONE,work,qp1,ONE);
                end
                for jj = qp1:p
                    t = conj( eml_div(-e(jj),e(qp1)) );
                    % A(qp1:n,jj) = A(qp1:n,jj) + t*work(qp1:n);
                    qp1jj = eml_index_plus(qp1,eml_index_times(n,eml_index_minus(jj,1)));
                    A = eml_xaxpy(nmq,t,work,qp1,ONE,A,qp1jj,ONE);
                end
            end
            if wantv
                % Place the transformation in V for subsequent back multiplication.
                for ii = qp1:p
                    V(ii,q) = e(ii);
                end
            end
        end
    end
    % Set up the final bidiagonal matrix or order m.
    m = min(p,eml_index_plus(n,1));
    if nct < p
        s(nctp1) = A(nctp1,nctp1);
    end
    if n < m
        s(m) = 0;
    end
    if nrtp1 < m
        e(nrtp1) = A(nrtp1,m);
    end
    e(m) = 0;
    % If required, generate U.
    if wantu
        if nctp1 <= ncu
            for jj = nctp1:ncu
                for ii = 1:nru
                    U(ii,jj) = 0;
                end
                U(jj,jj) = 1;
            end
        end
        for q = nct:-1:1 % isempty(A) --> nct == 0
            qp1 = eml_index_plus(q,1);
            nmq = eml_index_minus(n,q);
            nmqp1 = eml_index_plus(nmq,1);
            qq = eml_index_plus(q,eml_index_times(nru,eml_index_minus(q,1)));
            if s(q) ~= 0
                for jj = qp1:ncu
                    qjj = eml_index_plus(q,eml_index_times(nru,eml_index_minus(jj,1)));
                    % t = -U(q:n,q)'*U(q:n,jj)/U(q,q);
                    t = eml_xdotc(nmqp1,U,qq,ONE,U,qjj,ONE);
                    t = -eml_div(t,U(qq));
                    % U(q:n,jj) = U(q:n,jj) + t*U(q:n,q);
                    U = eml_xaxpy(nmqp1,t,[],qq,ONE,U,qjj,ONE);
                end
                % U(q:n,q) = -U(q:n,q);
                for ii = q:n
                    U(ii,q) = -U(ii,q);
                end
                U(qq) = U(qq) + 1;
                for ii = 1:eml_index_minus(q,1)
                    U(ii,q) = 0;
                end
            else
                for ii = 1:n
                    U(ii,q) = 0;
                end
                U(qq) = 1;
            end
        end
    end
    % If it is required, generate V.
    if wantv
        for q = p:-1:1
            if (q <= nrt) && (e(q) ~= 0) % isempty(A) --> nrt == 0
                qp1 = eml_index_plus(q,1);
                pmq = eml_index_minus(p,q);
                qp1q = eml_index_plus(qp1,eml_index_times(nrv,eml_index_minus(q,1)));
                for jj = qp1:p
                    qp1jj = eml_index_plus(qp1,eml_index_times(nrv,eml_index_minus(jj,1)));
                    % t = -V(qp1:p,q)'*V(qp1:p,jj)/V(qp1,q);
                    t = eml_xdotc(pmq,V,qp1q,ONE,V,qp1jj,ONE);
                    t = -eml_div(t,V(qp1q));
                    % V(qp1:p,jj) = V(qp1:p,jj) + t*V(qp1:p,q);
                    V = eml_xaxpy(pmq,t,[],qp1q,ONE,V,qp1jj,ONE);
                end
            end
            for ii = 1:p
                V(ii,q) = 0;
            end
            V(q,q) = 1;
        end
    end
    % Transform s and e so that they are real
    for q = 1:m
        if s(q) ~= 0
            rt = abs(s(q));
            r = eml_div(s(q),rt);
            s(q) = rt;
            if q < m
                e(q) = eml_div(e(q),r);
            end
            if wantu && (q <= n)
                % Checking q <= n is prudent but redundant because m<=n+1 by
                % definition and s(m)==0 when m==n+1.
                colq = eml_index_plus(1,eml_index_times(nru,eml_index_minus(q,1)));
                U = eml_xscal(n,r,U,colq,ONE);
            end
        end
        if q < m
            if e(q) ~= 0
                rt = abs(e(q));
                r = eml_div(rt,e(q));
                e(q) = rt;
                s(eml_index_plus(q,1)) = s(eml_index_plus(q,1)) * r;
                if wantv
                    colqp1 = eml_index_plus(1,eml_index_times(nrv,q));
                    V = eml_xscal(p,r,V,colqp1,ONE);
                end
            end
        end
    end
    % Main iteration loop for the singular values.
    maxit = 75;
    mm = m;
    iter = 0;
    tiny = eml_div(realmin(class(A)),eps(class(A)));
    snorm = zeros(class(A));
    for ii = 1:m
        snorm = max(snorm, max(abs(real(s(ii))),abs(real(e(ii)))));
    end
    while m > 0
        % If too many iterations have been performed, set flag and return.
        if iter >= maxit
            eml_error('MATLAB:svd:NoConvergence','SVD fails to converge');
            break
        end
        % This section of the program inspects for
        % negligible elements in the s and e arrays.  On
        % completion the variables kase and q are set as follows.
        %
        % kase = 1     if s(m) and e(q-1) are negligible and q<m
        % kase = 2     if s(q) is negligible and q<m
        % kase = 3     if e(q-1) is negligible, q<m, and
        %              s(q), ..., s(m) are not negligible (qr step).
        % kase = 4     if e(m-1) is negligible (convergence).
        q = eml_index_minus(m,1);
        for ii = eml_index_minus(m,1):-1:0
            q = ii;
            if ii == 0
                break
            end
            test0 = abs(real(s(ii))) + abs(real(s(eml_index_plus(ii,1))));
            ztest0 = abs(real(e(ii)));
            if (ztest0 <= eps(class(A))*test0) || (ztest0 <= tiny) || ...
                    (iter > 20 && ztest0 <= eps(class(A))*snorm),
                e(ii) = 0;
                break
            end
        end
        if q == eml_index_minus(m,1)
            kase = 4;
        else
            qs = m;
            for ii = m:-1:q
                qs = ii;
                if ii == q
                    break
                end
                test = zeros(class(A));
                if ii < m
                    test = test + abs(real(e(ii)));
                end
                if ii > eml_index_plus(q,1)
                    test = test + abs(real(e(eml_index_minus(ii,1))));
                end
                ztest = abs(real(s(ii)));
                if (ztest <= eps(class(A))*test) || (ztest <= tiny)
                    s(ii) = 0;
                    break
                end
            end
            if qs == q
                kase = 3;
            elseif qs == m
                kase = 1;
            else
                kase = 2;
                q = qs;
            end
        end
        q = eml_index_plus(q,1);
        % Perform the task indicated by kase.
        switch kase
            case 1 % Deflate negligible s(m).
                f = real(e(eml_index_minus(m,1)));
                e(eml_index_minus(m,1)) = 0;
                for k = eml_index_minus(m,1):-1:q
                    t1 = real(s(k));
                    [t1,f,cs,sn] = eml_xrotg(t1,f);
                    s(k) = t1;
                    if k > q
                        km1 = eml_index_minus(k,1);
                        f = -sn * real(e(km1));
                        e(km1) = e(km1) * cs;
                    end
                    if wantv
                        colk = eml_index_plus(1,eml_index_times(nrv,eml_index_minus(k,1)));
                        colm = eml_index_plus(1,eml_index_times(nrv,eml_index_minus(m,1)));
                        V = eml_xrot(p,V,colk,ONE,[],colm,ONE,cs,sn);
                    end
                end
            case 2 % Split at negligible s(q).
                qm1 = eml_index_minus(q,1);
                f = real(e(qm1));
                e(qm1) = 0;
                for k = q:m
                    t1 = real(s(k));
                    [t1,f,cs,sn] = eml_xrotg(t1,f);
                    s(k) = t1;
                    f = -sn * real(e(k));
                    e(k) = e(k) * cs;
                    if wantu
                        colk = eml_index_plus(1,eml_index_times(nru,eml_index_minus(k,1)));
                        colqm1 = eml_index_plus(1,eml_index_times(nru,eml_index_minus(qm1,1)));
                        U = eml_xrot(n,U,colk,ONE,[],colqm1,ONE,cs,sn);
                    end
                end
            case 3 % Perform one qr step.
                % Calculate the shift.
                mm1 = eml_index_minus(m,1);
                scale = max([abs(real(s(m))),abs(real(s(mm1))),...
                    abs(real(e(mm1))), ...
                    abs(real(s(q))),abs(real(e(q)))]);
                sm = eml_div(real(s(m)),scale);
                smm1 = eml_div(real(s(mm1)),scale);
                emm1 = eml_div(real(e(mm1)),scale);
                sqds = eml_div(real(s(q)),scale);
                eqds = eml_div(real(e(q)),scale);
                b = eml_div((smm1 + sm)*(smm1 - sm) + emm1*emm1,2);
                c = sm * emm1;
                c = c * c;
                shift = zeros(class(A));
                if (b ~= 0) || (c ~= 0)
                    shift = sqrt(b*b + c);
                    if b < 0
                        shift = -shift;
                    end
                    shift = eml_div(c,b+shift);
                end
                f = (sqds + sm)*(sqds - sm) + shift;
                g = sqds * eqds;
                % Chase zeros.
                for k = q:mm1
                    km1 = eml_index_minus(k,1);
                    kp1 = eml_index_plus(k,1);
                    [f,g,cs,sn] = eml_xrotg(f,g);
                    if k > q
                        e(km1) = f;
                    end
                    f = cs*real(s(k)) + sn*real(e(k));
                    e(k) = cs*e(k) - sn*s(k);
                    g = sn * real(s(kp1));
                    s(kp1) = s(kp1) * cs;
                    if wantv
                        colk = eml_index_plus(1,eml_index_times(nrv,eml_index_minus(k,1)));
                        colkp1 = eml_index_plus(1,eml_index_times(nrv,k));
                        V = eml_xrot(p,V,colk,ONE,[],colkp1,ONE,cs,sn);
                    end
                    [f,g,cs,sn] = eml_xrotg(f,g);
                    s(k) = f;
                    f = cs*real(e(k)) + sn*real(s(kp1));
                    s(kp1) = -sn*e(k) + cs*s(kp1);
                    g = sn * real(e(kp1));
                    e(kp1) = e(kp1) * cs;
                    if wantu && (k < n)
                        colk = eml_index_plus(1,eml_index_times(nru,eml_index_minus(k,1)));
                        colkp1 = eml_index_plus(1,eml_index_times(nru,k));
                        U = eml_xrot(n,U,colk,ONE,[],colkp1,ONE,cs,sn);
                    end
                end
                e(eml_index_minus(m,1)) = f;
                iter = iter + 1;
            otherwise % case 4 % Convergence.
                % Make the singular value positive.
                if real(s(q)) < 0
                    s(q) = -real(s(q));
                    if wantv
                        % V(:,q) = -V(:,q);
                        colq = eml_index_plus(1,eml_index_times(nrv,eml_index_minus(q,1)));
                        V = eml_xscal(p,-1+eml_scalar_eg(V),V,colq,ONE);
                    end
                end
                % Order the singular value.
                qp1 = eml_index_plus(q,1);
                while (q < mm) && (real(s(q)) < real(s(qp1)))
                    rt = real(s(q));
                    s(q) = real(s(qp1));
                    s(qp1) = rt;
                    if wantv && (q < p)
                        % V(1:p,[q q+1]) = V(1:p,[q+1 q]);
                        colq = eml_index_plus(1,eml_index_times(nrv,eml_index_minus(q,1)));
                        colqp1 = eml_index_plus(1,eml_index_times(nrv,q));
                        V = eml_xswap(p,V,colq,ONE,[],colqp1,ONE);
                    end
                    if wantu && (q < n)
                        % U(1:n,[q q+1]) = U(1:n,[q+1 q]);
                        colq = eml_index_plus(1,eml_index_times(nru,eml_index_minus(q,1)));
                        colqp1 = eml_index_plus(1,eml_index_times(nru,q));
                        U = eml_xswap(n,U,colq,ONE,[],colqp1,ONE);
                    end
                    q = qp1;
                    qp1 = eml_index_plus(q,1);
                end
                iter = 0;
                m = eml_index_minus(m,1);
        end
    end
end
if nargout < 2
    Uout = zeros(minnp,1,class(A));
    % Uout(1:rr) = real(s(1:rr));
    for k = ONE:minnp
        Uout(k) = real(s(k));
    end
else
    if (econ < 1) || (econ == 1 && n >= p)
        Uout = U;
        Sout = zeros(nrS,ncS,class(A));
        for ii = ONE:minnp
            Sout(ii,ii) = real(s(ii));
        end
        if wantv
            Vout = V;
        end
    else
        % Uout = U(1:n,1:n);
        % Sout = S(1:n,1:n);
        Uout = eml.nullcopy(eml_expand(aZERO,[n,n]));
        Sout = eml.nullcopy(zeros(n,class(A)));
        for jj = ONE:n
            for ii = ONE:n
                Uout(ii,jj) = U(ii,jj);
                Sout(ii,jj) = 0;
            end
            Sout(jj,jj) = real(s(jj));
        end
        if wantv
            % Vout = V(1:nrv,1:n);
            Vout = eml.nullcopy(eml_expand(aZERO,[nrv,n]));
            for jj = ONE:n
                for ii = ONE:nrv
                    Vout(ii,jj) = V(ii,jj);
                end
            end
        end
    end
end

%--------------------------------------------------------------------------

function y = csign(absx,d)
% y = absx * d/abs(d)
eml_must_inline;
if isreal(d)
    if d < 0
        y = -absx;
    else
        y = absx;
    end
else
    if d == 0
        y = complex(absx);
    else
        y = eml_div(absx,abs(d)) * d;
    end
end

%--------------------------------------------------------------------------

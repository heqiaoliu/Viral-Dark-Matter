function x=lsolve(L,b)
%LSOLVE  Solve GF lower-triangular system L*x=b.  
%  LSOLVE(L,b) is the solution to the lower-triangular 
%  system of equations L*x=b. b must be a column vector.
%
%  See also USOLVE, LU, INV.

%    Copyright 1996-2007 The MathWorks, Inc.
%    $Revision: 1.3.4.4 $  $Date: 2007/09/14 15:58:56 $ 

global GF_TABLE_M GF_TABLE_PRIM_POLY GF_TABLE1 GF_TABLE2

    if ~isa(L,'gf'), L = gf(L,b.m,b.prim_poly); end
    if ~isa(b,'gf'), b = gf(b,L.m,L.prim_poly); end
    if L.m~=b.m
      error('comm:gf_lsolve:MismatchOrders','Orders must match.')
    elseif L.prim_poly~=b.prim_poly
      error('comm:gf_lsolve:MismatchPrim_Poly','Primitive polynomials must match.')
    end

    n=length(L.x);
    if (length(b.x) ~= n),
        error('comm:gf_lsolve:MismatchInpDims',' LSOLVE: Inputs L and b must be of compatible dimensions');
    end;

    if any(( any(double(L.x)-double(tril(L.x))) )), 
        error('comm:gf_lsolve:LNotLwrTriangularMtx',' LSOLVE: Input matrix L must be lower-triangular');
    end;

    if( any(diag(double(L.x))==0) ), 
        error('comm:gf_lsolve:SingularL',' LSOLVE: Input matrix L must be nonsingular');
    end;

    x=b;
    if ~isequal(x.m,GF_TABLE_M) | ~isequal(x.prim_poly,GF_TABLE_PRIM_POLY)
       [GF_TABLE_M,GF_TABLE_PRIM_POLY,GF_TABLE1,GF_TABLE2] = gettables(x);
    end
    x.x=uint32(zeros(size(b.x)));
    x.x(1)=gf_mex(b.x(1),...
                    gf_mex(L.x(1,1),L.x(1,1),b.m,'rdivide',...
                          b.prim_poly,GF_TABLE1,GF_TABLE2),...
                    b.m,'times',x.prim_poly,GF_TABLE1,GF_TABLE2);
    for k=2:n,
        Lkk_inv = gf_mex(L.x(k,k),L.x(k,k),b.m,'rdivide',...
                           x.prim_poly,GF_TABLE1,GF_TABLE2);
        Lx = gf_mex(L.x(k,1:k-1),x.x(1:k-1),b.m,'mtimes',...
                      x.prim_poly,GF_TABLE1,GF_TABLE2);
        x.x(k)= gf_mex(bitxor(b.x(k),Lx),Lkk_inv,b.m,'mtimes',...
                         x.prim_poly,GF_TABLE1,GF_TABLE2);
    end;


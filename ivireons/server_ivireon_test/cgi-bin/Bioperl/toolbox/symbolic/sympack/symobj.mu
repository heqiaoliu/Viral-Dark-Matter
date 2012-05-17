// symobj - MATLAB interface library

//   Copyright 2009-2010 The MathWorks, Inc.

symobj := newDomain("symobj"):

symobj::Name := "symobj":
symobj::info := "Library 'symobj': the Symbolic Math Toolbox interface library":
symobj::interface := {}:

// defining the methods

// Copyright 2009-2010 The MathWorks, Inc.

/* Calculate indices for indexing in subsasgn. x(ind1,ind2,...) = y
 * inputs:
 *   xdims   dims of LHS (x)
 *   inds    list of indexing values (ind1,ind2,...)
 *   nin     nops(inds)
 *   y       RHS
 *   ny      nops(y)
 *   allZero true if all xdims are 0
 * outputs: [lhsDims, vinds, doAss, resize]
 *   lhsDims new LHS dims for each index
 *   vinds   list of transformed indices [M,V,L,F] where M is max index,
 *           V is the vector of indexing values (NULL if colon), L
 *           is length and F is 0,1,-1 
 *   doAss   true if not an empty assignment command
 *   resize  true if LHS is to be resized
 */
symobj::ConvertSubsasgn := proc(xdims,inds,nin,y,ny,allZero)
option noExpose;
local vinds,lhsDims,k,doAss,fun,resize,empty_subs,scalar,tmp;
begin
  doAss := TRUE;
  scalar := bool(ny = 1);
  if allZero then
    lhsDims := [0$k=1..nin];
  else
    lhsDims := symobj::GetWorkingDimensions(nin,xdims);
  end_if:
  empty_subs := FALSE;
  fun := proc(n)
    local lind;
    begin 
      lind := symobj::ConvertToIndex(inds[n],lhsDims[n]);
      if lind[4]=1 and scalar then
        doAss := FALSE;
        empty_subs := TRUE;
      end_if:
      lind;
    end_proc:
  vinds := map([k$k=1..nin],fun);
  if not empty_subs then
    if allZero then
      tmp := symobj::matchAndResizeIndicesToRHSDimensions(y,scalar,vinds);
      doAss := doAss and tmp[1];
      vinds := tmp[2];
    elif not scalar then
     // TODO error checking: port MatchIndicesToRHSDimensions
    end_if:
  end_if:
  resize := FALSE;
  for k from 1 to nin do
    if vinds[k][1] > lhsDims[k] then
      lhsDims[k] := vinds[k][1];
      resize := TRUE;
    end_if:
  end_for:
  if not resize and scalar and _mult(op(xdims))=0 then
    doAss := FALSE;
  end_if:
  [lhsDims, vinds, doAss, resize];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert subscripting indices into indexing data for subsref.
 *  inputs:
 *    inds   list of indexing expressions
 *    nin    nops(inds)
 *    wdim   working dimensions list of nin integers
 *  outputs:
 *    list of indexing data for each indexing expression. see ConvertToIndex
 */
symobj::ConvertSubsref := proc(inds,nin,wdim)
option noExpose;
local fun,i;
begin
  fun := proc(n)
    local res;
    begin
      res := symobj::ConvertToIndex(inds[n],wdim[n]);
      if res[1] > wdim[n] and res[3] > 0 then
        error("symbolic:TooManySubscripts#Index exceeds matrix dimensions.");
      end_if:
      res;
    end_proc:
  map([i$i=1..nin],fun);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert an input index into indexing data for subsref or subsasgn.
 *  inputs:
 *    ind    the indexing object to analyze
 *    sz     the size of the working dimension in the indexing position
 *  outputs: [maxInd, res, len, flag]
 *    maxInd the maximum of sz or the maximum index value
 *    res    the expanded integer index values for this position or NULL
 *    len    number of elements selected in this dimension
 *    flag   0: normal, -1: select all elements, 1: select no elements
 */
symobj::ConvertToIndex := proc(ind,sz)
option noExpose;
local maxInd,res,flag,xdim,len;
begin
  maxInd := 0;
  res := NULL;
  flag := 0;
  len := 0;
  if symobj::isColonIndex(ind) then
    maxInd := sz;
    len := sz;
    if sz=0 then
      flag := -1;
    end_if:
  elif type(ind)=DOM_INT then
    maxInd := ind;
    len := 1;
    res := [ind];
  else
    if symobj::islisty(ind) then
      xdim := symobj::size(ind);
      ind := symobj::flattenSymOrder(ind);
    else
      xdim := [1,1];
    end_if:
    if nops(ind)>0 and type(op(ind,1)) = DOM_BOOL then
      ind := symobj::bool2intv(ind,xdim);
      res := ind;
    end_if:
    len := nops(ind);
    if len=0 then
      flag := 1;
    else
      res := ind;
      maxInd := max(op(ind));
    end_if:
  end_if:
  [maxInd, res, len, flag];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Determine "working dimensions" for an indexing operation.  Accounts
 * for the fact that an array can be indexed with fewer or more indices
 * than there are dimensions in the indexed array.
 *  inputs:
 *   nin    number of indices
 *   xdims  dimensions of indexed array
 *  output:
 *   dimensions of indexed array reshaped into nin dimensions
 */
symobj::GetWorkingDimensions := proc(nin,xdims)
option noExpose;
local res, nx;
begin
  nx := nops(xdims);
  if nin < nx then
    res := xdims[1 .. nin];
    res[nin] := _mult(res[nin],op(xdims,(nin+1)..nx));
  elif nin > nx then
    res := append(xdims,1$(nin-nx));
  else
    res := xdims;
  end_if:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Serialize elements of x to a string separated by '#!' in MATLAB order.
 *  inputs:
 *    x   the expression to serialize (eg [a b;c d])
 *  outputs:
 *    the string (eg "a#!c#!b#!d")
 */
symobj::allstrs := proc(x)
option hold;
local y;
save DIGITS;
begin
  y := expr2text(x):
  // check for custom digits setting
  if stringlib::pos(y,"_symans",1)=1 then
      y := stringlib::split(y,"_");
      if nops(y)=4 then
          DIGITS := text2expr(y[3]);
      end_if:
  end_if:
  x := context(x);
  if symobj::islisty(x) and nops(x)>1 then
    y := symobj::flattenSymOrder(x);
    y := map(y,(e)->symobj::expr2text(symobj::outputproc(e))."#!");
    _concat(op(y));
  else
    x := symobj::extractscalar(x):
    symobj::expr2text(symobj::outputproc(x));
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Create array (DOM_ARRAY).  
 * inputs:
 *   items    list of elements in MuPAD order
 *   varargin remaining inputs are dimensions 
 */
symobj::array := proc(items /*,dim1,dim2,...*/ )
  local dims;
begin
  dims := [args(2..args(0))];
  dims := map(dims,(x)->1..x);
  array(op(dims),items);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Implement vectorized MATLAB-style atan2(y,x). x and y must have the same size.
 *  inputs:
 *    y    y value(s)
 *    x    x value(s)
 *  output:
 *    the array formed by the arctan of y and x
 */
symobj::atan2 := proc(y,x)
begin
  // atan seems to not allow scalar expansion like other array ops.
  if symobj::numel(y)<>symobj::numel(x) then
    error("symbolic:ArraySizeMismatch#Array sizes must match.");
  end_if:
  symobj::checkFloatDigits(symobj::zip(x,y,arg));
end_proc:


// Copyright 2009-2010 The MathWorks, Inc.

/* Apply special functions of the form fcn(nu,x) where one input is scalar.
 *  inputs:
 *    nu  the parameter (possible array)
 *    x   the x value (possible array)
 *    fcn the special function to evaluate
 *  outputs:
 *    the value or array of values of fcn(nu,x)
 */
symobj::bessel := proc(nu,x,fcn)
local nx,nnu,f2;
begin
  nx := symobj::numel(x);
  nnu := symobj::numel(nu);
  if nnu = 1 then
    f2 := (z)->fcn(nu,z);
    symobj::mapcatch(x,f2,infinity);
  elif nx = 1 then
    f2 := (v)->fcn(v,x);
    symobj::mapcatch(nu,f2,infinity);
  else
    error("symbolic:ScalarInputExpected#One argument must be a scalar.");
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert bool indexing values in MATLAB order to integer indices.
 *  inputs:
 *    x     the bool index list in MATLAB order (or a single bool scalar)
 *    xdim  the original size vector of x
 *  outputs:
 *    [] or a vector of integer indices where x was TRUE. The vector has the 
 *    orientation of xdim if xdim was a vector.
 */
symobj::bool2intv := proc(x,xdim)
local i,res,xvec;
begin
  res := [];
  for i from 1 to nops(x) do
    if op(x,i) then
      res := append(res,i);
    end_if:
  end_for;
  xvec := symobj::isvector(xdim);
  if res=[] then
    res;
  elif xvec<>0 then
    xdim[xvec] := nops(res);
    symobj::symArray(xdim,res);
  elif res<>[] then
    matrix(nops(res),1,res); 
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Returns TRUE if x is a piecewise expression with no condition
 * of the form "C123 in ..."
 *  inputs:
 *    x   the expression to check
 *  outputs:
 *    TRUE if x is filterable
 */
symobj::canfilter := proc(x)
local nonC,findC;
begin

  // return TRUE when condition does not have "C123 in ..."
  findC := proc(cond)
  local str;
  begin
    if bool(type(cond) = "_in") then
       str := "" . op(cond,1);
       not strmatch(str, "^C\\d+$");
    else
       TRUE;
    end_if:
  end_proc:

  nonC := piecewise::selectConditions(x,findC);
  bool( piecewise::numberOfBranches(nonC) = piecewise::numberOfBranches(x) );
end_proc:


// Copyright 2009-2010 The MathWorks, Inc.

/* Serialize x to a string in MuPAD syntax. Objects which are too big
 * are truncated using (...) in place of extra operands. The measure
 * of "too big" is defined in symobj::expr2text.
 *  inputs:
 *    x      the expression to serialize
 *    depth  the cutoff for the "depth" (default symobj::formatdepth)
 *  outputs:
 *    the string result
 */
symobj::char := proc(x,depth)
option hold;
local y,sz;
save DIGITS;
begin
  y := expr2text(x):
  // check for custom digits setting
  if stringlib::pos(y,"_symans",1)=1 then
      y := stringlib::split(y,"_");
      if nops(y)=4 then
          DIGITS := text2expr(y[3]);
      end_if:
  end_if:
  x := context(x):
  if symobj::islisty(x) then
    sz := symobj::size(x);
    if nops(sz) = 2 then
      x := symobj::tomatrix(x);
    end_if:
    x := symobj::extractscalar(x);
  end_if:
  if args(0) = 1 then
    depth := symobj::formatdepth;
  end_if:
  symobj::expr2text(x,depth);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute the characteristic polynomial of A wrt x. Error if not
 * convertible to a matrix.
 *  inputs:
 *    A   the expression to compute the char poly of
 *    x   the free variable
 *  outputs:
 *    an element of DOM_EXPR with poly in x.
 */
symobj::charpoly := (A,x)->expr(linalg::charpoly(symobj::tomatrix(A),x)):

// Copyright 2009-2010 The MathWorks, Inc.

/* Error if indexing inputs had more than 1 non-colon index.
 *  inputs:
 *    vinds  the processed index list
 *  outputs:
 *    none
 */
symobj::checkDeleteIndices := proc(vinds)
option noExpose;
local notcolon;
begin
  // vinds[k][2] is NULL if the index was a colon. check there is only 1.
  notcolon := select(vinds,(x)->bool(x[2]<>NULL));
  if nops(notcolon) > 1 then 
    symobj::subsasgnDimError();
  end_if:
end_proc:
// Copyright 2009-2010 The MathWorks, Inc.

symobj::checkFloatDigits := proc(x)
local fun,z;
begin
   if (x::dom::hasProp(Cat::Matrix)=TRUE) then
      map(x,symobj::checkFloatDigits);
   elif (type(x)=DOM_FLOAT or type(x)=DOM_COMPLEX) then
      (x*2)/2;
   else
      fun := z->(z*2)/2;
      misc::maprec(x,{DOM_FLOAT,DOM_COMPLEX}=fun,NoOperators);
   end_if;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Warn if input contains an unevaluated integral.
 *  inputs:
 *    x  the expression to check
 *  outputs:
 *    x
 */
symobj::checkIntFound := proc(x)
begin
  if hastype(x,"int") then
     warning("symbolic:sym:int:warnmsg1#Explicit integral could not be found.")
  end_if:
  symobj::checkFloatDigits(x);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

// get coeffs of a poly
symobj::coeffs := proc(f,x)
begin
  if args(0) = 1 then
    revert([coeff(f)]);
  else
    x := symobj::tolist(x);
    revert([coeff(f,x)]);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Get coeffs and terms of a polynomial.
 *  inputs:
 *    f   polynomial expression 
 *    x   optional free var of f
 *  outputs: [c, t]
 *    c   list of coefficients
 *    t   list of terms corresponding to c
 */
symobj::coeffsterms := proc(f,x)
local pol,lis,c,t,checkpoly;
begin
  checkpoly := proc() begin
    if pol=FAIL then
      error("symbolic:sym:coeffs:NotAPolynomial#Expression is not a polynomial.");
    end_if:
  end_proc:
  if args(0)=2 then
    x := symobj::tolist(x);
    pol := poly(f,x);
    checkpoly();
  else
    pol := poly(f);
    checkpoly();
    x := [op(pol,[2,1])];
  end_if:
  lis := poly2list(pol);
  c := map(lis,(e)->e[1]);
  if nops(x)=1 then
    t := map(lis,(e)->x[1]^e[2]);
  else
    t := map(lis,op,2); // [ [e11,e12..],..]
    t := map(t,(e)->zip(x,e,_power)); // [ [x11^e11,x12^e12..],..]
    t := map(t,(e)->_mult(op(e)));    // [ x11^e11*x12^e12.., ..]
  end_if:
  [ c,t ];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Trim trailing singleton dimensions from shape list up to leading 2 dims.
 *  inputs
 *    res  the shape list to trim
 *  outputs
 *    the trimmed shape list
 */
symobj::collapsedims := proc(dims)
local k;
begin
  k := nops(dims);
  while dims[k] = 1 and k > 2 do
    k := k-1;
  end_while:
  dims[1..k];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Collect like terms
 *  inputs
 *    ex  the expression to collect from
 *    x   the term to collect
 *  outputs
 *    the collected expression.
 *
 */
symobj::collect := proc(ex,x)
begin
  if args(0)=1 then
    collect(ex);
  elif symobj::islisty(x) then
    collect(ex,[op(x)]);
  else
    collect(ex,x);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute a basis for the column span of A.
 *  inputs
 *    A  the matrix
 *  outputs
 *    another matrix with the span of A
 */
symobj::colspace := proc(A)
local res,dims;
begin
  A := symobj::tomatrix(A);
  if nops(A) = 1 then
    if op(A,1) = 0 then
      matrix(0,0,[]);
    else
      1;
    end_if:
  else
    res := symobj::rref(linalg::transpose(A));
    res := linalg::transpose(res);
    dims := linalg::matdim(res);
    res := linalg::col(res,1..dims[2]);
    res := linalg::basis(res);
    linalg::concatMatrix(op(res));
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compose f(x) with g(y) to get f(g(z)).
 *  inputs
 *    f,g  the expressions to compose
 *    x    the variable of f 
 *    y    the variable of g
 *    z    the variable of the composition.
 *  outputs
 *    the composition expression in terms of z
 */
symobj::compose := proc(f,g,x,y,z)
  local f1,g1;
begin
  f1 := fp::unapply(f,x);
  g1 := fp::unapply(g,y);
  f1(g1(z));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert MATLAB-style ODE to MuPAD ODE object. X is an expression
 * or array where Df and D2f are used for derivatives of f. The changes
 * are to replace Dvar with D(var)(t), var with var(t) and DNNNvar with
 * (D@@NNN)(var)(t).
 *  inputs:
 *    X     an expression for the ODE in MATLAB format
 *    t     the independent variable
 *  outputs: [vars, DE]
 *    vars  list of dependent vars of the form [x(t),y(t),...]
 *    DE    the transformed ODE
 */
symobj::convertode := proc(X,t)
option noExpose;
local tryReplaceD,depvars,tdepvars,first_pass,replaceD;
begin
    tdepvars := {};
    first_pass := TRUE;

    replaceD := proc(str,ivar)
      local n;
      begin
        if length(str) > 0 then 
          n := text2expr(str);
          (D@@n)(ivar);
        else
          D(ivar);
        end_if:
      end_proc:

    /* subfunction to apply to every identifier to expand D2f to 
     * (D@@2)(f)(t), etc. Called twice - once to expand D2f to
     * (D@@2)(f) and again to replace f with f(t). Also builds
     * up the set of dependent variables tdepvars.
     */
    tryReplaceD := proc(x)
      local str,ivar;
      begin
        str := strmatch(expr2text(x),"^D(\\d*)(\\w+)$",ReturnMatches);
        if type(str)=DOM_LIST then
          ivar := text2expr(str[3]);
          tdepvars := tdepvars union {ivar(t)};
          ivar := replaceD(str[2],ivar);
          if first_pass then
            ivar(t);
          else
            ivar;
          end_if:
        elif first_pass and x<>t and bool(x in depvars) then
          x(t);
        else
          x;
        end_if:
    end_proc:
    
    if has(X,D) then
       error("symbolic:dsolve:errmsg1d#dsolve cannot use variable D");
    end_if:
    depvars := indets(X) minus Type::ConstantIdents minus {t};
    depvars := symobj::getdepvars(depvars);
    if bool(hold(D) in depvars) then
       error("symbolic:dsolve:errmsg1d#dsolve cannot use variable D");
    end_if:
    X := misc::maprec(X, {DOM_IDENT}=tryReplaceD, NoOperators);
    first_pass := FALSE;    
    X := misc::maprec(X, {DOM_IDENT}=tryReplaceD);
    [[op(tdepvars)], X];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Copies data from In to Out along specified indices. If dir is TRUE 
 * then indexing is for Out otherwise for In. If In is not an array 
 * (scalar) then inDims must be [].
 *  inputs:
 *    Out      array to copy to
 *    outDims  size of Out
 *    In       array or scalar to copy from
 *    inDims   size of In ([] if In is scalar)
 *    nelout   number of elements to copy
 *    vinds    vector of index vectors (NULL indicates a colon)
 *    lens     shape of space to copy
 *    dir      TRUE means indices are for Out.
 *  outputs:
 *    modified Out (with scalar extracted)
 */
symobj::copydata := proc(Out,outDims,In,inDims,nelout,vinds,lens,dir)
option noExpose;
local pos,     // current index being copied
      inPos,   // index of In to copy
      outPos,  // index of Out
      w,       // count of pos
      nlen,    // length of lens
      din,     // nops(inDims)
      dout,    // nops(outDims)
      tmp, vdim, fixInPos, fixOutPos, getValue;
begin
  vdim := symobj::isvector(inDims);
  nlen := nops(lens);
  pos := [1$nlen];
  din := nops(inDims);
  dout := nops(outDims);
  // expand any NULLs
  vinds := zip(lens,vinds,
        (n,v)->(if bool(v=NULL) then [w$w=1..n]; else v; end_if));

  fixInPos := proc()
  begin
    if nlen < din then
      inPos := symobj::dimexpand(inPos,inDims);
    elif nlen > din then
      inPos := inPos[1..din];
    end_if:
  end_proc:

  fixOutPos := proc()
  begin
    if nlen < dout then
      outPos := symobj::dimexpand(outPos,outDims);
    elif nlen > dout then
      outPos := outPos[1..dout];
    end_if:
  end_proc:

  getValue := proc()
  begin
    if din=0 then
      In; // scalar case
    elif vdim<>0 and dir then
      op(In,w); // vector case
    else
      indexval(In,op(inPos)); // array case
    end_if:
  end_proc:

  for w from 1 to nelout do
    inPos := pos;
    outPos := pos;
    if dir then
      outPos := zip(vinds,pos,_index);
    else
      inPos := zip(vinds,pos,_index);
    end_if:
    fixInPos();
    fixOutPos();
    tmp := getValue();
    Out[op(outPos)] := tmp;
    pos := symobj::incInd(pos,lens,nlen);
  end_for:
  symobj::extractscalar(Out):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Complex transpose.
 *  inputs
 *    A   the matrix to transpose
 *  outputs
 *    A'
 */
symobj::ctranspose := proc(A)
begin
  symobj::specialscalarcase(A,linalg::htranspose);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute determinant of A. Scalars are allowed.
 *  inputs
 *    A   the matrix
 *  outputs
 *    the determinant
 */
symobj::det := proc(A)
begin
  linalg::det(symobj::tomatrix(A));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB diag function. See help diag for more info.
 *  inputs:
 *    A    the matrix or diagonal vector
 *    n    the off-diagonal offset
 *  outputs:
 *    the diagonal vector or matrix
 */
symobj::diag := proc(A,n)
local dims, v, m, fun, vectorcase, matrixcase;
begin

  vectorcase := proc()
  begin
    A := [op(A)];
    m := max(dims[1],dims[2]);
    if n = 0 then
      matrix(m,m,A,Diagonal);
    else

      fun := proc(r,c) 
        begin
          if bool(c = r+n) then
            if n > 0 then
              A[r];
            else
              A[c];
            end_if:
          else
            0;
          end_if:
        end_proc:

      m := m+abs(n);
      matrix(m,m,fun);
    end_if:
  end_proc:

  matrixcase := proc()
  begin
    // get diagonal
    m := min(dims[1],dims[2])-abs(n);
    if n>0 then
      matrix(m, 1, (r,c)->indexval(A,r,r+n));
    else
      matrix(m, 1, (r,c)->indexval(A,r-n,r));
    end_if:
  end_proc:

  A := symobj::tomatrix(A);
  dims := linalg::matdim(A);
  v  := symobj::isvector(dims);
  if v<>0 then
    vectorcase();
  else
    matrixcase();
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Differentiate f wrt x n times. The expression can be an array of expressions.
 *  inputs:
 *    f    the expression to differentiate
 *    x    the variable
 *    n    the order of the derivative
 *  outputs:
 *    the nth derivative
 */
symobj::diff := proc(f,x,n)
begin
   symobj::map(f,(g)->diff(g,x$n));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Expand indexing list for an object with shape 'dim'. Leading singleton
 * dims are prepended and the trailing dim is expanded.
 *  inputs:
 *    pos     the index vector to expand
 *    dim     shape of the object to index
 *  outputs:
 *    the expanded index vector
 */
symobj::dimexpand := proc(pos,dim,single)
local n, nd, k, i, rest;
begin
  n := nops(pos);
  nd := nops(dim);
  // shift by leading 1 dims unless the position starts with ones
  i := 1;
  while n < nd and dim[i] = 1 do
    if i>n or pos[i]<>1 then
      pos := [1, op(pos)];
      n := n+1;
    end_if:
    i := i+1;
  end_while:
  // now expand the trailing dim
  while n < nd do
    k := pos[n]-1;
    if dim[n]=1 then
      i := 0;
      rest := k;
    else
      i := k mod dim[n];
      rest := (k-i) div dim[n];
    end_if:
    pos := [op(pos[1..n-1]),i+1,rest+1];
    n := n+1;
  end_while:
  pos;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Scalar divide. 0/B is inf and 0/0 is nan.
 *  inputs:
 *    A,B  the values to divide
 *  outputs:
 *    the result
 */
symobj::divide := proc(A,B)
begin
  if bool(B <> 0) then
    _divide(A,B);
  elif bool(A <> 0) then
    infinity;
  else
    undefined;
  end_if
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert expression to float with enough precision to try to avoid 
 * catastrophic cancellation. Expands RootOfs.
 *  inputs:
 *    x    the expression to convert
 *  outputs:
 *    the float
 */
symobj::double := proc(x)
  local subfun,subfunrat,ints,big,res;
  save DIGITS;
begin
  if symobj::islisty(x) then
    x := symobj::flattenSymOrder(x);
  end_if:
  x := symobj::removeRootOfs(x):
  // collect all the integers
  ints := []; 
  subfun := proc(n) begin ints := append(ints,n); n; end_proc;
  subfunrat := proc(n) begin ints := append(ints,numer(n),denom(n)); n; end_proc;
  misc::maprec(x,{DOM_INT}=subfun,{DOM_RAT}=subfunrat);
  // get the number of digits in the biggest integer or 1 if there were no integers
  if nops(ints) > 0 then
    big := ceil(float(symobj::log10(max(op(abs(ints)),10))));
  else
    big := 1;
  end_if:
  big := max(big,DIGITS);
  DIGITS := big+32; // use enough digits to try to prevent catastrophic cancellation
  res := float(x);
  if hastype(res,DOM_IDENT) then
    if has(res,eps_Var)or has(res,eps) then
      res := float(subs(x,[eps_Var=2^(-52),eps=2^(-52)]));
    end_if:
    if hastype(res,DOM_IDENT) then
      res := FALSE;
    end_if:
  end_if;
  if res=FALSE then
    error("symbolic:sym:double:cantconvert#DOUBLE cannot convert the input expression into a double array.\nIf the input expression contains a symbolic variable, use the VPA function instead.");
  end_if:
  DIGITS := 20; // truncate to a smaller number of digits for evaling in MATLAB
  res := float(res);
  subs(res,I=i,[RD_NINF=-infinity,RD_INF=infinity,RD_NAN=undefined]);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

// TODO: get example of Simplify slow and geck - try differnt steps

/* Since simplify does not do enough and Simplify takes too long for
 * piecewise answers, dsimplify is used on the output of dsolve.
 *  inputs:
 *    x   the expression to simplify
 *  outputs
 *    the simplified value
 */
symobj::dsimplify := proc(x)
begin
  if hastype(x,piecewise) then
     simplify(x);
  else
     Simplify(x);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to solve(ode(...)). 
 *  inputs:
 *    X     the system and initial conditions in MATLAB format (see convertode)
 *    t     the independent variable
 *    ignoreConstraints optional IgnoreAnlyticConstraints flag (default false)
 *  outputs: [cols,sys]
 *    cols  list of dep variables in solution
 *    sys   solution as a matrix. Each column is a dep variable. The order
 *          of the columns matches the order in the cols output. [] for no sol.
 */
symobj::dsolve := proc(X,t,ignoreConstraints)
option noExpose;
local out,sys,vars,cols,ignore;
begin
  if args(0)<3 then
    ignore := FALSE;
  else
    ignore := bool(ignoreConstraints = all);
  end_if:
  out := symobj::convertode(X,t);
  vars := out[1];
  sys := out[2];
  if nops(sys) < nops(vars) then
    vars := vars[1..nops(sys)];
  end_if:
  out := symobj::dsolveeqns(sys,vars,ignore);
  cols := out[1];
  sys := out[2];
  if sys::dom = DOM_NIL then
    sys := [];
  end_if:
  cols := symobj::map(cols,(z)->op(z,0)); // pick out fcn name
  [cols,symobj::checkFloatDigits(sys)];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Solves ODE given by eqns list with vars variable list. 
 *  inputs:
 *    eqns     the ODE and initial conditions in MuPAD format
 *    vars     the dependent variables in MuPAD format
 *    ignore   value for IgnoreAnalyticConstraints
 *  outputs: [res_lhs, res_rhs]
 *    res_lhs  list of dep variable names in solution or scalar if just one
 *    res_rhs  matrix of solutions. each column is a dep variable. the columns
 *             are ordered in the same order as res_lhs. or scalar if just one
 */
symobj::dsolveeqns := proc(eqns,vars,ignore)
option noExpose;
local res,res_lhs,res_rhs,de,opts;
begin
  if type(eqns) = Dom::Matrix() then
    eqns := [op(eqns)];
  end_if:
  if type(vars) = Dom::Matrix() then
    vars := [op(vars)];
  end_if:
  de := ode(numeric::rationalize(eqns),vars);
  if ignore then
    opts := IgnoreAnalyticConstraints;
  else
    opts := null();
  end_if:
  res := solve(de,opts);
  if type(res) = "solve" or type(res) = "ode" then
    res := NIL:
  elif type(res) = RootOf then
    res := RootOf::exact(res);
    if type(res) <> RootOf and nops(vars)=1 and length(eqns)>1 then
      eqns := select(eqns,(e)->not has(e,op(vars[1],1))); // select initial conds
      res := select(res,symobj::recheckSol,eqns,op(vars[1],0),op(vars[1],1));
    end_if:
  end_if:
  res := symobj::setToMatrix(res, FALSE);
  res := symobj::eqnsToSols(res, vars); 
  res_lhs := symobj::extractscalar(res[1]);
  res_rhs := symobj::extractscalar(res[2]);
  return([res_lhs, res_rhs]):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute eigenvalues in MATLAB format. RootOfs are expanded.
 *  inputs:
 *    A   the matrix
 *  outputs:
 *    a matrix with the eigenvalues along the diagonal
 */
symobj::eigenvalues := proc(A)
  local eigvals, res, extractelem, k, N;
begin
  extractelem := 
  proc(x)
    local next_item;
    begin
    if type(x)=Dom::Multiset and type(x[1]) = DOM_LIST then
      next_item := x[1];
    elif type(x)=DOM_SET then
      next_item := map(op(x),(y->[y,1]));
    else
      next_item := [x,1];
    end_if:
    res := append(res, next_item);
  end_proc:

  A := symobj::tomatrix(A);
  eigvals := symobj::removeRootOfs(linalg::eigenvalues(A,Multiple)):
  if type(eigvals) = piecewise then
    eigvals := Simplify(eigvals,Steps=2000); // TODO: why 2000?
    // if it still has piecewise then filter
    if type(eigvals) = piecewise then
      eigvals := symobj::filterPiecewise(eigvals);
    end_if:
  elif hastype(eigvals,RootOf) then
    N := linalg::nrows(A);
    eigvals := [eigvals[k]$k=1..N];
  end_if:
  if hastype(eigvals,DOM_SET) then
    res := [];
    map(eigvals, extractelem):
    eigvals := res;
  elif type(eigvals)=DOM_LIST and type(eigvals[1])<>DOM_LIST then
    eigvals:=map(eigvals,(x)->[x,1]);
  end_if:
  symobj::checkFloatDigits(symobj::multiplicities(matrix(eigvals))):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute eigenvectors in MATLAB format. RootOfs are expanded.
 *  inputs:
 *    A   the matrix
 *  outputs: [V, D, P]
 *    V   matrix of eigenvectors
 *    D   diagonal matrix of eigenvalues
 *    P   vector of indices such that A*V = V*D(P,P)
 */
symobj::eigenvectors := proc(A)
  local eigvecs, V, D, P, m, work, mgeo;
begin
  A := symobj::tomatrix(A);
  eigvecs := symobj::checkFloatDigits(symobj::removeRootOfs(linalg::eigenvectors(A))):
  if eigvecs = FAIL then
    error("symbolic:eig:NoExplicit#Unable to find explicit eigenvectors.");
  end_if:
  m := 0;
  V := [];
  D := [];
  P := [];
  work:=proc(item)
    local eigval, malg, mbasis, k, w;
    begin
    eigval := item[1];
    malg := item[2];
    mbasis := item[3];
    mgeo := nops(mbasis);
    for k from 1 to mgeo do
      V := [op(V), [op(mbasis[k])]];
    end_for;
    P := [op(P), (m+w)$w=1..mgeo];
    D := [op(D), eigval$w=1..malg];
    m := m + malg;
  end_proc:
  map(eigvecs,work);
  [linalg::transpose(matrix(V)), matrix(nops(D),nops(D),D,Diagonal), matrix(P)]:
end_proc:


// Copyright 2009-2010 The MathWorks, Inc.

/* Test equality of array elements in MATLAB order and return result as a string.
 *  inputs:
 *    a, b   the two objects to compare
 *  outputs:
 *    the shape vector followed by a string of "0" and "1" where true or false.
 */
symobj::eq := proc(a,b)
option hold;
local subproc,sz;
begin
  a := context(a);
  b := context(b);
  a := symobj::zip(a,b,symobj::equal2);
  sz := symobj::size(a);
  sz := expr2text(sz);
  subproc := proc(x) begin if x then "1" else "0" end_if: end_proc:
  a := symobj::flattenSymOrder(a);
  a := map(a,subproc);
  _concat(sz,op(a));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Split a matrix of equations into lhs and rhs. If the input is a scalar
 * then it is assumed to not be an equation.
 *  inputs:
 *    eqns     the matrix or scalar of solutions.
 *    var_list the solution names to use if eqns is a scalar
 *  outputs: [lhs, rhs]
 *    lhs      the solution names (from first row if eqns is a matrix)
 *    rhs      the solutions
 */
symobj::eqnsToSols := proc(eqns, var_list)
begin
  if eqns::dom::hasProp(Cat::Matrix) =TRUE 
      and nops(eqns) > 0 and type(eqns[1,1]) = "_equal" then
    [linalg::row(map(eqns,lhs),1), map(eqns,rhs)];
//    [map(eqns,lhs), map(eqns,rhs)];
  else
    [var_list, eqns];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Test equality of two scalar expressions. The second inputs is coerced
 * to the type of the first if needed for comparison.
 *  inputs:
 *    a, b   the two objects to compare
 *  outputs:
 *    TRUE or FALSE
 */
symobj::equal2 := proc(a,b)
local res;
begin
  if bool(a=undefined) or bool(b=undefined) then
    FALSE;
  else
    bool(a = b);
  end_if:
//  if not res then
//    b := coerce(b,domtype(a));
//    if b <> FAIL then
//      res := bool(a = b);
//    end_if:
//  end_if:
//  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Matrix exponential.
 *  inputs:
 *    x   the matrix
 *  outputs:
 *    e^x
 */
symobj::expm := proc(x)
local res;
begin
  x := symobj::tomatrix(x);
  if traperror((res := exp(x))) <> 0 then // TODO: investigate MaxSteps like in jordan
    res := matrix();
    warning("symbolic:expm:NotFound#Explicit matrix exponential could not be found.");
  end_if:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Serialize x to a string using the interface outputproc and
 * trimming the object if the depth is exceeded. Sums and products
 * may be trimmed, too.
 *  inputs:
 *    x     the expression to serialize
 *    depth desired max length of serialization
 *  outputs:
 *    the string form of x
 */
symobj::expr2text := proc(x,depth)
/*local n,m,lens,i,all;*/
begin
  if args(0) = 1 then
    depth := symobj::formatdepth;
  end_if:
/*
  n := 0; // todo: change to be based on x
  lens := map([op(x)],length);
  all := {0,op(lens)};
  while nops(all)>1 and (m:=max(all)) > depth and n < 10 do
    // replace the max length top operand with `...` which mupadmex turns 
    // into (...) - hyperlinks eventually to expand that part.
    all := all minus {m};    
    for i from 1 to nops(lens) do
      if lens[i] = m then
        x := subsop(x,i=`...`,Unsimplified);
        lens[i] := 0;
      end_if:
    end_for:
    n := n+1;
  end_while:
*/
  if type(x)=DOM_STRING then
    x;
  else
    expr2text(symobj::outputproc(x));
  end_if:
end_proc:

// simple version that does not not truncate
//symobj::expr2text := (x) -> expr2text(symobj::outputproc(x)):

// Copyright 2009-2010 The MathWorks, Inc.

/* Extracts solutions from an ImageSet object possibly expanding
 * RootOfs into floats. Might throw away information in the solution.
 *  inputs:
 *    res   the ImageSet
 *  outputs:
 *    the extracted solution
 */
symobj::extractImageSet:=proc(res)
option noExpose;
local zeroInSet;
begin
  zeroInSet := (x)->bool(is(0 in op(op(x,3))) = TRUE):
  if symobj::isImageRangeRorC(res) or not zeroInSet(res) then
     if hastype(op(res,3),RootOf) then
       float(res);
     else
       expr(res);
     end_if:
  else
     subs(expr(res),op(op(res,2))=0);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Extract scalar from 1-by-1 listy object.
 *  inputs:
 *   x    the object to check
 *  outputs:
 *   x or x[1] if x is 1-by-1
 */
symobj::extractscalar := proc(x)
begin
  if symobj::islisty(x) and nops(x)=1 then
    op(x,1);
  else
    x;
  end_if;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Filter out the leading assumption put on the answer for real, positive.
 *  inputs:
 *    res      the intersection to filter
 *  outputs:   [continue, sol]
 *    continue true if filtering was done
 *    sol      the filtered solution
 */
symobj::filterIntersection := proc(res)
option noExpose;
local isAssump,assump,s;
begin
  isAssump := (x)->bool(x=R_) or bool(x=Dom::Interval(0,infinity)) or bool(x=C_):
  if isAssump(res[1]) then
    // try mapping the assumption over the elements
    assump := res[1];
    s := res[2];
    if type(s)=Dom::Multiset then
      s := [expand(s)];
      res := select(s,(x)->is(x,assump)<>FALSE);
      [TRUE,res];
    else
      [TRUE,op(res,2)];
    end_if:
  elif type(res[1])=solvelib::VectorImageSet and _and(op(map(op(res[1],3),isAssump))) then
    [TRUE,op(res,2)];
  else
    [FALSE,res];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Filter lists for solutions. A sequence of matrices is catenated together.
 *  inputs: 
 *    res   the lisy
 *  outputs:
 *    the matrix or list of solutions
 */
symobj::filterList := proc(res)
option noExpose;
begin
  // if all the elements are matrices cat them together and transpose
  if nops(res) > 1 and _and(op(map(res,(x)->x::dom::hasProp(Cat::Matrix)=TRUE))) then
    linalg::transpose(linalg::concatMatrix(op(res)));
  else
    map(res,expr);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Filter a piecewise expression to get matrix of solutions.
 *  inputs:
 *    res      the piecewise to filter
 *  outputs:
 *    the filtered solution
 */
symobj::filterPiecewise := proc(x)
option noExpose;
local replacesets,x2;
begin
    replacesets := proc(x)
      begin
      if type(x) = Dom::ImageSet then
        expr(x);
      else
        x;
      end_if:
      end_proc:

    if type(x) = piecewise then
        x2 := piecewise::disregardPoints(x);
        if x2<>undefined then
           x := x2;
        end_if:
        if type(x) = piecewise and symobj::canfilter(x) then
          x:=piecewise::selectExpressions(x,
               proc(a)begin a<>{}; end_proc);
          x:=x[1];
         end_if;
    end_if:
    if type(x) = "_union" then
      x := [op(x)];
      x := map(x,(y)->replacesets(y));
    elif type(x) = DOM_SET then
      x := [op(x)];
      if nops([x]) = 0 then x := []; end_if:
    end_if:
    x:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert a union of solution sets into a matrix of solutions. Each solution 
 * is a row of the output matrix. Each column holds the solutions for a
 * particular variable. Assumes the type of res is "_union".
 *  inputs:
 *    res   the union
 *  outputs:
 *    the matrix of solutions
 */
symobj::filterUnion := proc(res)
option noExpose;
begin
  res := map([op(res)],symobj::setToMatrix,FALSE);
  if nops(res)>1 then
    res := linalg::stackMatrix(op(res));
  else
    res[1];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute the shape of result for subsref X(ind1,...)
 *  inputs:
 *   xdims   the size of X
 *   ind1    the first index
 *   lens    the shape computed from indices
 *   nin     nops(lens)
 *   nelout  numel of result
 *   vind1   the expanded first index
 *  output:
 *   the result shape vector
 */
symobj::finalShape := proc(xdims,ind1,lens,nin,nelout,vind1)
option noExpose;
local res,xv,rv;
begin
  if nin<>1 then
    symobj::collapsedims(lens);
  elif symobj::isColonIndex(ind1) then
    [nelout, 1];
  else
    if nops(ind1)>0 and type(op(ind1,1)) = DOM_BOOL then
      ind1 := vind1; // if a bool was used then use converted array
      if ind1=[] then // nothing was selected
        ind1 := matrix(0,0,[]);
      end_if:
    end_if:
    xv := symobj::isvector(xdims);
    res := symobj::size(ind1);
    rv := symobj::isvector(res);
    if xv<>0 and rv<>0 then
      if _mult(op(xdims)) <> 1 then 
        xdims[xv] := res[rv];
        res := xdims;
      else // in a scalar higher dims are collapsed
        res := symobj::collapsedims(res);
      end_if:
    end_if:
    res;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Find default symbols in S. see sym/findsym for more info.
 *  inputs:
 *    S   the expression to query
 *    n   the optional number of symbols to return
 *  outputs:
 *    list of symbols found
 */
symobj::findsym := proc(S,n)
local res;
begin
  res := symobj::indets(S);
  if args(0)=2 then
    res := sort(res,symobj::sortproc);
    if nops(res) > n then
      res := res[1..n];
    end_if:
    res;
  else
    sort(res);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Read value from file.
 *  inputs:
 *    fname  file name to read
 *  outputs:
 *    MATLAB-friendly value evaluated from file
 */

symobj::finput := proc(fname)
local res;
begin
  res := finput(fname);
  if bool(domtype(res) = DOM_NULL) then
      res := [];
  elif bool(type(res) = "_exprseq") then
      res := [res];
  else
      res := eval(res);
  end_if;
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Inverse of f(x). Assumes f and x are scalars.
 *  inputs:
 *    f   the expression to invert
 *    x   the free variable of x
 *  outputs
 *    the inverse expression
 */
symobj::finverse := proc(f,x)
  option noExpose;
  local res,maplist,i1,i2,msg,rlist,tmpy;
begin
  tmpy := genident();
  res := symobj::solve(f=tmpy,x); 
  msg := 0;
  // If msg = 0, res is the expression for the inverse as a function of x.
  // If msg = 1, no inverse was found.
  // If msg = 2, res wasn't unique (discards other values).
  if res[2] = FAIL then
    res := [];
    msg := 1;
  else
    res := res[2];
    if not symobj::islisty(res) then
      res := [res];
    end_if:
    if bool(nops(res) > 1) then
      msg := 2;
      // look for real solutions first, then shortest
      maplist := map(res,(ans)->not has(ans,I));
      rlist :=[];
      for i1 from 1 to nops(maplist) do
        if maplist[i1] then
          rlist := [op(rlist), op(res,i1)]; // take real sols
        end_if:
      end_for:
      if nops(rlist) = 0 then
        rlist := res; // if no real sols use originals
      end_if:
      res := symobj::shortest(rlist);
    else
      res := res[1];
    end_if:
    res := subs(res,tmpy=x);
    if not hastype(res,RootOf) then
      i1:=indets(f);
      i2:=indets(res);
      // if there are extra idents like 2*k*pi then try subing 0
      if nops(i1) <> nops(i2) then
         i1 := i2 minus i1;
         i1 := i1 minus Type::ConstantIdents;
         i1 := map([op(i1)],(item)->item=0); // TODO: check subs 0... try expandRootOf
         res := subs(res,i1);
      end_if:
    end_if:
  end_if:
  if msg=1 then
    warning("symbolic:sym:finverse:warnmsg1#finverse(".f.") cannot be found.");
    res := [];
  elif msg=2 then
    warning("symbolic:sym:finverse:warnmsg2#finverse(".f.") is not unique.");
  end_if:
  symobj::checkFloatDigits(res);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Make sure all unbound identifiers in input expression end with '_Var'.
 *  inputs:
 *    s    the expression to check
 *  outputs:
 *    the fixed expression
 */
symobj::fixupVar := proc(s)
option hold;
local t,str;
begin
    str := "".s;
    if not stringlib::contains(str,"_Var") then
      t := domtype(context(s));
      if t<>DOM_IDENT or bool(str="PI") then
        s := text2expr(str."_Var");
      end_if:
    end_if:
   s;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Join matrix rows and cols into one big matrix. Helper function for subs.
 *  inputs:
 *   obj  the obect to flatten
 *  outputs:
 *   the flattened object
 */
symobj::flatten := proc(obj)
local dim, rows;
begin
  if symobj::islisty(obj) and symobj::hasmatrix(obj) then
    if obj::dom::hasProp(Cat::Matrix) = TRUE then
      obj := symobj::tomatrix(obj);
      dim := linalg::matdim(obj);
      rows := linalg::row(obj,1..dim[1]);
      rows := map(rows,symobj::horzcat@op);
      obj := symobj::vertcat(op(rows));
    else
      obj := symobj::horzcat(op(obj));
    end_if:
  end_if:
  obj:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Flattens the array x into a list in MATLAB order (first dims first).
 *  inputs: 
 *    x   the object to flatten
 *  outputs:
 *    the flattened list
 */
symobj::flattenSymOrder := proc(x)
option noExpose;
local dims,n,y,ind,k;
begin
  x := symobj::toSymArray(x);
  dims := symobj::size(x);
  n := _mult(op(dims));
  y := [0$k=1..n];
  for k from 0 to n-1 do
    ind := symobj::fromSymIndex(k,dims);
    y[k+1] := x[op(ind)];
  end_for:
  y;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert to vpa.
 *  inputs:
 *    x   the expression to convert
 *    d   the optional precision (default DIGITS)
 *  outputs:
 *    the vpa
 */
symobj::float := proc(x,d)
save DIGITS;
begin
  if args(0)=2 then
    DIGITS := d;
  end_if:
  x := symobj::removeRootOfs(x):
  x := symobj::map(x,float):
  // TODO: look into using evalAt instead of subs
  subs(x,RD_NINF=-infinity,RD_INF=infinity,RD_NAN=undefined); // TODO: eval after all subs calls in symobj, might rid of simplifies.
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB's frac. */
symobj::frac := (x)->x-trunc(x):

// Copyright 2009-2010 The MathWorks, Inc.

/* Turn the (0 based) MATLAB index into a MuPAD position of an n-d array.
 *  inputs:
 *    k     the index to convert
 *    dims  shape of target array
 *  outputs:
 *    position as a list (1 based)
 */
symobj::fromSymIndex := proc(k,dims)
option noExpose;
local n,N,res;
begin
  N := nops(dims);
  res := [0$k=1..N];
  for n from 1 to N do
    res[n] := k mod dims[n];
    k := k div dims[n];
  end_for:
  map(res,(x)->x+1);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Numeric solve. First tries numeric::solve, then numeric::fsolve with a
 * few hard-coded starting points.
 *  inputs:
 *    eqns  the system to solve
 *    vars  the list of variables names in eqns
 *  outputs: [cols, sols]
 *    cols  the variable names in sols
 *    sols  matrix of solutions. Each column is a set of solutions for a
 *          variable. The order of cols gives the order of solutions in sols.
 */
symobj::fsolve := proc(eqns,vars)
local res;
begin
  eqns := symobj::tolist(eqns);
  res:=numeric::solve(eqns,vars):
  if res = {} or res = FAIL then
    res:=numeric::fsolve(eqns,vars):
  end_if:
  if res = FAIL then
    // if the first try failed try another starting point
    res:=numeric::fsolve(eqns,map(vars,(x)->(x=1))):
  end_if:
  if res = FAIL then
    [[],[]];
  else
    res := symobj::setToMatrix(res, FALSE);
    if linalg::ncols(res)=1 and linalg::nrows(res)>1 then
      res := linalg::transpose(res);
    end_if:
    symobj::eqnsToSols(res,vars); 
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB-style subs function.
 *  inputs:
 *    F   expression to sub into
 *    X   list of values to substsitute for
 *    Y   list of values to substsitute 
 *  outputs:
 *    the new expression
 */
symobj::fullsubs := proc(F,X,Y)
local shape, res, vars;
begin
  if nops(X)=1 and symobj::islisty(op(X)) then
    X := [op(op(X))];
  end_if:
  if nops(Y)=1 and symobj::islisty(op(Y)) then
    Y := op(Y);
  end_if:
  if nops(X)=1 and symobj::numel(F)=1 and nops(Y)>1 then
    X := op(X);
    res := symobj::map(Y,(y)->symobj::trysubs(F,X=y));
  else
    if symobj::islisty(Y) then
      Y := [op(Y)];
    end_if:
    // check for non-scalar Y
    shape := map(Y,(y)->bool(symobj::numel(y)=1));
    if _and(op(shape)) or symobj::numel(F)>1 then
      // all scalar Y or non-scalar F so subs directly
      vars := zip(X,Y,(a,b)->(a=b));
      if nops(vars)<>nops(Y) then
        error("symbolic:subs:InvalidY#Number of elements in NEW must match number in OLD");
      end_if:
      res := symobj::trysubs(F,vars);
    else
      // at least one non-scalar Y so use vectorized subs
      res := symobj::vectorizedsubs(F,X,Y);
    end_if:
  end_if:
  symobj::checkFloatDigits(symobj::flatten(res));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB's poly gcd.
 *  inputs:
 *    a,b   the polys
 *    x     the free var of a and b
 *  outputs:
 *
 */
symobj::gcdex := proc(a,b,x)
begin
  [gcdex(a,b,x)];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to generate::MATLAB for matlabFunction when making an
 * individual expression into MATLAB. The general output is of the
 * form 'reshape([list of elems],shape)' is the input is non-scalar.
 *  inputs:
 *    obj  the expression to act on
 *  outputs:
 *    a string with the generated code
 */
symobj::generateMATLAB := proc(obj)
local sz,str2,locgen,v,sep;
begin

  locgen := proc(x,sep)
  local str,head,tail;
  begin
    str := generate::MATLAB(x);
    // extract expression from inside str
    tail := length(str)-2;
    if type(x)="_equal" then
      head := strmatch(str,"t",Index);
      head := head[1];
    else
      head := strmatch(str,"=",Index);
      head := head[1]+2;
    end_if:
    str[head..tail] . sep;
  end_proc:

  if symobj::isempty(obj) then
    "[]";
  elif symobj::islisty(obj) then
    obj := symobj::toSymArray(obj);
    sz := symobj::size(obj);
    obj := symobj::flattenSymOrder(obj);
    v := symobj::isvector(sz);
    // check for horizontal or vertical vector.
    sep := ",";
    if v=1 then
      sep := ";";
    end_if:
    str2 := map(obj,locgen,sep);
    str2 := _concat(op(str2));
    str2 := str2[1..(length(str2)-1)];
    if v<>1 and v<>2 then
      // for arrays or matrices use reshape
      "reshape([" . str2 . "]," . expr2text(sz) . ")";
    else
      "[" . str2 . "]";
    end_if:
  else
    str2 := locgen(obj,",");
    str2[1..(length(str2)-1)];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Get list of identifiers foo of the form Dfoo or D123foo from the set X.
 *  inputs:
 *    X    the set of identifiers to search
 *  outputs:
 *    list of dependent variables
 */
symobj::getdepvars := proc(X)
option noExpose;
local res,x,str;
begin
  res := {};
  for x in X do 
    str := strmatch(expr2text(x),"^D\\d*(\\w+)$",ReturnMatches);
    if type(str)=DOM_LIST then
      res := res union {text2expr(str[2])};
    end_if:    
  end_for:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert a matrix of names into a sequence in MATLAB order.
 *  inputs:
 *    X  the matrix or expression
 *  outputs:
 *    the sequence of elements
 */
symobj::getvarnames := proc(X)
begin
  X := symobj::toSymArray(X);
  op(symobj::flattenSymOrder(X));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Check if A has a matrix element.
 *  inputs:
 *    A   the listy object to check
 *  outputs:
 *    true if A contains a matrix
 */
symobj::hasmatrix := proc(A)
local ismat;
begin
  ismat := (x) -> x::dom::hasProp(Cat::Matrix)=TRUE;
  bool(nops(select([op(A)],ismat)) > 0);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute the horner form of a polynomial in its default variable.
 *  inputs:
 *    p   the polynomial
 *  outputs:
 *    the expression
 */
symobj::horner := proc(p)
  local p2,x_var;
begin
  x_var := symobj::findsym(p,1);
  p2 := poly(p,x_var);
  if p2<>FAIL then
    p2(op(x_var));
  else
    p2;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Horizontal concatenation of inputs.
 *  inputs:
 *    varargin  the expressions to cat
 *  outputs:
 *    the concatenated object or [] if empty
 */
symobj::horzcat := proc()
local z;
begin
  if symobj::isNDArray(args()) then
    error("symbolic:ndarray#NDArray in horzcat or vertcat.");
  end_if: 
  z := map([args()],symobj::tomatrix);
  z := select(z,(x)->bool(nops(x)<>0));
  if nops(z) > 0 then
    linalg::concatMatrix(op(z));
  else
    [];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB interface to hypergeom. n and d are converted to a list.
 *  inputs:
 *    z    the argument
 *    n,d  parameters that are converted to lists
 *  outputs:
 *    the hypergeom output
 */
symobj::hypergeom := proc(z,n,d)
begin
  n := symobj::tolist(n):
  d := symobj::tolist(d):
  hypergeom(n,d,z);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Extended integer gcd as a list.
 *  inputs:
 *    a,b   the integers
 *  outputs:
 *    the list of results
 */
symobj::igcdex := proc(a,b)
begin
  [igcdex(a,b)];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Increment indexing vector in MuPAD order.
 *  inputs:
 *    pos    the index position vector to increment
 *    lens   the shape of the array being indexed
 *    nlen   nops(lens)
 *  outputs:
 *    the index vector for the next element in MuPAD order
 */
symobj::incInd := proc(pos,lens,nlen)
option noExpose;
local k;
begin
  k := nlen;
  while k > 0 do
    pos[k] := pos[k] + 1;
    if pos[k] > lens[k] then
      pos[k] := 1;
    else
      break;
    end_if:
    k := k-1;
  end_while:
  pos;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Get free variables not including constants.
 *  inputs:
 *    list  the object to check
 *  outputs:
 *    the list of indets
 */
symobj::indets := proc(list)
local res;
begin
  if symobj::islisty(list) then
    list = [op(list)];
  end_if:
  res := indets(list) minus Type::ConstantIdents;
  [op(res)]; // convert set to list
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to definite integration. Warns if an explicit integral wasn't found.
 *  inputs:
 *    f  the expression to integrate
 *    x  free variable of f
 *    a,b the limits of integration
 *  outputs:
 *    the integral
 */
symobj::intdef := proc(f,x,a,b)
begin
  symobj::checkIntFound(symobj::map(f,(g)->int(g,x=a..b)));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to indefinite integration. Warns if an explicit integral wasn't found.
 *  inputs:
 *    f  the expression to integrate
 *    x  free variable of f
 *  outputs:
 *    the integral
 */
symobj::intindef := proc(f,x)
begin
  symobj::checkIntFound(symobj::map(f,(g)->int(g,x)));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Invert matrix. If the input isn't a matrix it is converted to a matrix
 * or errors if not possible.
 *  inputs: 
 *    A   the matrix to invert
 *  outputs:
 *    the inverse.
 */
symobj::inv := proc(A)
local res,do_inverse;
begin
  A := symobj::tomatrix(A);
  do_inverse := proc()
  begin
    if nops(A)=1 then
      1/op(A,1);
    else
      simplify(_invert(A));
    end_if:
  end_proc:
  if traperror((res := do_inverse())) <> 0 then
    res := getlasterror();
    error("symbolic:sym:inv:errmsg1#" . res[2]);
  else
    symobj::checkFloatDigits(res);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Check if x is #COLON. Used by subscripting code to track indexing using
 * colons like x(:,1)=...
 *  inputs:
 *    x   the indexing expression to check
 *  outputs:
 *    true if x is #COLON
 */
symobj::isColonIndex := (x) -> type(x)=DOM_IDENT and bool(x = #COLON):

// Copyright 2009-2010 The MathWorks, Inc.

/* Test if x is an ImageSet over R or C.
 *  inputs:
 *    x   an ImageSet object
 */
symobj::isImageRangeRorC := (x)->op(x,3)=[R_] or op(x,3)=[C_]:

// Copyright 2010 The MathWorks, Inc.

/* Check for any n-dimensional arrays. Returns true if any of the inputs is an n-dim array (for n>2).
 *  inputs:
 *    varargin  the expressions to check
 *  outputs:
 *    true if any of the inputs are n-d.
 */
symobj::isNDArray := proc()
local z;
begin
    z := map([args()],(z)->nops(symobj::size(z)));
    bool(max(z)>2);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Test if x is empty in MATLAB sense.
 *  inputs:
 *   x  the object to test
 *  outputs:
 *   true if x has no elements
 */
symobj::isempty := proc(x)
begin
  if symobj::islisty(x) then
    bool(nops(x) = 0);
  else
    FALSE;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Implement MATLAB isequal. Inputs are held to allow sequences.
 *  inputs:
 *    a first object
 *    b second object
 *  outputs:
 *    TRUE or FALSE
 */
symobj::isequal := proc(a,b)
option noExpose;
option hold;
local sa,sb;
begin
  a := context(a);
  b := context(b);
  sa := symobj::size(a);
  sb := symobj::size(b);
  if sa=sb then
      if symobj::numel(a) = 0 then
        TRUE
      else
        a := symobj::zip(a,b,symobj::equal2);
        _and(op(a));
      end_if:
  else
    FALSE
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Test if x is list-like: matrix, array, set, list or sequence. The
 * MATLAB interface converts between listy types when needed to support
 * array sym objects.
 *  inputs
 *    x   the object to test
 *  outputs
 *    TRUE if it is list-like
 */
symobj::islisty := proc(x)
local t;
begin
   t := type(x);
   bool(x::dom::hasProp(Cat::Matrix) = TRUE or
        t = DOM_LIST or t = "_exprseq" or t = DOM_SET or
        t = DOM_ARRAY or t = DOM_HFARRAY);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Test for NaN of array elements in MATLAB order and return result as a string.
 *  inputs:
 *    x  the array to test
 *  outputs:
 *    the shape vector followed by a string of "0" and "1" where true or false.
 */
symobj::isnan := proc(x)
local subproc,sz,checknan;
begin
  x := symobj::toSymArray(x);
  x := symobj::map(x,(z)->bool(z=undefined)=TRUE);
  sz := symobj::size(x);
  sz := expr2text(sz);
  subproc := proc(x) begin if x then "1" else "0" end_if: end_proc:
  x := symobj::flattenSymOrder(x);
  x := map(x,subproc);
  _concat(sz,op(x));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Test for vector dimensions and return index of vector orientation.
 * Scalars are considered non-vectors.
 *  inputs:
 *    dims   the dimensions to check
 *  output
 *    the vector index or 0.
 */
symobj::isvector := proc(dims)
local k,j;
begin
  j := 0;
  for k from 1 to nops(dims) do
    if dims[k] <> 1 then
      if j <> 0 then 
        return(0);
      end_if:
      j := k;
    end_if:
  end_for:
  j;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB interface to jacobian.
 *  inputs:
 *    f  function expression
 *    v  variable list
 *  outputs:
 *    the jacobian
 */
symobj::jacobian := proc(f,v)
begin
  f:=symobj::tolist(f):
  v:=symobj::tolist(v):
  linalg::jacobian(f,v);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute Jordan form.
 *  inputs:
 *    A   the matrix
 *    arg flag to return transform matrix, too
 *  outputs: 
 *    same as MATLAB function
 */
symobj::jordan := proc(A,arg)
local res;
begin
  A := symobj::tomatrix(A);
  if (args(0) = 2) then
  // TODO: geck the examples that take forever to try to remove this traperror
    if traperror((res := linalg::jordanForm(A,All)),MaxSteps=50) <> 0 then
        error("symbolic:jordan:TooLarge#Similarity matrix too large."): 
    end_if:
    [res[2], res[1]];
  else
    linalg::jordanForm(A);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute limit of f wrt x at a in given direction
 *  inputs:
 *   f    expression 
 *   x    free variable
 *   a    point of limit
 *   dir  optional direction of limit
 *  outputs:
 *    the limit
 */
symobj::limit := proc(f,x,a,dir)
begin
  if type(f)=Factored then
   f := expr(f);
  end_if:
  if symobj::numel(x) > 1 then
   error("symbolic:sym:limit:errmsg1#Variable must be a scalar.")
  end_if:
  if symobj::numel(a) > 1 then
   error("symbolic:sym:limit:errmsg2t#Limit point must be a scalar.")
  end_if:
  x := symobj::extractscalar(x);
  a := symobj::extractscalar(a);
  if args(0) = 4 then
    symobj::checkFloatDigits(limit(f,x=a,dir));
  else
    symobj::checkFloatDigits(limit(f,x=a));
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

symobj::log10 := (x)->ln(x)/ln(10):

// Copyright 2009-2010 The MathWorks, Inc.
// TODO: look into 2 arg log because log(2^x,2) -> x, also using combine optionally
symobj::log2 := (x)->ln(x)/ln(2):

// Copyright 2009-2010 The MathWorks, Inc.

/* Map function over list or scalar. If x islisty then apply fcn to
 * each element of x otherwise apply fcn to x.
 *  inputs:
 *    x    the object to map over
 *    fcn  the function to apply
 *    varargin any trailing args are passed fcn after x
 *  outputs:
 *    the mapped list or scalar
 */
symobj::map := proc(x,fcn)
begin
  if symobj::islisty(x) then
    map(x,fcn,args(3..args(0)))
  else
    fcn(x,args(3..args(0)))
  end_if:
end_proc:
// Copyright 2009-2010 The MathWorks, Inc.

// Map fcn over x and check for float precision of output.
symobj::mapFloatCheck := symobj::checkFloatDigits @ symobj::map: 

// Copyright 2009-2010 The MathWorks, Inc.

/* Map fcn over x and insert val where fcn errored. x can be a scalar like in
 * map.
 *  inputs:
 *   x      the object to map over
 *   fcn    the function to apply
 *   val    the value to insert when fcn(x) errors
 *  outputs:
 *   the mapped list or scalar
 */
symobj::mapcatch := proc(x,fcn,val)
local trapfcn;
begin
  trapfcn := proc(x)
    local res,err;
    begin
      err := traperror((res := fcn(x)));
      if err = 1028 and stringlib::pos(op(getlasterror(),2),"Error: singularity") <> FAIL then
        res := val;
      elif err <> 0 then
        lasterror();
      end_if:
      symobj::checkFloatDigits(res);
    end_proc:
  if symobj::islisty(x) then
    map(x,trapfcn)
  else
    trapfcn(x)
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Port of MATLAB's logic to resize an empty array to the right-hand-side
 * of an indexed assignment statement.
 *  inputs:
 *    prhs    right-hand-side array
 *    scalar  true if performing scalar expansion assignment
 *    vinds   indexing data (see subsasgn)
 */
symobj::matchAndResizeIndicesToRHSDimensions := proc(prhs,scalar,vinds)
option noExpose;
local doAss,scalarCase,lens,j,k,rdim,matchNonSingletonLHS,
 matchColonLHS,fillColonLHS;
begin
  scalarCase := proc(ind)
  begin
    if bool(ind[2]=NULL) then // colon
      ind := [1,[1],1,0];
    end_if:
    ind;
  end_proc:

  matchNonSingletonLHS := proc()
  local d,j2;
  begin
    j := 1;
    for k from 1 to nops(lens) do
      while lens[j] = 1 do 
        j := j+1;
      end_while:
      if vinds[j][2] = NULL then
        d := rdim[k];
        vinds[j] := [d,[j2$j2=1..d],-1];
      elif lens[j] <> rdim[k] then
        symobj::subsasgnDimError();
      end_if:        
      j := j+1;
    end_for:
  end_proc:

  matchColonLHS := proc()
  local allColons,nrdim,fun;
  begin
    nrdim := nops(rdim);
    allColons := _and(op(map(vinds,(x)->bool(x[2]=NULL))), nrdim<=nops(lens));
    j := 0;
    fun := proc(r)
    begin
      if r<>1 or allColons then
        rdim[j+1] := r;
        j := j+1;
        if r=0 then
          doAss := FALSE;
        end_if:
      end_if:
    end_proc:
    map(rdim,fun);
    rdim := rdim[1..j];
    nrdim := j;
    // line 1011 in assignmt.cpp
    if nrdim > nops(vinds) then
      if nops(vinds) > 1 then      
        symobj::subsasgnDimError();
      end_if:
      rdim := [_mult(op(rdim))];
    end_if:
    fillColonLHS();
  end_proc:  

  fillColonLHS := proc()
  local nrdim,i,j,nvinds;
  begin
    nrdim := nops(rdim);
    nvinds := nops(vinds);
    j:=0;
    for i from 1 to nrdim do
      while j<nvinds and lens[j+1]=1 do
        j := j+1;
      end_while:
      if j=nvinds then
        symobj::subsasgnDimError();
      end_if:
      j := j+1;
      if bool(vinds[j][2]=NULL) then
        vinds[j][3] := rdim[i]; // set new length
        vinds[j][1] := rdim[i]; // set new max
      elif lens[j]<>rdim[i] then
        symobj::subsasgnDimError();
      end_if:
    end_for:
    while j<nvinds and (vinds[j+1][3]=1 or vinds[j+1][2]=NULL) do
      j := j+1;
      vinds[j][3] := 1;
      if vinds[j][2]=NULL then
        vinds[j][1] := 1;
      end_if:
    end_while:
    if j<>nvinds then
      symobj::subsasgnDimError();
    end_if:
  end_proc:

  doAss := TRUE;
  rdim := symobj::size(prhs);
  if scalar then
    vinds := map(vinds,scalarCase);
  else
    lens := map(vinds,(x)->x[1]);
    j := 0;
    for k from 1 to nops(lens) do
      if lens[k]=1 then j:=j+1; end_if;
    end_for:
    if j = nops(rdim) then
      matchNonSingletonLHS();
    else
      matchColonLHS();
    end_if:
  end_if:
  [doAss, vinds];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Construct matrix in alternate form as MuPAD's constructor.
 *  inputs:
 *    items    list of elements
 *    nrows,ncols  shape
 *  outputs:
 *    the matrix
 */
symobj::matrix := proc(items,nrows,ncols)
begin
  matrix(nrows,ncols,items);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert a matrix to an array.
 *  inputs:
 *    x  the matrix
 *  outputs:
 *    the array form of x
 */
symobj::matrixToArray := proc(x)
begin
  if x::dom::hasProp(Cat::Matrix) = TRUE then
    x := expr(x);
  end_if:
  x;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Matrix left divide a and b.
 *  inputs:
 *    a,b  items to divide
 *  outputs:
 *    a\b
 */
symobj::mldivide:=proc(a,b)
local bdim, X, res, rk,warn1,warn2, na;
begin
  na := symobj::numel(a);
  if na=1 then
    a := symobj::extractscalar(a);
    res := symobj::map(b,symobj::divide,a);
  else
    // try to convert a and b to matrices
    a := symobj::tomatrix(a);
    b := symobj::tomatrix(b);
    warn1 := FALSE;
    warn2 := FALSE;
    bdim := linalg::matdim(b);
    // vectorize over columns of b
    res := matrix(linalg::ncols(a),0);
    for rk from 1 to bdim[2] do
      X := linalg::matlinsolve(a,linalg::col(b,rk));// TODO: matlinsolve over all of b at once? check for pseudo inverse in linalg?
      if (type(X) = DOM_LIST) then
        if (X = []) then
          res := matrix(linalg::ncols(a),linalg::ncols(b),infinity);
          if not warn1 then
            warning("symbolic:sym:mldivide:warnmsg1#System is inconsistent. Solution does not exist.");
            warn1 := TRUE;
          end_if:
        else
          if nops(X[2]) > 0 and not warn2 then
            warning("symbolic:sym:mldivide:warnmsg2#System is rank deficient. Solution is not unique.");
            warn2:=TRUE;
          end_if:
          res := linalg::concatMatrix(res,X[1]);
        end_if:
      else
        res := linalg::concatMatrix(res,X);
      end_if:
    end_for:
    res := simplify(res);
  end_if:
  res;
end_proc:


// Copyright 2009-2010 The MathWorks, Inc.

/* MuPAD's modp mapped over polynomial coeffs.
 *  inputs:
 *    x  the poly expression
 *    m  the modulus
 *  outputs:
 *    the expression result
 */
symobj::modp := proc(x,m)
  local p,v;
begin
  v := symobj::findsym(x,1);
  if nops(v)>0 then
    p := poly(x,v);
    expr(mapcoeffs(p,modp,m));
  else
    modp(x,m);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Matrix power a^p. One of a or p must be a scalar.
 *  inputs:
 *   a  base object
 *   p  exponent object
 *  outputs:
 *    a^p
 */
symobj::mpower := proc(a,p)
local na, np;
begin
  na := symobj::numel(a);  np := symobj::numel(p);
  if na=1 and np=1 then
    a^p;
  elif na=1 and np>1 then
    // Scalar base
    p := symobj::tomatrix(p);
    exp(ln(a)*p);
  elif na>1 and np=1 then
    // Scalar exponent
    a := symobj::tomatrix(a);
    a^p;
  else
    error("symbolic:sym:mpower:errmsg4#Either base or exponent must be a scalar.");
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Matrix right division.
 *  inputs:
 *    a,b  the expressions
 *  outputs:
 *    a/b
 */
symobj::mrdivide:=proc(a,b)
local nb;
begin
  nb := symobj::numel(b);
  if nb=1 then
    b := symobj::extractscalar(b);
    symobj::map(a,symobj::divide,b);
  else
    a := linalg::transpose(symobj::tomatrix(a));
    b := linalg::transpose(symobj::tomatrix(b));
    linalg::transpose(symobj::mldivide(b,a));
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Matrix multiply a*b. If a and b are scalars they are expanded. Otherwise
 * a and b are converted to matrices.
 *  inputs:
 *   a,b  objects to multiply
 *  outputs:
 *    a*b
 */
symobj::mtimes := proc(a,b)
local na, nb;
begin
  na := symobj::numel(a);  nb := symobj::numel(b);
  if na=1 or nb=1 then
    symobj::scalarop(a,b,_mult,na,nb);
  else
    // try to convert a and b to matrices
    a := symobj::tomatrix(a);
    b := symobj::tomatrix(b);
    symobj::extractscalar(_mult(a,b));
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Expand an n-by-2 matrix of [val, mult] into a column vector.
 *  inputs:
 *    A  matrix to convert
 *  outputs:
 *    column vector of values
 */
symobj::multiplicities := proc(A)
local res, fcn, dims;
begin
  res := [];
  dims := linalg::matdim(A);
  fcn := proc(x) begin res:=append(res,x[1,1]$x[1,2]); x; end_proc:
  map(linalg::row(A,1..dims[1]),fcn);
  matrix(res);
end_proc:

//   Copyright 2009-2010 The MathWorks, Inc.

/* mwcos2sin(s) replaces cos(E)^2 by (1-sin(E)^2) and cosh(E)^2 by (1+sinh(E)^2)
 *  inputs:
 *    x   the expression to check
 *  outputs:
 *    the rewritten x
 */
symobj::mwcos2sin := proc(x)
begin
  x := rewrite(x,sin); // TODO: this is too much
  x := rewrite(x,sinh);// TODO: this is too much
  rewrite(x,sincos); 
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Nullspace as a matrix.
 *  inputs:
 *    A  the matrix
 *  outputs:
 *    the nullspace as a matrix
 */
symobj::nullspace := proc(A)
local basis;
begin
  A := symobj::tomatrix(A);
  basis := linalg::nullspace(A):
  if nops(basis) <> 0 then
    basis := linalg::concatMatrix(op(basis));
  end_if:
  basis;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.


/* MATLAB-like numden */
symobj::numden := proc(x)
local res,n,d,mynorm;
begin
    mynorm := proc(t)
    begin
        // TODO: replace with normal(t,List) except watch for DOM_RAT which
        // does not get split by normal.
        [numer(t), denom(t)];
    end_proc:
    if symobj::islisty(x) then
        res := symobj::map(x,mynorm);
        n := symobj::map(res,(elem)->elem[1]);
        d := symobj::map(res,(elem)->elem[2]);
        [n, d];
    else
        mynorm(x);
    end_if:

end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Number of elements of a MuPAD object as considered from MATLAB interface.
 * listy objects have multiple elements. Scalars have 1.
 *  inputs:
 *    x  the object
 *  outputs:
 *    integer
 */
symobj::numel := proc(x)
begin
  if symobj::islisty(x) then
    nops(x);
  else
    1;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to generate::optimize without intermediate names.
 *  inputs:
 *    x    the expression or list of expressions to optimize
 *  outputs:
 *    the list of assignment statements and final expression
 */
symobj::optimize := proc(x)
local out;
begin
  out := symobj::optimizeWithIntermediates(x);
  append(out[1],out[2]);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to generate::optimize.
 *  inputs:
 *    varargin  list of expressions or arrays to optimize
 *  outputs: [intDefns, f, ints]
 *    intDefns  list of optimized intermediates. 
 *    f         list of original expressions in terms of the intermediates.
 *    ints      list of names of intermediate variables
 */
symobj::optimizeWithIntermediates := proc()
local locproc, temps, x, f;
begin
   locproc := proc(y)
   begin  
     if type(y)=Dom::Matrix() then
       y := (Dom::Matrix())::convert_to(y,DOM_ARRAY);
     end_if:
     y;
   end_proc:

  x := array(1..args(0),[args()]);
  // convert list elements to arrays if needed
  x := map(x,locproc);
  x := generate::optimize(x);
  // now x is a list of equations. the last equation the rhs is
  // an array of answers. non-scalar answers are arrays.
  // turn surrounding array into a list.
  f := x[nops(x)];
  x := x[1..nops(x)-1];
  f := [op(rhs(f))];
  temps := map(x,lhs);
  [x, f, temps];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Output procedure for MuPAD objects displayed by MATLAB.
 */
symobj::outputproc := proc()
  local res;
begin
  if length(args())<100000 and traperror((res := ((MathContent::expr)@MathContent)(args()))) = 0 then
    res
  else
    args()
  end_if
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert a list of coefficients into a poly expression.
 *  inputs:
 *    c   list of coeffs
 *    x   free variable
 *  outputs:
 *    an expression for the poly 
 */
symobj::poly2sym := proc(c,x)
local k,expon;
begin
  if not symobj::islisty(c) then
    c := [c];
  else
    c := symobj::flattenSymOrder(c);
  end_if:
//  expon := revert([k$k=0..(nops(c)-1)]);
//  c := zip(c, expon, (a,b)->[a,b]);
  c := revert(c);
  _plus((c[k+1]*x^k)$k=0..(nops(c)-1));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Pretty print.
 *  inputs:
 *    s   the expression to pretty print
 *    n   width of screen in characters
 *  outputs:
 *    the string for printing
 */
symobj::pretty := proc(s,n)
  save PRETTYPRINT, TEXTWIDTH;
begin
  TEXTWIDTH := n;
  PRETTYPRINT := TRUE;
  // we need to explicitly replace Vars so that pretty-printing gets
  // the right spacing around the variable name
  s := symobj::replaceVar(s);
  print(symobj::outputproc(s));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute MATLAB prod or sum.
 *  inputs:
 *    a  array to act upon
 *    f  function to apply
 *  outputs:
 *   computed value
 */
symobj::prodsum := proc(a,f)
local res,sz;
begin
  if symobj::islisty(a) then
    a := symobj::tomatrix(a);
    sz := symobj::size(a);
    if sz[1]=1 or sz[2]=1 then
      res := f(op(a));
    else
      res := symobj::prodsumdim(a,1,f);
    end_if:
  else
    res := a;
  end_if:
  simplify(res);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute prod or sum along dimension n.
 *  inputs:
 *    a   the array to act upon
 *    n   dimension to collapse
 *    f   function to apply
 *  outputs:
 *    computed value
 */
symobj::prodsumdim := proc(a,n,f)
local res, sz, items, vfcn;
begin
  vfcn := (a)->f(op(a));
  if symobj::islisty(a) then // TODO: check for ndim array?
    sz := symobj::size(a);
    if n = 1 then
      items := linalg::col(a,1..sz[2]);
      items := map(items,vfcn);
      res := matrix(1,sz[2],items);
    else
      items := linalg::row(a,1..sz[1]);
      items := map(items,vfcn);
      res := matrix(sz[1],1,items);
    end_if
  else
    res := a;
  end_if:
  simplify(res); // TODO: simpilfy twice? look in prodsum.mu
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB quorem.
 *  inputs:
 *    a,b  values for quotien/remainder
 *    x    optional free variable for polys
 *  outputs: [quo, rem]
 *    quo  quotient
 *    rem  remainder
 */
symobj::quorem2 := proc(a,b,x)
begin
  if (args(0) = 3) then
    [ divide(a,b,[x]) ];
  else
    [_div(a,b), _mod(a,b)];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB vectorized integer quorem.
 *  inputs:
 *    a,b  values for quotien/remainder
 *  outputs: [quo, rem]
 *    quo  quotient
 *    rem  remainder
 */
symobj::quoremInt := proc(a,b)
local la,lb,res;
begin
  la := symobj::islisty(a);
  lb := symobj::islisty(b);
  if la and lb then
    res := zip(a,b,symobj::quorem2);
  elif la then
    res := map(a,symobj::quorem2,b);
  elif lb then
    res := map(b,(x,y)->symobj::quorem2(y,x),a);
  else
    res := symobj::quorem2(a,b);
  end_if:
  if la or lb then 
     //[[a,a],[b,b]] -> ...
    [map(res,(L)->L[1]), map(res,(L)->L[2])];
  else
    res;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB vectorized polynomial quorem.
 *  inputs:
 *    a,b  values for quotien/remainder
 *    x    free variable
 *  outputs: [quo, rem]
 *    quo  quotient
 *    rem  remainder
 */
symobj::quoremPoly := proc(a,b,x)
local la,lb,res;
begin
  la := symobj::islisty(a);
  lb := symobj::islisty(b);
  if la and lb then
    res := zip(a,b,symobj::quorem2,x);
  elif la then
    res := map(a,symobj::quorem2,b,x);
  elif lb then
    res := map(b,(A,B)->symobj::quorem2(B,A,x),a);
  else
    res := symobj::quorem2(a,b,x);
  end_if:
  if la or lb then
    [map(res,(L)->L[1]), map(res,(L)->L[2])];
  else
    res;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute rank of a matrix.
 *  inputs:
 *    A   the matrix
 *  outputs:
 *    the rank
 */
symobj::rank := proc(A)
begin
  A := symobj::tomatrix(A);
  linalg::rank(A);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Read value from file. It is read and returned.
 *  inputs:
 *    file   file name
 *  outputs:
 *    the value in the file
 */
symobj::read := proc(file)
local res;
begin
  res := finput(file);
  normal(eval(res));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Verify candidate solution is a solution of the given ODE.
 *  inputs:
 *    sol    the solution to check
 *    eqns   ODE eqns to plug into
 *    yvar   free variable in eqns
 *    xvar   free variable in sol
 */
symobj::recheckSol:=proc(sol,eqns,yvar,xvar)
local fun,res1,res;
begin
  fun := fp::unapply(sol,xvar);
  res1 := map(eqns,(e)->evalAt(e,yvar=fun));
  res := map(res1,(e)->bool(symobj::dsimplify(e)));
  res := _and(op(res));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Expand RootOfs or approximate by float values. If the expansion is
 * a set then it is converted into a list.
 *  inputs:
 *    X   the expression to check
 *  outputs:
 *    the expanded result
 */
symobj::removeRootOfs := proc(X)
option noExpose;
begin
  if (hastype(X,RootOf)) then
    X := simplify(RootOf::exact(X)):
    if (hastype(X,RootOf)) then
      X := float(X);
    end_if:
  end_if:
  if type(X)=DOM_SET then
    X:=[op(X)];
  end_if:
  X:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Replace foo_Var identifiers with foo.
 *  inputs:
 *    s   the expression to convert
 *  outputs:
 *    the unevaluated converted expression
 */
symobj::replaceVar := proc(s)
local tryreplace;
begin
  tryreplace := proc(id) local str;
  begin
    str := "".id;
    if stringlib::contains(str,"_Var") then
      text2expr(str[1..length(str)-4]);
    else
      id;
    end_if:
  end_proc:
  misc::maprec(s,{DOM_IDENT}=tryreplace,Unsimplified);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Reshape x like MATLAB reshape command. Scalars are left as scalars.
 *  inputs:
 *    x   the object to reshape
 *    varargin either a single input of the target shape or list of dims
 *  outputs:
 *    the reshaped array
 */
symobj::reshape := proc(x)
local lens,total,empty,k,z;
begin
  if args(0)=2 then
    lens := args(2);
  else
    total := 1;
    lens := [args(2..args(0))];
    empty := 0;
    for k from 1 to nops(lens) do
      z := lens[k];
      if type(z)=DOM_IDENT and bool(z = #COLON) then
        empty := k;
      else
        total := total*z;
      end_if:
    end_for:
    if empty<>0 then
      lens[empty] := symobj::numel(x)/total;
    end_if;
  end_if:
  symobj::reshapeknown(x,lens);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Reshapes x to specified shape. product of lens must be numel(x).
 *  inputs
 *    x     the object to reshape
 *    lens  the new shape
 *  outputs
 *    the reshaped object
 */
symobj::reshapeknown := proc(x,lens)
local k,xdims,val,y,N;
begin
  x := symobj::toSymArray(x);
  N := nops(x)-1;
  if N+1 <> _mult(op(lens)) then
    error("symbolic:reshape:BadShape#New shape must have the same number of elements as the old shape.");
  end_if:
  xdims := symobj::size(x);
  y := symobj::symArray(lens);
  for k from 0 to N do
    val := x[op(symobj::fromSymIndex(k,xdims))];
    y[op(symobj::fromSymIndex(k,lens))] := val;
  end_for:
  symobj::extractscalar(y);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB round.
 */
symobj::round := proc(x)
begin
  if bool(x<0) then
    -round(-x);
  else
    round(x);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Row reduce.
 *  inputs:
 *    A  matrix to reduce
 *  outputs:
 *    row reduced matrix
 */
symobj::rref := proc(A)
local res;
begin
  A := symobj::tomatrix(A);
  if nops(A)=1 then
    if bool(A=0) then
      res := 0;
    else
      res := 1;
    end_if:
  else
    res := symobj::gaussJordan(A);
  end_if:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Vectorize a scalar binary op.
 *  inputs:
 *    a,b    the inputs to op
 *    fcn    function to apply
 *    na,nb  numel in a,b
 *  outputs:
 *    vectorized result of fcn(a,b)
 */
symobj::scalarop := proc(a,b,fcn,na,nb)
begin
  a := symobj::extractscalar(a);
  b := symobj::extractscalar(b);
  if na=1 and nb=1 then
    fcn(a,b);
  elif na=1 then
    map(b,(x)->fcn(a,x));
  else
    map(a,(x)->fcn(x,b));
  end_if
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Turns a "set" output from MuPAD into a MATLAB matrix of solutions.
 * Each solution is a row of the output matrix.
 *  inputs:
 *    res  object to transform
 *    checkSolve flag to only transform if res does not contain a 'solve'.
 *  output:
 *    the matrix of solutions or FAIL if no explicit sols
 */ 
symobj::setToMatrix := proc(res,checkSolve)
option noExpose;
  local again,res1;
begin
  if checkSolve then
    again := not has(res,solve);
  else
    again := TRUE;
  end_if;
  while again do
//  print(type(res));
    case type(res)
      of Dom::Matrix() do
        res := linalg::transpose(res);
        again := FALSE;
        break;
      of Dom::ImageSet do
      of solvelib::VectorImageSet do
        res := symobj::extractImageSet(res);
        break;
      of "_in" do
        res := op(res,2);
        // longterm, return condition as assumption if possible eg k in Z_
        break;
      of "_minus" do
        res := op(res,1);
        break;
      of "_exprseq" do
        res := symobj::filterList([res]);
        again := FALSE;
        break;
      of "_union" do
        res := symobj::filterUnion(res);
        again := FALSE;
        break;
      of "_intersect" do
        [again,res] := symobj::filterIntersection(res);
        break;
      of piecewise do
        res := symobj::filterPiecewise(res);
        break;
      of Dom::Multiset do
        res := [expand(res)];
        again := FALSE;
        break;
      of RootOf do
        res1 := float(res);
        if type(res1)=RootOf then
          again := FALSE;
        else
          res := res1;
        end_if:
        break;
      otherwise
        again := FALSE;
    end_case:
  end_while:
  // now build matrix of results
  if type(res)=DOM_SET then // transform set to list
     res := sort([op(res)],(x,y)->bool(length(x)<length(y)));
     res := map(res,symobj::tolist); // also transform vectors to lists
  elif type(res)="_exprseq" then
     res := [res];
  end_if:
  if checkSolve and has(res,solve) then
    res := FAIL;
  elif type(res)<>Dom::Matrix() and type(res)<>DOM_LIST then
    res := matrix([[res]]):
  elif type(res) <> Dom::Matrix() then
    res := matrix(res):
  end_if:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Get the "shortest" elements of a list, defined by length()
 *  inputs:
 *    objs  list of objects
 *  output:
 *    the shortest elem in list
 */
symobj::shortest := proc(objs)
local res,i,maplist,shortest_len;
begin
  maplist := map(objs,length);
  shortest_len := infinity;
  for i from 1 to nops(maplist) do
    if maplist[i] < shortest_len then
      res := op(objs,i);
      shortest_len := maplist[i];
    end_if:
  end_for:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Helper function for simple.m that determines if x is more simple than y.
 * Uses traditional toolbox definition of length of string form.
 *  inputs:
 *    x,y  the objects to compare
 *  output:
 *    true if x is simpler than y
 */
symobj::simpler := proc(x,y)
begin
    if bool(type(x)=DOM_FAIL) then
      FALSE;
    else
      bool(length(expr2text(x)) < length(expr2text(y)));
    end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Vectorized interface to Simplify.
 *  inputs:
 *     x  the object to simplify
 *     n  Steps (default 50)
 *  outputs:
 *     simplified result
 */
symobj::simplify := proc(x,n=50)
begin
  symobj::mapFloatCheck(x,Simplify,Steps=n):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute MATLAB size (shape) of an object. see size.m for details.
 *  inputs:
 *    x  the object to query
 *  outputs:
 *    the list of dimensions of x
 */
symobj::size := proc(x)
local dims;
begin
  if x::dom::hasProp(Cat::Matrix) =TRUE then
   linalg::matdim(x);
  elif type(x) = DOM_ARRAY or type(x)=DOM_HFARRAY then
    dims := op(x,0);
    dims := dims[2..nops(dims)];
    if type(dims) = "_exprseq" then
      dims := [map(dims,(pair)->op(pair,2))];
    else
      dims := [op(dims,2)];
    end_if:
  elif type(x) = DOM_LIST or type(x) = DOM_SET then
   [1, nops(x)];
  else
   [1, 1];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Solve system symbolically. 
 *  inputs:
 *    func   the system to solve
 *    var    the variable(s) to solve for
 *  outputs: [cols, sols]
 *    cols   the variable list var giving the order of sols
 *    sols   the solution matrix. The columns are ordered by cols.
 */
symobj::solve := proc(func,var)
option noExpose;
  local res,opts;
begin
  if func::dom::hasProp(Cat::Matrix) = TRUE then
    func := [op(func)];
  elif bool(type(func) <> DOM_EXPR) then
    func := expr(func):
  end_if:
  opts := MaxDegree=3,IgnoreSpecialCases,VectorFormat;
  // first try as a polynomial with Multiple
  var := symobj::extractscalar(var);
  if traperror((res := solve(func,var,opts,Multiple))) <> 0 then
    // if that failed then just try as general expr
    if traperror((res := solve(func,var,opts))) <> 0 then
      return([[],[]]);
    end_if:
  end_if:
  if bool(res = {}) then
      return([[],#NO_SOLUTION]);
  end_if:
  res := symobj::setToMatrix(res,TRUE);
  res := symobj::eqnsToSols(res,var); 
  if res[2]<>FAIL then
    res[2] := symobj::sortSols(res[2]);
  end_if:
  res[2] := symobj::extractscalar(res[2]);
  res:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Full interface for MATLAB solve.
 *  inputs:
 *    eqns   the equations
 *    vars   free variables to solve for
 *  outputs: [order, R]
 *    order  the column names of result matrix R
 *    R      matrix of solutions
 */
symobj::solvefull := proc(eqns,vars)
option noExpose;
local neqns,nvars,str, out, order, R, inds;
begin
  neqns := nops(eqns);
  if nops(vars)=0 then
    vars := symobj::findsym(eqns,neqns);
  end_if:
  nvars := nops(vars);
  [vars,inds] := symobj::sort(vars);
  vars := [op(vars)];
  if neqns < nvars then
    str := "symbolic:solve:TooFewVars#".neqns." equations in ".nvars." variables. New variables might be introduced.";
    warning(str);
  elif neqns <> nvars then
    str := "symbolic:solve:TooManyVars#".neqns." equations in ".nvars." variables.";
   warning(str);
  end_if:
  out := symobj::solve(eqns,vars);
  order := out[1];
  R := out[2];
  if R=FAIL then
    R := [];
  elif R = #NO_SOLUTION then
    return( [order,[]] );
  end_if:
  if nops(R)=0 and nvars = neqns and nvars = nops(symobj::findsym(eqns)) then
    out := symobj::fsolve(eqns,vars);
    order := out[1];
    R := out[2];
  end_if:
  [order, symobj::checkFloatDigits(R)];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Sort elements
 *  inputs:
 *    x     the array to sort
 *    sdim  the dimension to sort over or Auto
 *    mode  TRUE=ascend, FALSE=descend
 *    outputIndices  TRUE=return indices, otherwise indices are empty
 *  outputs:
 *    y     the sorted array
 *    inds  the indices such that y=x(inds).
 */
symobj::sort := proc(x,sdim,mode,outputIndices)
local dims,inds,sortWithIndices,indsort,doSort,myorder,
getsdim,prepAndSort,k;
begin 
  if args(0) = 1 then
      sdim := Auto;
      mode := TRUE;
      outputIndices := FALSE;
  end_if:
  if mode then
      myorder := sysorder;
  else
      myorder := _not @ sysorder;
  end_if:

  indsort := proc(a,b)
  begin 
    _lazy_and(myorder(a[1],b[1]), _lazy_or(not myorder(b[1],a[1]),a[2]<b[2]));
  end_proc:

  // sort the list y and return the index permutation in the second output
  sortWithIndices := proc(y) 
  local z,k;
  begin
    z := zip(y,[k$k=1..nops(y)],(a,b)->[a,b]);
    z := sort(z,indsort);
    [map(z,(a)->a[1]), map(z,(a)->a[2])];
  end_proc:

  // get the default dimension to sort over
  getsdim := proc() 
  begin
      if symobj::isvector(dims)<>0 then
        // vector case  
        sdim := symobj::isvector(dims);
      else
        // sdim is first non-scalar
        for k from 1 to nops(dims) do
          if dims[k] > 0 then
            sdim := k;
              break;
          end_if:
        end_for
      end_if:    
  end_proc:

  // sort the array x
  doSort := proc() 
    local n,col,indcol;
  begin
    if sdim=2 then // transpose
      x := linalg::transpose(x);
      dims := [dims[2],dims[1]];
    end_if:
    if outputIndices then
        inds := symobj::symArray(dims);
    end_if:
    for n from 1 to dims[2] do
      col := [op(linalg::col(x,n))]; 
      if outputIndices then
         [col,indcol] := sortWithIndices(col);
         inds := linalg::setCol(inds,n,indcol);
      else
         col := sort(col,myorder);
      end_if:
      x := linalg::setCol(x,n,col);
    end_for:
    if sdim=2 then // transpose
      x := linalg::transpose(x);
      if nops(inds)>1 then
        inds := linalg::transpose(inds);
      end_if:
    end_if:
  end_proc:

  // prepare the sorting dimension, the input x and do the sort
  prepAndSort := proc()
  begin
    x := symobj::toSymArray(x);
    dims := symobj::size(x);
    // figure out the stride dimension to sort over
    if bool(sdim = Auto) then
      getsdim();
    end_if:
    // now sdim is the dimension to step along to sort.
    // create a list from the sdim slices, sort each one
    // and put the contents back into x (and inds if desired).
    if nops(dims) > 2 then
      error("symbolic:sym:sort:NDNotSupported#symbolic sort is only supported for vectors and matrices");
    end_if:
    doSort();
    x := symobj::extractscalar(x);
  end_proc:

  inds := 1;
  // first check for scalar and empty case
  if symobj::islisty(x) then
    if symobj::numel(x) = 0 then
      inds := [];
    else
      prepAndSort();
    end_if:
  end_if:
  [x, inds];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Sort matrix of solutions by the rows by the first column so that real 
 * solutions are on top.
 *  inputs:
 *    res  the matrix of solutions
 *  outputs:
 *    sorted solution matrix
 */
symobj::sortSols := proc(res)
option noExpose;
local imag,real,i,dims;
begin
  dims := linalg::matdim(res);
  real := matrix(0,dims[2]);
  imag := matrix(0,dims[2]);
  for i from 1 to dims[1] do
    if has(res[i,1],I) then
      imag := linalg::stackMatrix(imag,linalg::row(res,i));
    else
      real := linalg::stackMatrix(real,linalg::row(res,i));
    end_if:
  end_for:
  linalg::stackMatrix(real,imag);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Sort procedure to sort identifiers according to findsym style.
 *  inputs:
 *    x,y  names to compare
 *  outputs:
 *    true if x<y in findsym order
 */
symobj::sortproc:=proc(x,y)
local x1, y1, order, indx, indy;
begin
  x:=expr2text(x);
  y:=expr2text(y);
  // compare first char closest-to-x. rest normally
  x1 := x[1];
  y1 := y[1];
  if (bool(x1 = y1)) then
    bool(x<y);
  else
    // x y w z v ... 
    order := "xywzvutsrqponmlkjihgfedcbaXYWZVUTSRQPONMLKJIHGFEDCBA_";
    indx := stringlib::pos(order,x1);
    indy := stringlib::pos(order,y1);
    bool(indx < indy);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Apply a function to A as matrix. Errors if A is an array.
 *  inputs:
 *    A    expression to evaluate
 *    fcn  function to apply
 *  outputs:
 *    result
 */
symobj::specialscalarcase := proc(A,fcn)
begin
  A := symobj::tomatrix(A);
  A := fcn(A);
  symobj::extractscalar(A):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

// TODO: replace with subexpression extraction in MuPAD
// output::subexpr

/* Search for a "good" subexpression X to extract from S to get S2
 * by using generate::optimize and looking for a split that results
 * in the minimum len(X)+len(S2). If that doesn't produce a smaller
 * split use the subexpr that minimizes abs(len(S2)-len(X)).
 *  inputs:
 *    x        expression to split
 *    signame  substitution name for the subexpression
 *  outputs: [s2, subexpr]
 *    s2       expression with subexpr factored out
 *    subexpr  the subexpression
 */
symobj::subexpr := proc(x,signame)
option noExpose;
  local s,sr,Y,tdiff,Ydiff,sigmadiff,rest,
        sum2,rest2,sigma2,diff2,Y2,sigma,k, lenY,lensigma,
        bestSigma, bestY, bestSum;
begin
  s := symobj::matrixToArray(x);
  s := generate::optimize(s); // TODO: geck array vs matrix? check
  if nops(s) < 2 then
    return([x,NULL]):
  end_if;
  sr := revert(s);
  Y := rhs(sr[1]);
  sigma := NULL;
  bestSigma := NULL;
  tdiff := infinity;
  Ydiff := Y;
  sigmadiff := NULL;
  bestSum := infinity;
  rest := sr[2 .. nops(sr)];
  for k from 1 to nops(rest) do
    sigma2 := rest[k];
    rest2 := select(rest,x->x<>rest[k]);
    Y2 := subs(Y,op(rest2));
    sigma2 := subs(sigma2,op(rest2));
    lenY:=length(Y2);
    lensigma:=length(sigma2);
    sum2 := lenY+lensigma;
    if (sum2 < bestSum) then
      bestSigma := sigma2;
      bestY := Y2;
      bestSum := sum2;
    end_if;
    diff2:=abs(lenY-lensigma);
    if (diff2 < tdiff) then
      sigmadiff := sigma2;
      Ydiff := Y2;
      tdiff := diff2;
    end_if;
  end_for:
  if (bestSigma=NULL) then 
    s := [Ydiff, sigmadiff];
  else 
    s := [bestY,bestSigma]; 
  end_if;
  k := lhs(s[2]);
  [subs(s[1],k=signame), rhs(s[2])];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* General indexed assignment X(I1,I2,...,In) = Y
 *  inputs:
 *   x     the LHS object
 *   y     the RHS object
 *   varargin the indices I1, I2, ...
 *  outputs:
 *   the new value for x
 */
symobj::subsasgn := proc(x,y)
option noExpose;
local inds,  // indexing inputs I1,I2,...
      nin,   // nops(inds)
      wdims, // working dimensions
      xdims, // dimensions of x 
      ydims, // dimensions of y
      vinds, // vectors of integer indices
      lens,  // lengths of vinds
      ny, allZero, doAss, doAss1, resize;
begin
  x := symobj::toSymArray(x);
  if symobj::islisty(y) then
    y := symobj::toSymArray(y);
    ny := nops(y);
    ydims := symobj::size(y);
  else
    ydims := [];
    ny := 1;
  end_if;
  xdims := symobj::size(x);
  inds := [args(3..args(0))];
  nin := nops(inds);
  doAss := TRUE;
  allZero := _and(op(map(xdims,(x)->bool(x=0))));
  [wdims,vinds,doAss1,resize] := symobj::ConvertSubsasgn(xdims,inds,nin,y,ny,allZero);
  doAss := doAss and doAss1;
  if ny = 0 then
    if resize=TRUE then 
      // cannot grow during delete
      error("symbolic:subsassignDimMismatch#Subscripted assignment dimension mismatch");
    end_if:
    return( symobj::subsdelete(x,xdims,vinds,wdims) );
  end_if:
  if resize=TRUE then
    [x, xdims] := symobj::subsgrow(x,xdims,wdims,allZero);
  end_if:
  if not doAss then
    return( x );
  end_if:
  lens := map(vinds,(x)->x[3]);
  vinds := map(vinds,(x)->x[2]);
  ny := _mult(op(lens));
  symobj::copydata(x,xdims,y,ydims,ny,vinds,lens,TRUE);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Error with a standard subsasgn error.
 */
symobj::subsasgnDimError := proc()
begin
  error("symbolic:subsassignDimMismatch#Subscripted assignment dimension mismatch");
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Deletes slices from array according to MATLAB indexing rules.
 *  inputs:
 *    x      the array to delete from
 *    xdims  shape of x
 *    vinds  the indexing data (see subsasgn)
 *    wdims  the working dimensions (see subsasgn)
 *  outputs:
 *    the new array with the specified slices missing
 */
symobj::subsdelete := proc(x,xdims,vinds,wdims)
option noExpose;
local invertIndex, lens, nelout, finalShape, res;
begin

  invertIndex := proc(ind,ldim)
  local count,k,elems;
  begin
    if bool(ind[2] = NULL) then
      // was colon, keep it
      return(ind);
    end_if:
    count := [k$k=1..ldim];
    elems := ind[2]; 
    for k from 1 to nops(elems) do
      count[op(elems,k)] := 0;
    end_for:
    ind[2] := select(count,(x)->x>0);
    ind[3] := nops(ind[2]);
    ind;
  end_proc:

  // check that vinds are valid
  symobj::checkDeleteIndices(vinds);
  lens := map(vinds,(x)->x[3]);

  if _mult(op(lens)) = 0 then
    // nothing to delete
    return( x );
  end_if;
  if _and(op(map(vinds,(x)->bool(x[2]=NULL)))) then
    // all colons - return empty
    return( matrix(0,0,[]) );
  end_if:

  // invert the dimension along which the indexing is non-trivial
  vinds := zip(vinds,wdims,invertIndex);

  lens := map(vinds,(x)->x[3]);
  vinds := map(vinds,(x)->x[2]);
  nelout := _mult(op(lens));
  finalShape := symobj::finalShape(xdims,vinds[1],lens,nops(vinds),nelout,vinds[1]);
  res := symobj::symArray(finalShape);
  symobj::copydata(res,finalShape,x,xdims,nelout,vinds,lens,FALSE);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Grow an array during subscript assignment.
 *  inputs:
 *    x      the array to grow
 *    xdims  shape of x
 *    wdims  working dimensions of assignment
 *    allZero true if the shape is all zeros
 *  outputs: [y,wdims]
 *    y      the grown array (with zeros filled in)
 *    wdims  new working dimensions
 */
symobj::subsgrow := proc(x,xdims,wdims,allZero)
option noExpose;
local k,y,nx,vinds,ny,xv,items;
begin
  ny := _mult(op(wdims));
  if nops(wdims) = 1 then
    if allZero then
      wdims := [1,ny];
    else
      xv := symobj::isvector(xdims);
      if xv = 0 then
        wdims := [1,ny];
      else
        wdims := xdims;
        wdims[xv] := ny;
      end_if:
    end_if:
  end_if:
  items := [0 $ k= 1 .. ny];
  if allZero then
    y := symobj::symArray(wdims,items);
  else
    y := symobj::symArray(wdims,items);
    nx := _mult(op(xdims));
    vinds := map(xdims,(n)->[k$k=1..n]);
    y := symobj::copydata(y,wdims,x,xdims,nx,vinds,xdims,FALSE);
  end_if:
  [y,wdims];
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* General indexing X(I1,I2,...,In). If the result is a scalar it is
 * extracted from any matrix or array.
 *  inputs:
 *    x        the expression to index
 *    varargin the indices I1, I2,...
 *  outputs:
 *    the subscripted expression
 */
symobj::subsref := proc(x)
option noExpose;
local inds,  // indexing inputs I1,I2,...
      nin,   // nops(inds)
      wdims, // working dimensions
      xdims, // dimensions of x 
      vinds, // vector of integer indices
      lens,  // lengths of vinds
      finalShape,  // shape of result
      nelout,      // numel of result
      res;
begin
  // TODO: profile in MuPAD with integer index
  x := symobj::toSymArray(x);
  xdims := symobj::size(x);
  inds := [args(2..args(0))];
  nin := nops(inds);
  wdims := symobj::GetWorkingDimensions(nin,xdims);
  vinds := symobj::ConvertSubsref(inds,nin,wdims);
  lens := map(vinds,(x)->x[3]); // pick out lengths
  vinds := map(vinds,(x)->x[2]); // pick out indexing vectors
  nelout := _mult(op(lens));
  finalShape := symobj::finalShape(xdims,inds[1],lens,nin,nelout,vinds[1]);
  res := symobj::symArray(finalShape);
  if nelout > 0 then
    res := symobj::copydata(res,finalShape,x,xdims,nelout,vinds,lens,FALSE);
  end_if:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute numeric singular values of A. A is allowed to be a scalar.
 *  inputs:
 *    A    the matrix
 *  outputs:
 *    the list of singular values
 */
symobj::svdvals := proc(A)
local siz,B,ev;
begin 
  A := symobj::tomatrix(A);
  siz := linalg::matdim(A);
  if siz[1] < siz[2] then
    B := A*linalg::htranspose(A);
  else
    B := linalg::htranspose(A)*A;
  end_if:
  ev := symobj::eigenvalues(B);
  map(ev,sqrt);
end_proc:


// Copyright 2009-2010 The MathWorks, Inc.

/* Compute numeric singular values and vectors like the MATLAB command.
 * A is allowed to be a scalar.
 *  inputs:
 *    A    the matrix
 *  outputs: [U,S,V]
 *    U,V  unitary matrices
 *    S    diagonal matrix storing the singular values
 */
symobj::svdvecs := proc(A)
local res;
begin
  A := symobj::tomatrix(A);
  A := symobj::float(A);
  res := numeric::svd(A);
  res[2] := matrix(nops(res[2]),nops(res[2]),res[2],Diagonal);
  symobj::checkFloatDigits(res):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Get expanded coeffs of poly.
 *  inputs:
 *    p   the poly
 *    x   free variable of p
 *  outputs:
 *    matrix of coefficients of p or FAIL
 */
symobj::sym2poly := proc(p,x)
  local k;
begin
  p := poly(p,[x]):
  if (p <> FAIL) then
    p := [coeff(p,x,k)$k=degree(p)..0 step -1];
    matrix(p):
  else
    p;
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Create matrix or array with given shape. If the items are not
 * given 0 is used. Items are in MuPAD order if given.
 *  inputs:
 *   dims   shape of result. a single scalar [n] becomes [n,1] matrix.
 *   items  list of elements of resulting matrix or array.
 *  output
 *   the constructed matrix or array
 */
symobj::symArray := proc(dims,items)
begin
  if nops(dims)=1 then
    if args(0)=1 then
      matrix(op(dims,1),1):
    else
      matrix(op(dims,1),1,items):
    end_if:
  elif nops(dims)=2 then
    if args(0)=1 then
      matrix(op(dims)):
    else
      matrix(op(dims),items):
    end_if:
  else
    if args(0)=1 then
      items := [0 $ _mult(op(dims))];
    end_if:
    dims := map(dims,(x)->1..x);
    array(op(dims),items);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.


/* Sum in a MATLAB-like syntax */
symobj::symsum := (f,x,a,b)->sum(f,x=a..b):

// Copyright 2009-2010 The MathWorks, Inc.

/* Wrapper for MATLAB-like transform function like fourier, etc.
 *  inputs:
 *    tform     the transform to apply
 *    fcn       expression to transform
 *    varin     default input variable
 *    varout    default output variable
 *    varalt    default alternate variable
 *    varargin  input variables from user
 *  outputs:
 *    transformed expression
 */
symobj::symtransform := proc(tform,fcn,varin,varout,varalt)
local vargs,var,res,nargs,stest;
begin
  if args(0)>5 then
    vargs := [args(6..args(0))];
  else
    vargs := [];
  end_if:
  if contains(symobj::findsym(fcn),varin)<>0 then
    var := varin;
  else
    var := symobj::findsym(fcn,1);
    if var=[] then
      var := varin;
    else
      var := var[1];
    end_if:
  end_if:
  stest := bool(var=varout);
  nargs := nops(vargs);
  if nargs=0 then
    if stest then
      res := [var, varalt];
    else
      res := [var, varout];
    end_if:
  elif nargs=1 then
    res := [var, vargs[1]];
  elif nargs=2 then
    res := [vargs[1], vargs[2]];
  end_if:
  symobj::checkFloatDigits((tform)(fcn,op(res)));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Find symbols in input. See findsym for more info.
 */
symobj::symvar := proc()
begin
  symobj::extractscalar( symobj::findsym(args()) );
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Implement taylor that converts to builtin DOM_POLY type.
 * Avoids the problem of sending the order term back to MATLAB.
 *  inputs:
 *    f   expression
 *    x   free variable
 *    a   point of expansion
 *    n   order
 *  outputs:
 *    taylor expansion as expr
 */
symobj::taylor := proc(f,x,a,n)
begin
  expr(taylor(f,x=a,n,AbsoluteOrder)):
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert expression to an array or matrix. Listy things are put into a 
 * matrix as elements.
 *  inputs:
 *    a   expression to convert.
 *  outputs:
 *    converted value which is DOM_ARRAY, DOM_HFARRAY or hasProp Cat::Matrix
 */
symobj::toSymArray:=proc(a)
local b,t;
begin
  t := type(a);
  if t = DOM_LIST or t = DOM_SET then
      a := matrix([[op(a)]]);
  elif t <> DOM_ARRAY and t <> DOM_HFARRAY and a::dom::hasProp(Cat::Matrix) <> TRUE then
    b := coerce(a,Dom::Matrix());
    if b = FAIL or b = undefined then
      b := matrix([[a]]);
    end_if:
    a := b;
  end_if:
  a:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute the MATLAB index of a position (eg 1,2,1 -> 13) xprods are 
 * the partial products of the xdims array.
 *  inputs:
 *    pos   position in an array
 *    prods partial products of shape of target array
 *  outputs:
 *    integer base 0 in MATLAB order of the position
 */
symobj::toSymIndex := proc(pos,prods)
begin
  pos := map(pos,(x)->x-1);
  _plus(op(zip(pos,prods,_mult)));
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert to list. If x is not listy it is wrapped in a list.
 *  inputs
 *    x    the object to convert
 *  outputs
 *    the list
 */
symobj::tolist := proc(x)
local dims,v;
begin
  if symobj::islisty(x) then
     dims := symobj::size(x);
     v := symobj::isvector(dims);
     if v=0 then
       x := symobj::flattenSymOrder(x):
     end_if:
     [op(x)];
  else
     [x]:
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Convert expression to a matrix. Lists, exprseqs and sets are converted
 * to row matrices. 2-by-2 arrays are converted but other sized arrays error.
 * Other expressions are coerced or wrapped in a 1-by-1 matrix.
 *  inputs:
 *    a  the expression to convert.
 *  outputs:
 *    the resulting matrix.
 */
symobj::tomatrix:=proc(a)
local b,dims,t;
begin
  t := type(a);
  if t = DOM_LIST or t = DOM_SET then
      a := matrix([[op(a)]]);
  elif t = DOM_ARRAY or t = DOM_HFARRAY then
    dims := symobj::size(a);
    if nops(dims)<>2 then
      error("symbolic:InputsMustBe2D#Input arguments must be 2-D.");
    end_if:
    a := coerce(a,Dom::Matrix());
  elif a::dom::hasProp(Cat::Matrix) <> TRUE then
    b := coerce(a,Dom::Matrix());
    if b = FAIL or b = undefined then
      b := matrix([[a]]);
    end_if:
    a := b;
  end_if:
  a:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Transpose.
 *  inputs
 *    A   the matrix to transpose
 *  outputs
 *    A.'
 */
symobj::transpose := proc(A)
begin
  symobj::specialscalarcase(A,linalg::transpose);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB-like lower triangular matrix
 *  inputs:
 *    X       matrix or vector
 *    offset  off-diagonal offset
 *  outputs:
 *    new matrix
 */
symobj::tril := proc(X,offset)
begin
  X := symobj::tomatrix(X);
  X - symobj::triu(X,offset+1); // TODO: infinities? inf-inf etc
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* MATLAB-like upper triangular matrix
 *  inputs:
 *    X       matrix or vector
 *    offset  off-diagonal offset
 *  outputs:
 *    new matrix
 */
symobj::triu := proc(X,off)
local sz,m,n,absoff,lenx,Y;
begin
  X := symobj::tomatrix(X);
  sz := symobj::size(X);
  Y := matrix(sz[1],sz[2]);
  lenx := max(op(sz));
  absoff := abs(off);
  for m from 1 to lenx-absoff do
    for n from m+absoff to lenx do
      Y[m,n] := indexval(X,m,n);
    end_for:
  end_for:
  if off < 0 then
    for m from 1 to lenx do
      for n from max(1,m+off) to min(lenx,m-off-1) do
        Y[m,n] := indexval(X,m,n);
      end_for:
    end_for:
  end_if:
  Y;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Interface to subs that catches singularity errors.
 *  inputs:
 *    obj  object to subs into
 *    var  expression x=y
 *  outputs:
 *    new value
 */
symobj::trysubs := proc(obj,var)
local res,err;
begin
  err := traperror((res := eval(subs(obj,var))));
  if err = 1028 and stringlib::pos(op(getlasterror(),2),"Error: singularity") <> FAIL then
    res := undefined;
  elif err <> 0 then
    lasterror();
  end_if:
  res;
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Compute unique items in x. If x is not listy then it is returned unchanged.
 * Items are returned as a column vector if x islisty unless x is a row.
 * Items are sorted.
 * vector.
 *  inputs:
 *    x  the object to uniquify
 *  outputs: 
 *    the unique items in x
 */
symobj::unique := proc(x)
local dims,res;
begin
  if symobj::islisty(x) then
    x := symobj::toSymArray(x);
    dims := symobj::size(x);
    if symobj::isvector(dims)=2 then  // row vector
      res := coerce({ op(x) }, DOM_LIST);
      matrix(1,nops(res),sort(res));
    else
      matrix(sort([op( { op(x) } ) ]));
    end_if:
  else
    x;
  end
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Vectorized subs. Scalar F and X can be expanded to the size of Y.
 *  inputs:
 *    F  expression to sub into
 *    X  list of names or expressions
 *    Y  values to subs
 *  outputs:
 *    new value
 */
symobj::vectorizedsubs := proc(F,X,Y)
local items,k,len,lens,shape,nonscalar,vars,getitem,Ys;
begin
  shape := map(Y,(y)->symobj::size(y));
  lens := map(shape,(y)->_mult(op(y)));
  nonscalar := select(shape, (y)->(_mult(op(y)) > 1) );
  if length(nonscalar)>1 then
    // make sure all the nonscalar shapes are the same
    if nops({op(nonscalar)}) > 1 then
      error("symbolic:subs:InvalidValueShape#NEW arrays must be scalar or the same shape.");
    end_if:
  end_if:
  len := max(op(lens));
  items := [0$k=1..len];
  getitem := proc(_y,_len,_k)
  begin
    if (_len > 1) then
      op(_y,k);
    else
      _y;
    end_if:
  end_proc:
  for k from 1 to len do
    Ys := zip(Y,lens,(_y,_len)->getitem(_y,_len,k));
    vars := zip(X,Ys,(a,b)->(a=b));
    if nops(vars)<>nops(Ys) then
      error("symbolic:subs:InvalidY#Number of elements in NEW must match number in OLD");
    end_if:
    items[k] := symobj::trysubs(F,vars);
  end_for:
  symobj::symArray(nonscalar[1],items);
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* Vertical concatenation of inputs.
 *  inputs:
 *    varargin  the expressions to cat
 *  outputs:
 *    the concatenated object or [] if empty
 */
symobj::vertcat := proc()
local z;
begin
  if symobj::isNDArray(args()) then
    error("symbolic:ndarray#NDArray in horzcat or vertcat.");
  end_if: 
  z := map([args()],symobj::tomatrix);
  z := select(z,(x)->bool(nops(x)<>0));
  if nops(z) > 0 then
    linalg::stackMatrix(op(z));
  else
    [];
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

// Zeta function with swapped inputs.
symobj::zeta := proc(n,z) 
begin
  if args(0)=2 then
    zeta(z,n);
  else
    zeta(n);
  end_if:
end_proc:

// Copyright 2009-2010 The MathWorks, Inc.

/* zip fcn(a,b) with scalar expansion in a or b. Nonscalars must have same
 * shape.
 *  inputs:
 *    a,b   objects to zip together
 *    fcn   function to apply
 *  outputs:
 *    zipped output
 */
symobj::zip := proc(a,b,fcn)
local na, nb;
begin
  na := symobj::numel(a);  nb := symobj::numel(b);
  if na=1 or nb=1 then
    symobj::scalarop(a,b,fcn,na,nb);
  elif na<>nb then
    error("symbolic:ArraySizeMismatch#Array sizes must match.");
  else
    a := symobj::toSymArray(a);
    b := symobj::toSymArray(b);
    na := symobj::size(a);
    if na <> symobj::size(b) then
      error("symbolic:ArraySizeMismatch#Array sizes must match.");
    end_if;
    a := [op(a)];
    b := [op(b)];
    a := zip(a,b,fcn);
    symobj::symArray(na,a);
  end_if:
end_proc:
// Normalize fourier and ifourier to match backwards compatibility
symobj::fourier := (f,x,y)->subs(transform::fourier(f,x,y), y = -y, EvalChanges):
symobj::ifourier := (f,x,y)->subs(transform::invfourier(f,x,y), y = -y, EvalChanges):
symobj::gaussJordan := linalg::gaussJordan @ symobj::tomatrix:
symobj::formatdepth := infinity:
symobj::expint := (x) -> -Ei(-x):

protect(symobj, ProtectLevelError):

// protect constants from overwriting by the user
protect(NULL, ProtectLevelError):

// explicitly declare variables which are used globally
prog::setcheckglobals(symobj,
                      {i, eps, eps_Var}):

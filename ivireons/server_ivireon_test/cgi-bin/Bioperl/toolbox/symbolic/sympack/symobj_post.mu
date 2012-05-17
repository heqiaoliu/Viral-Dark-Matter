//   Copyright 2009-2010 The MathWorks, Inc.

// custom aliases and top-level definitions

DIGITS := 32:
// TODO: float inf/nan?
alias(Inf=infinity, pi=PI, i=I, NaN=undefined):
alias(besselj=besselJ, bessely=besselY);
alias(besseli=besselI, besselk=besselK);
alias(log=ln);
alias(fix=trunc, factorial=fact);
alias(asin=arcsin, acos=arccos, atan=arctan);
alias(asinh=arcsinh, acosh=arccosh, atanh=arctanh);
alias(acsc=arccsc, asec=arcsec, acot=arccot);
alias(acsch=arccsch, asech=arcsech, acoth=arccoth);
alias(sinint=Si, cosint=Ci);
alias(lambertw=lambertW);
alias(eulergamma=EULER, conj=conjugate, catalan=CATALAN);

// set upper bound on matrix display to be really big
matrix::setPrintMaxSize(infinity):

// fourier/ifourier uses a different defn that MATLAB so we can't alias it.
alias(laplace=transform::laplace);
alias(ilaplace=transform::invlaplace);
alias(ztrans=transform::ztrans);
alias(iztrans=transform::invztrans);

Pref::output(symobj::outputproc):
TEXTWIDTH := 1000:

alias(expint=symobj::expint);

// define dirac(0)=infinity
unprotect(dirac): dirac(0) := infinity:
dirac(float(0)) := RD_INF: protect(dirac,%3): // TODO: geck help update?

// redefine the display of psi and zeta to reverse the inputs
unprotect(psi):
psi := subsop(psi,2=proc(x)begin "psi(".expr2text(op(revert([op(x)]))).")";end):
protect(psi):
unprotect(zeta):
zeta := subsop(zeta,2=proc(x)begin "zeta(".expr2text(op(revert([op(x)]))).")";end):
protect(zeta):

// return value of reading this file, should always be null():
null():
// --------- end of file symobj.mu ---------

MMG( info = "Module: calculate factorial" )

/********************************************************************/
/* Module implementation of numfuncs::factorial.  It is completely  */
/* broken for results larger than a C long.  See correcponding test */
/* file in demePack1/lib/NUMFUNCS/TEST/factorial.tst .              */
/********************************************************************/

long fact(long i);

/********************************************************************/
/* modulefact:  calulate the factorial of a non-negative integer    */
/********************************************************************/

MFUNC(modulefact, MCnop)
{
  // one argument expected
  MFnargsCheck(1);

  if(MFisInt(MFarg(1))) {
    long value = MFlong(MFarg(1));
    if (value > 0) 
      MFreturn(MFlong(fact(value)));
  } 

  MFreturn(MFcopy(MVargs));
} MFEND

/********************************************************************/
/*  fact:  utility function, calculate factorial as a C long        */
/********************************************************************/
long fact(long i)
{
  return ((i== 1) ? 1 : i*fact(i-1));
}

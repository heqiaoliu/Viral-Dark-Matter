/* Copyright 2008-2009 The MathWorks, Inc. */

#include "mex.h"
#include "matrix.h"

/*
 * This mex-function needs to be complied before it can be used on your cluster
 * To compile this to executable code within MATLAB you will need to ensure that
 * you carry out the following steps on a machine running the same Operating System
 * as your cluster machines
 *
 * 1. Ensure that the mex compiler has been setup 
 *         mex -setup
 * 
 * 2. mex randRA.cpp
 *
 * For more help type 'help mex' at the MATLAB command prompt
 *
 */

/*
 * randRA( initState, 'setstate' ) 
 * is used to do setup - it assumes that ALL inputs are uint64. The initial
 * state of the RNG is initState 
 *
 * r = randRA( N )
 * generates N results from the RNG and returns them in the output r
 */

#define PERIOD 1317624576693539401L
/* typedef needed to compile HPCC_starts as taken from the hpcc utility code */
typedef uint64_T u64Int;
typedef int64_T s64Int;

uint64_T ZERO64B = 0L;
uint64_T POLY = 7L;
uint64_T BIT64 = static_cast< uint64_T >( 1 ) << 63;
uint64_T lastR;

/* 
 * Utility routine to start random number generator at Nth step - taken from
 * hpcc-1.2.0/RandomAccess/utilities.c. This generates the n'th random element 
 * in the RNG
 */
u64Int HPCC_starts(s64Int n)
{
  int i, j;
  u64Int m2[64];
  u64Int temp, ran;

  while (n < 0) n += PERIOD;
  while (n > PERIOD) n -= PERIOD;
  if (n == 0) return 0x1;

  temp = 0x1;
  for (i=0; i<64; i++) {
    m2[i] = temp;
    temp = (temp << 1) ^ ((s64Int) temp < 0 ? POLY : 0);
    temp = (temp << 1) ^ ((s64Int) temp < 0 ? POLY : 0);
  }

  for (i=62; i>=0; i--)
    if ((n >> i) & 1)
      break;

  ran = 0x2;
  while (i > 0) {
    temp = 0;
    for (j=0; j<64; j++)
      if ((ran >> j) & 1)
        temp ^= m2[j];
    ran = temp;
    i -= 1;
    if ((n >> i) & 1)
      ran = (ran << 1) ^ ((s64Int) ran < 0 ? POLY : 0);
  }

  return ran;
}

void mexFunction( int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[] ) {    
    /* If we are just initializing the RNG then only set it's state and return */
    if ( nrhs > 1 ) {
        lastR = HPCC_starts( static_cast< int64_T >( *mxGetPr( prhs[0] ) ) );
        return;
    }
    /* How many random numbers have we been asked to calculate? */
    int N = static_cast< int >( *mxGetPr( prhs[0] ) );
    /* 
     * Make a uint64 real vector of length N to return the output in, and
     * get a pointer to the beginning of that array so we can fill it in.
     */
    plhs[0]      = mxCreateNumericMatrix( 1, N, mxUINT64_CLASS, mxREAL );
    uint64_T * r = static_cast< uint64_T * >( mxGetData( plhs[0] ) );
    /* Loop and calculate the random numbers */
    for ( int i = 0; i < N; ++i ) {
        *r++ = lastR;
        lastR = ( lastR << 1 ) ^ ( lastR & BIT64 ? POLY : ZERO64B);
    }
}

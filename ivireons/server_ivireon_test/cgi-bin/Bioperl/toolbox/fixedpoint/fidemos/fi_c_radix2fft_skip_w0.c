/**
    FI_C_RADIX2FFT_SKIP_W0 Fixed-Point radix 2 FFT, skipping multiply by W^0.

    Y = fi_radix2fft_skip_w0(X, W, Wfractionlength) computes a radix
    2, fixed-point FFT of int16 input X with int16 twiddle factors W
    with scaling after each section, skipping the multiply by W^0=1.

    Wfractionlength is the fraction-length of W.

    Y is the int16 FFT of X.

    See also fi_m_radix2fft_withscaling.m, fi_c_radix2fft_withscaling.h,
             fi_m_radix2fft_skip_w0.m, fi_c_radix2fft_skip_w0.c,
             fi_m_radix2fft_blockfloatingpoint.m, fi_c_radix2fft_blockfloatingpoint.c

    To compile:

      mex fi_c_radix2fft_skip_w0.c

    Example:

      n = 64;                                     % Number of points
      Fs = 4;                                     % Sampling frequency in Hz
      t  = (0:(n-1))/Fs;                          % Time vector
      f  = linspace(0,Fs,n);                      % Frequency vector
      f0 = .2; f1 = .5;                           % Frequencies, in Hz
      x0 = cos(2*pi*f0*t) + 0.55*cos(2*pi*f1*t);  % Time-domain signal
      w0 = fi_radix2twiddles(n);

      F = fimath;
      F.ProductMode       = 'KeepLSB';
      F.ProductWordLength = 32;
      F.SumMode           = 'KeepLSB';
      F.SumWordLength     = 32;
      F.OverflowMode      = 'wrap';
      F.RoundMode         = 'floor';
      F.CastBeforeSum     = false;

      wordlength = 16;
      x = fi(x0, true, wordlength);
      w = fi(w0, true, wordlength, wordlength-1);

      x.fimath = F;
      w.fimath = F;

      y1 = fi_c_radix2fft_withscaling(int16(x), int16(w), w.fractionlength);
      y2 = fi_c_radix2fft_skip_w0(int16(x), int16(w), w.fractionlength);
      [y3, nshifts] = fi_c_radix2fft_blockfloatingpoint(int16(x), int16(w), ...
                                                        w.fractionlength, ...
                                                        int16(lowerbound(x)), ...
                                                        int16(upperbound(x)));

      figure(gcf); clf
      subplot(411);
      plot(t, int16(x));
      title('Input data')

      subplot(412);
      plot(f, abs(double(y1)));
      title('fi_c_radix2fft_withscaling','interpreter','none')

      subplot(413);
      plot(f, abs(double(y2)));
      title('fi_c_radix2fft_skip_w0','interpreter','none')

      subplot(414);
      plot(f, abs(double(y3)));
      title('fi_c_radix2fft_blockfloatingpoint','interpreter','none')


    Reference:
      Charles Van Loan, Computational Frameworks
      for the Fast Fourier Transform, SIAM, Philadelphia, 1992,
      Algorithm 1.6.2, p. 45.

    Copyright 1999-2005 The MathWorks, Inc.
    @author Thomas A. Bryan
    @version $Revision: 1.1.6.1 $ $Date: 2005/02/23 02:43:34 $
*/
#include "mex.h"

#define Y_OUT                plhs[0]

#define X_IN                 prhs[0]
#define W_IN                 prhs[1]
#define WFRACTIONLENGTH_IN        prhs[2]

#define USAGE "\nUsage:  Y = fi_c_radix2fft_skip_w0(X, W, Wfractionlength)"

void bitreverse(int16_T* xr, int16_T* xi, int n);
bool isPowerOfTwo(int n);
int log2(int n);

void fi_c_radix2fft_skip_w0(int16_T* xr, int16_T* xi, int16_T* wr, int16_T* wi,
                            int n, int nw, int t,
                            int Wfraclen)
{
    int32_T tempr, tempi;
    int q, i, j, k;
    int n1, n2, n3;
    int L, kL, r, L2;
    bitreverse(xr,xi,n);
    for (q=1; q<=t; q++) {
        L = 1; L <<= q;       /* L = 2^q */
        r = 1; r <<= (t-q);   /* r = n/L = 2^(t-q) */
        L2 = L>>1;            /* L2 = L/2 */
        kL = 0;               /* kL = k*L */
        for (k=0; k<r; k++) {
            /* Skip multiply by w^0=1 */
            n3     = kL;
            n2     = n3 + L2;
            n1     = L2 - 1;
            tempr  = xr[n2];
            tempi  = xi[n2];
            xr[n2] = (((int32_T)xr[n3]) - tempr)>>1;
            xi[n2] = (((int32_T)xi[n3]) - tempi)>>1;
            xr[n3] = (((int32_T)xr[n3]) + tempr)>>1;
            xi[n3] = (((int32_T)xi[n3]) + tempi)>>1;
            for (j=1; j<L2; j++) {
                n3     = kL + j;
                n2     = n3 + L2;
                n1     = L2 - 1 + j;
                tempr  = (int32_T)wr[n1]*(int32_T)xr[n2] - (int32_T)wi[n1]*(int32_T)xi[n2];
                tempi  = (int32_T)wr[n1]*(int32_T)xi[n2] + (int32_T)wi[n1]*(int32_T)xr[n2];
                xr[n2] = ((((int32_T)xr[n3])<<Wfraclen) - tempr)>>(Wfraclen+1);
                xi[n2] = ((((int32_T)xi[n3])<<Wfraclen) - tempi)>>(Wfraclen+1);
                xr[n3] = ((((int32_T)xr[n3])<<Wfraclen) + tempr)>>(Wfraclen+1);
                xi[n3] = ((((int32_T)xi[n3])<<Wfraclen) + tempi)>>(Wfraclen+1);
            }
            kL += L;
        }
    }
}

/**  Bit reverse the input.
  */
void bitreverse(int16_T* xr, int16_T* xi, int n)
{
  /* Increment the bit reversed counter and sort the input sequence.
   */
    int i, j, k;
    int16_T temp;
    int nv2 = n/2;
    j=1;
    for (i=1; i<n; i++) {
        if (i<j) {
            temp   = xr[j-1];
            xr[j-1] = xr[i-1];
            xr[i-1] = temp;
            temp   = xi[j-1];
            xi[j-1] = xi[i-1];
            xi[i-1] = temp;
        }
        k = nv2;
        while (k<j) {
            j = j-k;
            k = k/2;
        }
        j = j+k;
    }
}

bool isPowerOfTwo(int n)
{
    return ((n>0) && ((n&(n-1))==0));
}

/* log2 of exact powers of two */
int log2(int n)
{
    int i=-1;
    while (n>0) {
        n >>= 1;
        i++;
    }
    return i;
}


void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    int n, nw, t;
    int16_T *yr, *yi, *xr, *xi, *wr, *wi;
    int Wfraclen;
    int isWComplex = mxIsComplex(W_IN);

    if (nrhs != 3) mexErrMsgTxt("Wrong number of input arguments." USAGE);
    if (nlhs > 1) mexErrMsgTxt("Too many output arguments." USAGE);

    if (!mxIsInt16(X_IN)) mexErrMsgTxt("X must be int16.");
    if (!mxIsInt16(W_IN)) mexErrMsgTxt("W must be int16.");

    n  = mxGetNumberOfElements(X_IN);
    t = log2(n);  /* n = 2^t */
    nw = mxGetNumberOfElements(W_IN);

    Y_OUT = mxDuplicateArray(X_IN);
    if (n<=1) return;

    if (!isPowerOfTwo(n)) {
        mexErrMsgTxt("The length of X must be a power of two.");
    }
    if (nw != (n-1)) {
        mexErrMsgTxt("The length of the twiddle factor vector "
                     "must be one less than the length of the input data.");
    }

    if (!mxIsComplex(X_IN)) {
        /* Grow imaginary part. */
        int16_T* yi = mxCalloc(n,sizeof(int16_T));
        mxSetImagData(Y_OUT, yi);
    }

    /* Overwrite a copy of the input data for the output */
    xr = (int16_T*)mxGetData    ( Y_OUT );
    xi = (int16_T*)mxGetImagData( Y_OUT );

    wr = (int16_T*)mxGetData    ( W_IN );

    if (isWComplex==1) {
        wi = (int16_T*)mxGetImagData( W_IN );
    }  else {
        wi = mxCalloc(n,sizeof(int16_T));
    }

    Wfraclen = (int)mxGetScalar( WFRACTIONLENGTH_IN );

    fi_c_radix2fft_skip_w0(xr, xi, wr, wi, n, nw, t, Wfraclen);

    if (isWComplex==0) {
        mxFree(wi);
    }
}



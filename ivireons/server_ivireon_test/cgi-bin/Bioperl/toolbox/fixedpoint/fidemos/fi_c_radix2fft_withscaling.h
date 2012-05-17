void fi_c_radix2fft_withscaling(int16_T* xr, int16_T* xi, int16_T* wr, int16_T* wi, 
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
            for (j=0; j<L2; j++) {
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
/* Copyright 2004 The MathWorks, Inc. */
/*   $Revision: 1.1.6.1 $ */

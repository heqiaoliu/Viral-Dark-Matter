% Communications Toolbox
% Version 4.6 (R2010b) 03-Aug-2010
%
% Signal Sources
%   commsrc.pattern - Generate modulated signals with a given pattern.
%   commsrc.pn      - Generate pseudorandom noise sequences.
%   randerr         - Generate bit error patterns.
%   randsrc         - Generate random matrix using prescribed alphabet.
%   wgn             - Generate white Gaussian noise.
%
% Performance Evaluation
%   berawgn            - Bit error rate (BER) and symbol error rate (SER) for uncoded AWGN channels.
%   bercoding          - Bit error rate (BER) for coded AWGN channels.
%   berconfint         - BER and confidence interval of Monte Carlo simulation.
%   berfading          - Bit error rate (BER) and symbol error rate (SER) for fading channels.
%   berfit             - Fit a curve to nonsmooth empirical BER data.
%   bersync            - Bit error rate (BER) for imperfect synchronization.
%   biterr             - Compute number of bit errors and bit error rate.
%   commscope          - Communications scopes (e.g. Eye Diagram, Scatter Plot).
%   commmeasure        - Communications measurements (e.g. EVM, MER, ACPR).
%   commtest.ErrorRate - Error rate test console.
%   distspec           - Compute the distance spectrum of a convolutional code.
%   eyescope           - Eye diagram scope.
%   noisebw            - Calculate the equivalent noise bandwidth of a digital lowpass filter.
%   scatterplot        - Generate a scatter plot.
%   semianalytic       - Calculate bit error rate using the semianalytic technique.
%   symerr             - Compute number of symbol errors and symbol error rate.
%
% Source Coding
%   arithdeco   - Decode binary code using arithmetic decoding.
%   arithenco   - Encode a sequence of symbols using arithmetic coding.
%   compand     - Source code mu-law or A-law compressor or expander.
%   dpcmdeco    - Decode using differential pulse code modulation.
%   dpcmenco    - Encode using differential pulse code modulation.
%   dpcmopt     - Optimize differential pulse code modulation parameters.
%   huffmandeco - Huffman decoder. 
%   huffmandict - Generate Huffman code dictionary for a source with known probability model. 
%   huffmanenco - Huffman encoder. 
%   lloyds      - Optimize quantization parameters using the Lloyd algorithm.
%   quantiz     - Produce a quantization index and a quantized output value.
%
% Error Detection and Correction
%   bchgenpoly     - Generator polynomial of BCH code.
%   bchnumerr      - Number of correctable errors for BCH code.
%   convenc        - Convolutionally encode binary data.
%   crc            - Family of objects to perform CRC generation and detection.
%   cyclgen        - Produce parity-check and generator matrices for cyclic code.
%   cyclpoly       - Produce generator polynomials for a cyclic code.
%   decode         - Block decoder.
%   dvbs2ldpc      - Produce parity-check matrices of LDPC codes from the DVB-S.2 standard.
%   encode         - Block encoder.
%   fec            - Family of objects to perform forward error correction.
%   gen2par        - Convert between parity-check and generator matrices.
%   gfweight       - Calculate the minimum distance of a linear block code.
%   hammgen        - Produce parity-check and generator matrices for Hamming code.
%   iscatastrophic - Determine if a convolutional code is catastrophic or not.
%   rsdecof        - Decode an ASCII file that was encoded using Reed-Solomon code.
%   rsencof        - Encode an ASCII file using Reed-Solomon code.
%   rsgenpoly      - Produce Reed-Solomon code generator polynomial.
%   syndtable      - Produce syndrome decoding table.
%   vitdec         - Convolutionally decode binary data using the Viterbi algorithm.
%
% Interleaving/Deinterleaving
%   algdeintrlv     - Restore ordering of symbols.
%   algintrlv       - Reorder symbols using algebraically derived permutation table.
%   convdeintrlv    - Restore ordering of symbols permuted using shift registers.
%   convintrlv      - Permute symbols using a set of shift registers.
%   deintrlv        - Restore ordering of symbols.
%   intrlv          - Reorder sequence of symbols.
%   helintrlv       - Permute symbols using a helical array.
%   heldeintrlv     - Restore ordering of symbols permuted using HELINTRLV.
%   helscandeintrlv - Restore ordering of symbols in a helical pattern.
%   helscanintrlv   - Permute symbols in a helical pattern.
%   matdeintrlv     - Reorder symbols by filling a matrix by columns and emptying it by rows.
%   matintrlv       - Permute symbols by filling a matrix by rows and emptying it by columns.
%   muxdeintrlv     - Restore ordering of symbols using specified shift registers.
%   muxintrlv       - Permute symbols using shift registers with specified delays.
%   randdeintrlv    - Restore ordering of symbols using a random permutation.
%   randintrlv      - Reorder the symbols using a random permutation.
%
% Analog Modulation/Demodulation
%   ammod    - Amplitude modulation.
%   amdemod  - Amplitude demodulation.
%   fmmod    - Frequency modulation.
%   fmdemod  - Frequency demodulation.
%   pmmod    - Phase modulation.
%   pmdemod  - Phase demodulation.
%   ssbmod   - Single sideband amplitude modulation.
%   ssbdemod - Single sideband amplitude demodulation.
%
% Digital Modulation/Demodulation
%   fskmod   - Frequency shift keying modulation.
%   fskdemod - Frequency shift keying demodulation.
%   modnorm  - Scaling factor for normalizing modulation output.
%
% MODEM objects
%   modem             - Family of objects for modulation/demodulation.
%   modem.pskmod      - For Phase shift keying modulation. 
%   modem.pskdemod    - For Phase shift keying demodulation. 
%   modem.qammod      - For Quadrature amplitude modulation.
%   modem.qamdemod    - For Quadrature amplitude demodulation.
%   modem.pammod      - For Pulse amplitude modulation.
%   modem.pamdemod    - For Pulse amplitude demodulation.
%   modem.dpskmod     - For Differential phase shift keying modulation.
%   modem.dpskdemod   - For Differential phase shift keying demodulation.
%   modem.oqpskmod    - For Offset quadrature phase shift keying modulation.
%   modem.oqpskdemod  - For Offset quadrature phase shift keying demodulation.
%   modem.genqammod   - For General quadrature amplitude modulation.
%   modem.genqamdemod - For General quadrature amplitude demodulation.
%   modem.mskmod      - For Minimum shift keying modulation.
%   modem.mskdemod    - For Minimum shift keying demodulation.
%  Methods for MODEM objects
%   modem/modulate    - Modulate data using modulation object.
%   modem/demodulate  - Demodulate signal using demodulation object.
%   modem/disp        - Display properties of MODEM object.
%   modem/copy        - Copy MODEM object.
%
% Pulse Shaping
%   intdump   - Integrate and dump.
%   rcosflt   - Filter the input signal using a raised cosine filter.
%   rectpulse - Rectangular pulse shaping.
%
% Special Filters
%   hank2sys  - Convert a Hankel matrix to a linear system model.
%   hilbiir   - Hilbert transform IIR filter design.
%   rcosine   - Design raised cosine filter.
%
% Lower-Level Functions for Special Filters
%   rcosfir   - Design a raised cosine FIR filter.
%   rcosiir   - Design a raised cosine IIR filter.
%
% Channels
%   awgn         - Add white Gaussian noise to a signal.
%   bsc          - Model a binary symmetric channel.
%   mimochan     - Construct a multipath fading MIMO channel object.
%   rayleighchan - Construct a Rayleigh fading channel object.
%   ricianchan   - Construct a Rician fading channel object.
%   stdchan      - Construct a channel object from a set of standardized channel models.
%   filter       - Filter a signal with a channel object.
%   reset        - Reset a channel object.
%
% DOPPLER objects
%   doppler            - Family of Doppler spectra objects.
%   doppler.jakes      - Jakes Doppler spectrum object. 
%   doppler.flat       - Flat Doppler spectrum object. 
%   doppler.rjakes     - Restricted Jakes Doppler spectrum object.
%   doppler.ajakes     - Asymmetrical Jakes Doppler spectrum object.
%   doppler.rounded    - Rounded Doppler spectrum object.
%   doppler.gaussian   - Gaussian Doppler spectrum object.
%   doppler.bigaussian - Bi-Gaussian Doppler spectrum object.
%   doppler.bell       - Bell Doppler spectrum object.
%
% Equalizers
%   lms      - Construct a least mean square (LMS) adaptive algorithm object.
%   signlms  - Construct a signed LMS adaptive algorithm object.
%   normlms  - Construct a normalized LMS adaptive algorithm object.
%   varlms   - Construct a variable step size LMS adaptive algorithm object.
%   rls      - Construct a recursive least squares (RLS) adaptive algorithm object.
%   cma      - Construct a constant modulus algorithm (CMA) object.
%   lineareq - Construct a linear equalizer object.
%   dfe      - Decision feedback equalizer.
%   equalize - Equalize a signal with an equalizer object.
%   reset    - Reset equalizer object.
%   mlseeq   - Equalize a linearly modulated signal using the Viterbi algorithm.
%  
% Galois Field Computations
%   gf          - Create a Galois array.
%   gfhelp      - Provide a list of operators that are compatible with Galois arrays. 
%   convmtx     - Convolution matrix of Galois field vector.
%   cosets      - Produce cyclotomic cosets for a Galois field.
%   dftmtx      - Discrete Fourier transform matrix in a Galois field.
%   gftable     - Generate a file to accelerate Galois field computations.
%   isprimitive - Check whether a polynomial over a Galois field is primitive.
%   minpol      - Find the minimal polynomial for a Galois element.
%   primpoly    - Find primitive polynomials for a Galois field.
%
% Computations in Galois Fields of Odd Characteristic
%   gfadd    - Add polynomials over a Galois field.
%   gfconv   - Multiply polynomials over a Galois field.
%   gfcosets - Produce cyclotomic cosets for a Galois field.
%   gfdeconv - Divide polynomials over a Galois field.
%   gfdiv    - Divide elements of a Galois field.
%   gffilter - Filter data using polynomials over a prime Galois field.
%   gflineq  - Find a particular solution of Ax = b over a prime Galois field. 
%   gfminpol - Find the minimal polynomial of an element of a Galois field.
%   gfmul    - Multiply elements of a Galois field.
%   gfpretty - Display a polynomial in traditional format.
%   gfprimck - Check whether a polynomial over a Galois field is primitive.
%   gfprimdf - Provide default primitive polynomials for a Galois field.
%   gfprimfd - Find primitive polynomials for a Galois field.
%   gfrank   - Compute the rank of a matrix over a Galois field.
%   gfrepcov - Convert one binary polynomial representation to another.
%   gfroots  - Find roots of a polynomial over a prime Galois field.
%   gfsub    - Subtract polynomials over a Galois field.
%   gftrunc  - Minimize the length of a polynomial representation.
%   gftuple  - Simplify or convert the format of elements of a Galois field.
%
% Utilities
%   alignsignals   - Aligns two signals, by delaying the earliest signal.
%   bi2de          - Convert binary vectors to decimal numbers.
%   bin2gray       - Gray encode a scalar, a vector or matrix of positive integers.
%   de2bi          - Convert decimal numbers to binary numbers.
%   erf            - Error function.
%   erfc           - Complementary error function.
%   finddelay      - Estimates the delay between signals.
%   iscatastrophic - Check if a trellis corresponds to a catastrophic convolutional code.
%   istrellis      - Check if the input is a valid trellis structure.
%   gray2bin       - Gray decode a scalar, a vector or matrix of positive integers.
%   marcumq        - Generalized Marcum Q function.
%   mask2shift     - Convert mask vector to shift for a shift register configuration.
%   oct2dec        - Convert octal numbers to decimal numbers.
%   poly2trellis   - Convert convolutional code polynomial to trellis description.
%   qfunc          - Q function.
%   qfuncinv       - Inverse Q function.
%   shift2mask     - Convert shift to mask vector for a shift register configuration.
%   vec2mat        - Convert a vector into a matrix.
%
% Graphical User Interface
%   bertool - Bit Error Rate Analysis Tool.
%
% See also COMMDEMOS, COMM/EXAMPLES, SIGNAL.

% Copyright 1996-2010 The MathWorks, Inc.
% Generated from Contents.m_template revision 1.1.6.35 $Date: 2009/05/23 07:48:08 $


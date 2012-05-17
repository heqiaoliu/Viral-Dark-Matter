// Copyright 2010 The MathWorks, Inc.
// $Revision: 1.1.8.1 $   $Date: 2010/05/03 16:03:48 $

// A simple function to map co-ordinates to linear indices.
__device__ unsigned int iLinOffSet( int r, int c, 
                                    int m, int n,
                                    int offRow, int offCol ) {
    r = r + offRow;
    r = ( r >= m ? r - m : r );
    r = ( r <  0 ? r + m : r );
 
    c = c + offCol;
    c = ( c >= n ? c - n : c );
    c = ( c <  0 ? c + n : c );
    return c * m + r;
}

// Shared memory used to communicate between threads for stencil calculation
extern __shared__ unsigned char block[];

// macro to simplify accessing shared memory
#define BLOCK_EL( yyy, xxx ) block[ iLinOffSet( (yyy), (xxx), blockDim.y, blockDim.x, 0, 0 ) ]

// one generation of the game of life. Overwrites board each turn.
__global__ void life( unsigned char * board, int m, int n ) {

    // co-ords in global board
    int ix     = blockIdx.x * blockDim.x + threadIdx.x;
    int iy     = blockIdx.y * blockDim.y + threadIdx.y;
    int linidx = iLinOffSet( iy, ix, m, n, 0, 0 );

    // Load up the shared memory - plus ghost cells using toroidal boundary
    // conditions.
    BLOCK_EL( threadIdx.y + 1, threadIdx.x + 1 ) = board[linidx];
    if ( threadIdx.x == 0 ) {
        BLOCK_EL( threadIdx.y, 0 ) = board[ iLinOffSet( iy, ix, m, n, 0, -1 ) ];
    }
    if ( threadIdx.x == blockDim.x - 1 ) {
        BLOCK_EL( threadIdx.y, blockDim.x + 1 ) = board[ iLinOffSet( iy, ix, m, n, 0, 1 ) ];
    }
    if ( threadIdx.y == 0 ) {
        BLOCK_EL( 0, threadIdx.x ) = board[ iLinOffSet( iy, ix, m, n, -1, 0 ) ];
    }
    if ( threadIdx.y == blockDim.y - 1 ) {
        BLOCK_EL( blockDim.y + 1, threadIdx.x ) = board[ iLinOffSet( iy, ix, m, n, 1, 0 ) ];
    }

    // Make sure all shared memory is loaded
    __syncthreads();
    
    // Game of life stencil computation
    int liveNeighbours = 0;
    int imAlive        = BLOCK_EL( threadIdx.y + 1, threadIdx.x + 1 );
    for ( int xoff = 0; xoff <= 2; xoff++ ) {
        for ( int yoff = 0; yoff <= 2; yoff++ ) {
            if ( ! ( xoff == 1 && yoff == 1 ) ) {
                liveNeighbours += BLOCK_EL( threadIdx.y + yoff, threadIdx.x + xoff );
            }
        }
    }
    
    // Finally, update the board.
    if ( ix < n && iy < m ) {
        board[linidx] = ( imAlive && liveNeighbours == 2 ||
                          liveNeighbours == 3 );
    }
}

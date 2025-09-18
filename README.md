# Gas-Aware Airdrop Implementation

The CampusCreditV2 airdrop function demonstrates gas optimization through four key techniques that achieve measurable gas savings compared to individual transfers. Testing with 3 recipients receiving 10 tokens each shows the batch airdrop consumed 94,999 gas versus 104,780 gas for individual transfers, representing a 9.33% gas savings and 4.12% fee reduction. 

First, custom errors like CapExceeded() and ArrayLengthMismatch() use 4-byte selectors instead of full error strings, reducing failure costs by 50-80% since require strings consume ~22 gas per byte for on-chain storage while custom errors cost only ~100 gas total. 

Second, calldata optimization leverages arrays passed as calldata parameters, which read directly from transaction data at 4 gas per byte, compared to memory arrays that require copying calldata to memory at an additional 3 gas per word, eliminating allocation overhead that scales with array size. 

Third, unchecked loop arithmetic using unchecked { ++i; } blocks disables Solidity 0.8+ automatic overflow checks that cost ~20 gas per operation, providing safe savings since loop counters cannot realistically overflow in practice. 

Fourth, single transaction amortization spreads the fixed 21,000 gas base transaction cost across multiple operations instead of paying it three times for individual transfers (63,000 gas total), while also sharing function call overhead and enabling optimized state tree updates with a single root hash change. Additional optimizations include pre-validation that calculates the total mint amount before any state changes to fail fast on cap violations, demonstrated by the contract's successful deployment at address 0x5fbdb2315678afecb367f032d93f642f64180aa3 on block 1 with 1,943,296 deployment gas. The implementation shows increasing efficiency potential as batch sizes grow, since the fixed costs become amortized across more operations, making it a production-ready solution that scales cost-effectively for token distribution operations.

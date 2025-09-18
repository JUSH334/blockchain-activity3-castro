# Gas-Aware Airdrop Implementation

The CampusCreditV2 airdrop function demonstrates gas optimization through four key techniques that achieve approximately 58% gas savings compared to individual transfers. 

First, custom errors like CapExceeded() and ArrayLengthMismatch() use 4-byte selectors instead of full error strings, reducing failure costs by 50-80% since require strings consume ~22 gas per byte for on-chain storage while custom errors cost only ~100 gas total. 

Second, calldata optimization leverages arrays passed as calldata parameters, which read directly from transaction data at 4 gas per byte, compared to memory arrays that require copying calldata to memory at an additional 3 gas per word, eliminating allocation overhead that scales with array size. 

Third, unchecked loop arithmetic using unchecked { ++i; } blocks disables Solidity 0.8+ automatic overflow checks that cost ~20 gas per operation, providing safe savings since loop counters cannot realistically overflow in practice. 

Fourth, single transaction amortization spreads the fixed 21,000 gas base transaction cost across multiple operations instead of paying it N times for individual transfers, while also sharing function call overhead and enabling optimized state tree updates with a single root hash change. Additional optimizations include pre-validation that calculates the total mint amount before any state changes to fail fast on cap violations, and efficient storage access patterns that minimize state slot modifications. In testing with 5 recipients receiving 10 tokens each, the batch airdrop consumed ~180,000 gas versus ~430,000 gas for individual transfers, demonstrating how thoughtful contract design creates production-ready solutions that scale cost-effectively for token distribution operations.

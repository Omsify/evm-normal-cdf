## EVM Gaussian CDF

The task was to implement an optimized Gaussian CDF using fixed-point WAD numbers. Gaussian CDF can be computed using different approximations. In the gaussian.js reference library an approximation involving polynomials and exponentiating is used. But we can't efficiently calculate fixed-point exponentiation in the EVM. Another way is to use the `erfc` (complementary error function) to calculate the cdf. So we need to approximate `exp` or `erfc` directly.

## Results
My implementation of cdf in Huff is `85-90%` more efficient than the `primitivefinance/solstat` one.

## How I did it

I decided to use **Chebyshev polynomial** function approximation for `erfc`. Why not rational approximation? Well, there are two main reasons:
1. Calculating two polynomials of degrees `p` and `q` and then dividing them is almost the same (gas-wise) as calculating one polynomial of degree `p+q`
2. Chebyshev polynomial approximation is easier to implement. And they allow to use a trick I came up with. (more on this below)

So first we see that `erfc(-x) = 2 - erfc(x)` for `x>0`. This allows us to split the approximation range by half. Furthermore, `erfc(x)` for `x>=6.24` is less than `1e-18`, so it can't even fit the smallest decimal digit in the 18 decimal fixed point numbers format.

So we need to approximate erfc(x) for `0<=x<=6.24`, which is a pretty small range.

While I was researching possible approximation techniques for erfc, I stumbled upon [this article](https://www.ams.org/journals/mcom/1969-23-107/S0025-5718-1969-0247736-4/S0025-5718-1969-0247736-4.pdf), which used different approximations for different function ranges. Then I came up with the following idea to approximate `erfc(x)`: 
1. We set a fixed (max) polynomial degree, for example, `n=6`
2. We binary search the most right possible endpoint `rp<=6.24` such that the interval `[0, rp]` can be approximated by a polinomial with degree at most `n`
3. We save the polynomial and repeat the process with the interval `[rp, 6.24]` slicing it as much time as needed.
Using this algorithm, we get an approximation for `erfc(x)` with an error less than `1e-8` that uses polynomials of degree `<=n`

Then in a smart contract, when computing `erfc(x)` we can find the interval `x` belongs to using binary search and calculate the related polynomial using Horner's method.

To implement all of this I've created several python scripts. More precisely, I used `mpmath` library to get the precision and Chebyshev polynomial approximations. Also one part of the script automatically generates Huff evm-assembly language code. This generated code implements the binary search in the contract and the polynomial calculation.

## Usage
First, clone the repository and make sure you have `foundry` and `huffc` (huff language compiler) installed. Then in the project folder run:
```bash
forge install
forge t -vv --ffi
```
ffi access is needed to deploy a huff contract using `foundry-huff` library.

## Notes
I tested the implementation against [primitivefinance/solstat](https://github.com/primitivefinance/solstat/blob/main/src/Gaussian.sol), which has a maximum error of 1e-15 compared to Gaussian.js library.

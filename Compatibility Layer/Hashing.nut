// Wrapper functions for offical Hashing plugin
// ------------------------------------------------------- //

// hashing plugin returns results in uppercase
function _EvalHash(h, s) { return SqCrypto.Hash(h, s).toupper(); }

// not including all of them ; check below link for more
// https://github.com/VCMP-SqMod/SqMod-Snippets/blob/main/SqCrypto/hash.nut

function SHA256(s) { return _EvalHash("SHA256", s); }
function SHA512(s) { return _EvalHash("SHA512", s); }

function MD5(s) { return _EvalHash("MD5", s); }
function RIPEMD(s) { return _EvalHash("RIPEMD", s); }
function WHIRLPOOL(s) { return _EvalHash("WHIRLPOOL", s); }
import { binexpmod } from "./exp.ts";
import { encode, decode } from "./code.ts";
import { key_creation } from "./rsa.ts";

export type RSAPublicKey = { N: bigint; e: bigint };
export type RSAPrivateKey = { N: bigint; d: bigint };

/**
 * Sign a message (string or bigint representative) using RSA private key.
 * Note: This implementation uses the raw message representative (no padding or hashing).
 */
export const sign = (
  message: string | bigint,
  priv: RSAPrivateKey
): bigint => {
  const m = typeof message === "string" ? encode(message) : message;
  if (m >= priv.N) throw new Error("message representative too large for modulus");
  return binexpmod(m, priv.d, priv.N);
};

/**
 * Verify an RSA signature. Returns true if signature is valid for message and public key.
 */
export const verify = (
  message: string | bigint,
  signature: bigint,
  pub: RSAPublicKey
): boolean => {
  const m = typeof message === "string" ? encode(message) : message;
  const mFromSig = binexpmod(signature, pub.e, pub.N);
  return m === mFromSig;
};

// Convenience functions that operate on bigint hashes/representatives directly
export const signHash = (hash: bigint, priv: RSAPrivateKey) => sign(hash, priv);
export const verifyHash = (hash: bigint, signature: bigint, pub: RSAPublicKey) =>
  verify(hash, signature, pub);

// --- Demo / Example usage ---
// Uses small primes for demonstration. In practice, use large safe primes
const demo = () => {
  const p = 1223n;
  const q = 1987n;
  const e = 65537n;
  const { N, e: pubE, d } = key_creation(p, q, e);
  const pub: RSAPublicKey = { N, e: pubE };
  const priv: RSAPrivateKey = { N, d };

  const message = "Web3Bridge";
  const signature = sign(message, priv);

  console.log("message:", message);
  console.log("signature:", signature.toString());
  console.log("verify (correct):", verify(message, signature, pub));
  console.log("verify (tampered):", verify("Web3Br1dge", signature, pub));

  // Show that verification also works on numeric representatives
  const mRep = encode(message);
  const s2 = signHash(mRep, priv);
  console.log("verify numeric rep:", verifyHash(mRep, s2, pub));
};

// Run demo for local testing (consistent with other files which log at import time)
demo();

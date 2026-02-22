# TrustCert Protocol

**On-Chain Certificate Issuance & Revocation Registry**  
A Clarity smart contract for managing digital certificates with transparent issuance, revocation, and verification.

---

## Features

- **Admin-managed issuer authorization**
- **Issuers can issue certificates**
- **Issuers can revoke certificates**
- **Public verification of certificate status**
- **Designed for clarity and easy testing with Clarinet**

---

## Contract Overview

- **Admin:** The contract deployer is the admin and can add or remove authorized issuers.
- **Issuers:** Only authorized issuers can issue or revoke certificates.
- **Certificates:** Each certificate has an owner, issuer, status (revoked or not), and issuance block height.

---

## Error Codes

| Code                | Value   | Description                       |
|---------------------|---------|-----------------------------------|
| ERR-NOT-ADMIN       | `u100`  | Caller is not the admin           |
| ERR-NOT-ISSUER      | `u101`  | Caller is not an authorized issuer|
| ERR-CERT-NOT-FOUND  | `u102`  | Certificate does not exist        |
| ERR-CERT-EXISTS     | `u103`  | Certificate already exists        |
| ERR-ALREADY-REVOKED | `u104`  | Certificate already revoked       |

---

## Public Functions

### Admin Functions

- `add-issuer (issuer principal)`  
  Add a new authorized issuer (admin only).

- `remove-issuer (issuer principal)`  
  Remove an authorized issuer (admin only).

### Issuer Functions

- `issue-certificate (cert-id uint) (owner principal)`  
  Issue a new certificate (authorized issuers only).

- `revoke-certificate (cert-id uint)`  
  Revoke a certificate issued by the sender.

### Read-Only Functions

- `get-certificate (cert-id uint)`  
  Get full certificate details.

- `is-certificate-valid (cert-id uint)`  
  Returns `true` if the certificate exists and is not revoked.

- `is-authorized-issuer (issuer principal)`  
  Returns `true` if the address is an authorized issuer.

- `get-admin`  
  Returns the admin address.

---

## Example Usage

```clarity
;; Add an issuer (admin only)
(add-issuer 'SP...')

;; Issue a certificate (issuer only)
(issue-certificate u1 'SP...owner...)

;; Revoke a certificate (issuer only)
(revoke-certificate u1)

;; Check certificate validity
(is-certificate-valid u1)
```

---

## Testing

- Designed for use with [Clarinet](https://docs.hiro.so/clarinet/getting-started).
- Includes clear error codes and read-only verification functions.

---

## License

MIT License

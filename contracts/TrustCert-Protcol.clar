;; ------------------------------------------------------------
;; CertiTrust
;; On-Chain Certificate Issuance & Revocation Registry
;;
;; Features:
;; - Admin-managed issuer authorization
;; - Issuers can issue certificates
;; - Issuers can revoke certificates
;; - Public verification of certificate status
;;
;; Designed for clarity, readability, and Clarinet testing
;; ------------------------------------------------------------

;; -------------------------
;; Error Codes
;; -------------------------
(define-constant ERR-NOT-ADMIN u100)
(define-constant ERR-NOT-ISSUER u101)
(define-constant ERR-CERT-NOT-FOUND u102)
(define-constant ERR-CERT-EXISTS u103)
(define-constant ERR-ALREADY-REVOKED u104)

;; -------------------------
;; Contract Owner (Admin)
;; -------------------------
(define-data-var admin principal tx-sender)

;; -------------------------
;; Authorized Issuers
;; -------------------------
;; issuer principal => true
(define-map issuers principal bool)

;; -------------------------
;; Certificate Registry
;; -------------------------
;; cert-id => certificate data
(define-map certificates uint {
  owner: principal,
  issuer: principal,
  revoked: bool,
  issued-at: uint
})

;; ============================================================
;; ADMIN FUNCTIONS
;; ============================================================

;; Add a new authorized issuer
(define-public (add-issuer (issuer principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (map-set issuers issuer true)
      (ok true)
    )
    (err ERR-NOT-ADMIN)
  )
)

;; Remove an issuer
(define-public (remove-issuer (issuer principal))
  (if (is-eq tx-sender (var-get admin))
    (begin
      (map-delete issuers issuer)
      (ok true)
    )
    (err ERR-NOT-ADMIN)
  )
)

;; ============================================================
;; ISSUER FUNCTIONS
;; ============================================================

;; Issue a new certificate
(define-public (issue-certificate (cert-id uint) (owner principal))
  (if (is-eq (default-to false (map-get? issuers tx-sender)) true)
    (if (is-none (map-get? certificates cert-id))
      (begin
        (map-set certificates cert-id {
          owner: owner,
          issuer: tx-sender,
          revoked: false,
          issued-at: stacks-block-height
        })
        (ok true)
      )
      (err ERR-CERT-EXISTS)
    )
    (err ERR-NOT-ISSUER)
  )
)

;; Revoke an issued certificate
(define-public (revoke-certificate (cert-id uint))
  (let ((cert (map-get? certificates cert-id)))
    (if (is-some cert)
      (let ((cert-data (unwrap-panic cert)))
        (if (is-eq (get issuer cert-data) tx-sender)
          (if (not (get revoked cert-data))
            (begin
              (map-set certificates cert-id {
                owner: (get owner cert-data),
                issuer: tx-sender,
                revoked: true,
                issued-at: (get issued-at cert-data)
              })
              (ok true)
            )
            (err ERR-ALREADY-REVOKED)
          )
          (err ERR-NOT-ISSUER)
        )
      )
      (err ERR-CERT-NOT-FOUND)
    )
  )
)

;; ============================================================
;; READ-ONLY FUNCTIONS (PUBLIC)
;; ============================================================

;; Verify full certificate details
(define-read-only (get-certificate (cert-id uint))
  (map-get? certificates cert-id)
)

;; Check if a certificate is valid (exists and not revoked)
(define-read-only (is-certificate-valid (cert-id uint))
  (match (map-get? certificates cert-id)
    cert (not (get revoked cert))
    false
  )
)

;; Check if an address is an authorized issuer
(define-read-only (is-authorized-issuer (issuer principal))
  (default-to false (map-get? issuers issuer))
)

;; Get contract admin
(define-read-only (get-admin)
  (var-get admin)
)

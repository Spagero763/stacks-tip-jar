;; Tip Jar Contract
;; Allows anyone to send STX tips, owner can withdraw

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-OWNER (err u100))
(define-constant ERR-NO-BALANCE (err u101))
(define-constant ERR-INVALID-AMOUNT (err u102))

;; Data
(define-data-var total-tips uint u0)
(define-data-var tip-count uint u0)

;; Maps
(define-map tipper-amounts principal uint)

;; Read-only functions
(define-read-only (get-balance)
  (stx-get-balance (as-contract tx-sender))
)

(define-read-only (get-total-tips)
  (ok (var-get total-tips))
)

(define-read-only (get-tip-count)
  (ok (var-get tip-count))
)

(define-read-only (get-tipper-amount (tipper principal))
  (ok (default-to u0 (map-get? tipper-amounts tipper)))
)

(define-read-only (get-owner)
  (ok CONTRACT-OWNER)
)

;; Public functions
(define-public (send-tip (amount uint))
  (begin
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (var-set total-tips (+ (var-get total-tips) amount))
    (var-set tip-count (+ (var-get tip-count) u1))
    (map-set tipper-amounts tx-sender
      (+ (default-to u0 (map-get? tipper-amounts tx-sender)) amount)
    )
    (ok true)
  )
)

(define-public (withdraw (amount uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)
    (asserts! (> amount u0) ERR-INVALID-AMOUNT)
    (asserts! (>= (stx-get-balance (as-contract tx-sender)) amount) ERR-NO-BALANCE)
    (as-contract (stx-transfer? amount tx-sender CONTRACT-OWNER))
  )
)

(define-public (withdraw-all)
  (let ((balance (stx-get-balance (as-contract tx-sender))))
    (begin
      (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-OWNER)
      (asserts! (> balance u0) ERR-NO-BALANCE)
      (as-contract (stx-transfer? balance tx-sender CONTRACT-OWNER))
    )
  )
)
;; Invoice Token Contract

(define-non-fungible-token invoice uint)

(define-map invoice-data uint {
    issuer: principal,
    payer: principal,
    amount: uint,
    due-date: uint,
    paid: bool
})

(define-data-var invoice-counter uint u0)

(define-public (create-invoice (payer principal) (amount uint) (due-date uint))
    (let
        ((invoice-id (+ (var-get invoice-counter) u1))
         (issuer tx-sender))
        (try! (nft-mint? invoice invoice-id issuer))
        (map-set invoice-data invoice-id {
            issuer: issuer,
            payer: payer,
            amount: amount,
            due-date: due-date,
            paid: false
        })
        (var-set invoice-counter invoice-id)
        (ok invoice-id)))

(define-public (transfer-invoice (invoice-id uint) (recipient principal))
    (begin
        (try! (nft-transfer? invoice invoice-id tx-sender recipient))
        (ok true)))

(define-read-only (get-invoice (invoice-id uint))
    (ok (unwrap! (map-get? invoice-data invoice-id) (err u404))))

(define-public (mark-invoice-paid (invoice-id uint))
    (let
        ((invoice-info (unwrap! (map-get? invoice-data invoice-id) (err u404))))
        (asserts! (is-eq (get payer invoice-info) tx-sender) (err u403))
        (ok (map-set invoice-data invoice-id (merge invoice-info { paid: true })))))


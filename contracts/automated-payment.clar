;; Automated Payment Contract

(define-map invoices uint {
    payer: principal,
    recipient: principal,
    amount: uint,
    due-date: uint,
    paid: bool
})

(define-map pending-payments uint {
    invoice-id: uint,
    amount: uint,
    recipient: principal
})

(define-data-var invoice-counter uint u0)
(define-data-var payment-counter uint u0)

(define-public (create-invoice (recipient principal) (amount uint) (due-date uint))
    (let
        ((invoice-id (+ (var-get invoice-counter) u1)))
        (map-set invoices invoice-id {
            payer: tx-sender,
            recipient: recipient,
            amount: amount,
            due-date: due-date,
            paid: false
        })
        (var-set invoice-counter invoice-id)
        (ok invoice-id)))

(define-public (schedule-payment (invoice-id uint))
    (let
        ((invoice (unwrap! (map-get? invoices invoice-id) (err u404)))
         (payment-id (+ (var-get payment-counter) u1)))
        (asserts! (is-eq (get payer invoice) tx-sender) (err u403))
        (asserts! (not (get paid invoice)) (err u400))
        (map-set pending-payments payment-id {
            invoice-id: invoice-id,
            amount: (get amount invoice),
            recipient: (get recipient invoice)
        })
        (var-set payment-counter payment-id)
        (ok payment-id)))

(define-public (confirm-delivery (payment-id uint))
    (let
        ((payment (unwrap! (map-get? pending-payments payment-id) (err u404)))
         (invoice-id (get invoice-id payment)))
        (try! (stx-transfer? (get amount payment) tx-sender (get recipient payment)))
        (map-set invoices invoice-id (merge (unwrap! (map-get? invoices invoice-id) (err u404)) { paid: true }))
        (map-delete pending-payments payment-id)
        (ok true)))

(define-read-only (get-invoice (invoice-id uint))
    (ok (unwrap! (map-get? invoices invoice-id) (err u404))))

(define-read-only (get-pending-payment (payment-id uint))
    (ok (unwrap! (map-get? pending-payments payment-id) (err u404))))


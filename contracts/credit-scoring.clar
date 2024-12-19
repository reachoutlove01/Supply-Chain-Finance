;; Credit Scoring Contract

(define-map credit-scores principal {
    score: uint,
    total-payments: uint,
    on-time-payments: uint
})

(define-public (update-credit-score (user principal) (on-time bool))
    (let
        ((current-data (default-to { score: u500, total-payments: u0, on-time-payments: u0 }
                                   (map-get? credit-scores user)))
         (new-total (+ (get total-payments current-data) u1))
         (new-on-time (if on-time (+ (get on-time-payments current-data) u1) (get on-time-payments current-data)))
         (new-score (/ (* u1000 new-on-time) new-total)))
        (map-set credit-scores user {
            score: new-score,
            total-payments: new-total,
            on-time-payments: new-on-time
        })
        (ok new-score)))

(define-read-only (get-credit-score (user principal))
    (ok (default-to { score: u500, total-payments: u0, on-time-payments: u0 }
                    (map-get? credit-scores user))))


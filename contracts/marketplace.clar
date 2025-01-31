;; Marketplace Contract
(use-trait vr-asset-trait .vr-asset.vr-asset)

;; Constants
(define-constant err-not-listed (err u200))
(define-constant err-price-mismatch (err u201))

;; Data vars
(define-map listings 
  uint
  {
    seller: principal,
    price: uint,
    listed-at: uint
  }
)

;; List asset for sale
(define-public (list-asset (asset-id uint) (price uint))
  (let ((owner (unwrap! (nft-get-owner? vr-asset asset-id) err-not-listed)))
    (asserts! (is-eq tx-sender owner) err-not-owner)
    (map-set listings asset-id
      {
        seller: tx-sender,
        price: price,
        listed-at: block-height
      }
    )
    (ok true)
  )
)

;; Purchase listed asset
(define-public (purchase (asset-id uint))
  (let (
    (listing (unwrap! (map-get? listings asset-id) err-not-listed))
    (price (get price listing))
  )
    (try! (stx-transfer? price tx-sender (get seller listing)))
    (try! (contract-call? .vr-asset transfer asset-id tx-sender))
    (map-delete listings asset-id)
    (ok true)
  )
)

;; VR Asset NFT Contract
(define-non-fungible-token vr-asset uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-owner (err u100))
(define-constant err-asset-exists (err u101))
(define-constant err-asset-not-found (err u102))

;; Data vars
(define-map asset-metadata
  uint 
  {
    name: (string-utf8 64),
    description: (string-utf8 256),
    model-uri: (string-utf8 256),
    created-at: uint,
    creator: principal
  }
)

(define-data-var asset-counter uint u0)

;; Mint new VR asset
(define-public (mint (name (string-utf8 64)) 
                   (description (string-utf8 256))
                   (model-uri (string-utf8 256)))
  (let ((asset-id (+ (var-get asset-counter) u1)))
    (try! (nft-mint? vr-asset asset-id tx-sender))
    (map-set asset-metadata asset-id
      {
        name: name,
        description: description, 
        model-uri: model-uri,
        created-at: block-height,
        creator: tx-sender
      }
    )
    (var-set asset-counter asset-id)
    (ok asset-id)
  )
)

;; Transfer asset
(define-public (transfer (asset-id uint) (recipient principal))
  (begin
    (try! (nft-transfer? vr-asset asset-id tx-sender recipient))
    (ok true)
  )
)

;; Get asset metadata
(define-read-only (get-metadata (asset-id uint))
  (ok (unwrap! (map-get? asset-metadata asset-id)
      err-asset-not-found))
)

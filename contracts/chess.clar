(define-constant EMPTY u0)
(define-constant WHITE-PAWN u1)
(define-constant WHITE-KNIGHT u2)
(define-constant WHITE-BISHOP u3)
(define-constant WHITE-ROOK u4)
(define-constant WHITE-QUEEN u5)
(define-constant WHITE-KING u6)

(define-constant BLACK-PAWN u7)
(define-constant BLACK-KNIGHT u8)
(define-constant BLACK-BISHOP u9)
(define-constant BLACK-ROOK u10)
(define-constant BLACK-QUEEN u11)
(define-constant BLACK-KING u12)


(define-map games
  ((game-id uint))
  ((player principal)
   (board (list 64 uint)) ; 8x8 board flattened
   (turn bool)
   (status (string-ascii 32))
   (move-history (list 200 (tuple (from uint) (to uint))))
   (last-move-time uint)
  )
)

(define-data-var game-counter uint u0)


(define-read-only (initial-board)
  (ok
    (list 
      u10 u8 u9 u11 u12 u9 u8 u10 ; Black back rank
      u7 u7 u7 u7 u7 u7 u7 u7     ; Black pawns
      u0 u0 u0 u0 u0 u0 u0 u0     ; Empty rows
      u0 u0 u0 u0 u0 u0 u0 u0
      u0 u0 u0 u0 u0 u0 u0 u0
      u0 u0 u0 u0 u0 u0 u0 u0
      u1 u1 u1 u1 u1 u1 u1 u1     ; White pawns
      u4 u2 u3 u5 u6 u3 u2 u4     ; White back rank
    )
  )
)



; create game function
(define-public (create-game)
  (let
    (
      (player tx-sender)
      (counter (var-get game-counter))
      (new-id (+ counter u1))
      (board-response (initial-board))
    )
    (begin
      (match board-response board
        (begin
          (map-set games
            ((game-id new-id))
            (
              (player player)
              (board board)
              (turn true) ; player starts first
              (status "active")
              (move-history (list))
              (last-move-time block-height)
            )
          )
          (var-set game-counter new-id)
          (ok new-id)
        )
        (err u100) ; error getting initial board (should never happen)
      )
    )
  )
)


;; make-move Function (Player’s Move)
(define-public (make-move (game-id uint) (from uint) (to uint))
(define-read-only (is-white-piece (piece uint))
  (ok (and (>= piece u1) (<= piece u6))) ; 1–6 are white
)
(define-public (make-move (game-id uint) (from uint) (to uint))
  (let (
      (sender tx-sender)
      (game (map-get? games ((game-id game-id))))
    )
    (match game g
      (begin
        (if (is-eq (get status g) "active")
          (if (is-eq (get player g) sender)
            (if (get turn g) ; Player's turn = true
              (let (
                  (board (get board g))
                  (piece (element-at? from board))
                )
                (match piece p
                  (begin
                    (match (is-white-piece p) is-white
                      (if is-white
                        ;; Proceed with move
                        (let (
                            ;; Build updated board: set from = EMPTY, to = piece
                            (updated-board (replace-at? to p (replace-at? from u0 board)))
                            (history (get move-history g))
                            (new-history (append history (list (tuple (from from) (to to)))))
                          )
                          (match updated-board b
                            (begin
                              (map-set games
                                ((game-id game-id))
                                (
                                  (player sender)
                                  (board b)
                                  (turn false) ; Now it's bot's turn
                                  (status "active")
                                  (move-history new-history)
                                  (last-move-time block-height)
                                )
                              )
                              (ok true)
                            )
                            (err u101) ;; Error updating board
                          )
                        )
                        (err u103) ;; Not a white piece
                      )
                    )
                  )
                  (err u102) ;; No piece at `from`
                )
              )
              (err u104) ;; Not player's turn
            )
            (err u105) ;; Sender not player
          )
          (err u106) ;; Game not active
        )
      )
      (err u107) ;; Game not found
    )
  )
))


;;bot-move Function (Bot’s Turn)
(define-constant BOT-ADDRESS 'STB...ST33ZPTYR4ZRQCPSV22ND1AD5H2MHTYBK8ACY76A9...) ; replace with actual bot address

(define-public (bot-move (game-id uint) (from uint) (to uint))
  (let (
      (sender tx-sender)
      (game (map-get? games ((game-id game-id))))
    )
    (match game g
      (begin
        (if (is-eq (get status g) "active")
          (if (is-eq sender BOT-ADDRESS)
            (if (not (get turn g)) ; false = bot's turn
              (let (
                  (board (get board g))
                  (piece (element-at? from board))
                )
                (match piece p
                  (begin
                    (if (and (>= p u7) (<= p u12)) ; Must be black piece
                      (let (
                          (updated-board (replace-at? to p (replace-at? from u0 board)))
                          (history (get move-history g))
                          (new-history (append history (list (tuple (from from) (to to)))))
                        )
                        (match updated-board b
                          (begin
                            (map-set games
                              ((game-id game-id))
                              (
                                (player (get player g))
                                (board b)
                                (turn true) ; back to player
                                (status "active")
                                (move-history new-history)
                                (last-move-time block-height)
                              )
                            )
                            (ok true)
                          )
                          (err u201) ;; Board update failed
                        )
                      )
                      (err u202) ;; Not a black piece
                    )
                  )
                  (err u203) ;; No piece at `from`
                )
              )
              (err u204) ;; Not bot's turn
            )
            (err u205) ;; Not bot
          )
          (err u206) ;; Game not active
        )
      )
      (err u207) ;; Game not found
    )
  )
)

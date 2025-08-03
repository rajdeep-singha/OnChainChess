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
  (player2 (optional principal)) ;; pehle koi nehi rehega
   (board (list 64 uint)) 
   (turn bool)
   (status (string-ascii 32))
   (move-history (list 200 (tuple (from uint) (to uint))))
   (last-move-time uint)
    (bet-amount uint) 
  )
)

;; create game with bet logic 
(define-public (create-game)
  (let (
      (player1 tx-sender)
     (bet (stx-get-transfer-amount))
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
              (player1 player1)
              (player2 none)
              (board board)
              (turn true)
              (status "waiting")
              (move-history (list))
              (last-move-time block-height)
              (bet-amount bet)
            )
          )
          (var-set game-counter new-id)
          (ok new-id)
        )
        (err u100)
      )
    )
  )
)




(define-data-var game-counter uint u0)


(define-read-only (initial-board)
  (ok
    (list 
      u10 u8 u9 u11 u12 u9 u8 u10 ;; Black back rank
      u7 u7 u7 u7 u7 u7 u7 u7     ;; Black pawns
      u0 u0 u0 u0 u0 u0 u0 u0     ;; Empty rows
      u0 u0 u0 u0 u0 u0 u0 u0
      u0 u0 u0 u0 u0 u0 u0 u0
      u0 u0 u0 u0 u0 u0 u0 u0
        u1 u1 u1 u1 u1 u1 u1 u1     ;; White pawns
      u4 u2 u3 u5 u6 u3 u2 u4     ;; White back rank
    )
  )
)



;; join-game
(define-public (join-game (game-id uint))
  (let ((sender tx-sender))
    (match (map-get? games ((game-id game-id))) game
      (if (is-none (get player2 game))
        (let ((bet (get bet-amount game)))
          (begin
            ;; Require same bet amount
            (try! (stx-transfer? bet sender contract-principal))
            (map-set games
              ((game-id game-id))
              (
                (player1 (get player1 game))
                (player2 (some sender))
                (board (get board game))
                (turn (get turn game))
                (status "active")
                (move-history (get move-history game))
                (last-move-time block-height)
                (bet-amount bet)
              )
            )
            (ok true)
          )
        )
        (err u400) ;; Game already full
      )
    )
  )
)









;; make-move Function (Players Move)
(define-public (make-move (game-id uint) (from uint) (to uint))
  (let (
      (sender tx-sender)
      (game-opt (map-get? games ((game-id game-id))))
    )
    (match game-opt game
      (let (
          (status (get status game))
          (is-white-turn (get turn game))
          (player1 (get player1 game)) ;; white
          (player2-opt (get player2 game))
        )
        (if (is-eq status "active")
          (match player2-opt player2
            (if (or
                  (and is-white-turn (is-eq sender player1))
                  (and (not is-white-turn) (is-eq sender player2))
                )
              (let (
                  (board (get board game))
                  (piece-opt (element-at? from board))
                )
                (match piece-opt piece
                  (begin
                    (if (or
                          (and is-white-turn (is-white-piece piece))
                          (and (not is-white-turn) (not (is-white-piece piece)))
                        )
                      (let (
                          (updated-board (replace-at? to piece (replace-at? from u0 board)))
                          (move-history (get move-history game))
                          (new-history (append move-history (list (tuple (from from) (to to)))))
                        )
                        (match updated-board new-board
                          (begin
                            (map-set games
                              ((game-id game-id))
                              (
                                (player1 player1)
                                (player2 player2)
                                (board new-board)
                                (turn (not is-white-turn)) ;; switch turn
                                (status "active")
                                (move-history new-history)
                                (last-move-time block-height)
                              )
                            )
                            (ok true)
                          )
                          (err u109) ;; error updating board
                        )
                      )
                      (err u110) ;; Invalid piece move (wrong color)
                    )
                  )
                  (err u111) ;; No piece at source position
                )
              )
              (err u112) ;; Not your turn
            )
          )
          (err u113) ;; Game not active
        )
      )
      (err u114) ;; Game not found
    )
  )
)




;;bot-move Function 
(define-constant BOT-ADDRESS 'ST33ZPTYR4ZRQCPSV22ND1AD5H2MHTYBK8ACY76A9) ;; your bot address here

(define-public (bot-move (game-id uint) (from uint) (to uint))
  (let (
      (sender tx-sender)
      (game (map-get? games ((game-id game-id))))
    )
    (match game g
      (begin
        (if (is-eq (get status g) "active")
          (if (is-eq sender BOT-ADDRESS)
            (if (not (get turn g)) ;; bot's turn
              (let (
                  (board (get board g))
                  (piece (element-at? from board))
                )
                (match piece p
                  (if (and (>= p u7) (<= p u12))
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
                              (player1 (get player1 g))
                              (player2 (get player2 g))
                              (board b)
                              (turn true)
                              (status "active")
                              (move-history new-history)
                              (last-move-time block-height)
                              (bet-amount (get bet-amount g))
                            )
                          )
                          (ok true)
                        )
                        (err u701)
                      )
                    )
                    (err u702)
                  )
                )
              )
              (err u703)
            )
            (err u704)
          )
          (err u705)
        )
      )
      (err u706)
    )
  )
)


;; finish game logic 

(define-public (finish-game (game-id uint) (winner principal))
  (let (
      (game (map-get? games ((game-id game-id))))
    )
    (match game g
      (begin
        (if (is-eq (get status g) "active")
          (let (
              (bet (get bet-amount g))
            )
            (begin
              (let ((total (* bet u2)))
  (try! (stx-transfer? total contract-principal winner))
)
 ;; reward the winner
              (map-set games
                ((game-id game-id))
                (
                  (player (get player g))
                  (board (get board g))
                  (turn (get turn g))
                  (status "finished")
                  (move-history (get move-history g))
                  (last-move-time (get last-move-time g))
                  (bet-amount u0)
                )
              )
              (ok true)
            )
          )
          (err u300) ;; game not active
        )
      )
      (err u301) ;; game not found
    )
  )
)



;; resign-game 
(define-public (resign-game (game-id uint))
  (let (
      (sender tx-sender)
      (game (map-get? games ((game-id game-id))))
    )
    (match game g
      (let (
          (player1 (get player1 g))
          (player2-opt (get player2 g))
          (status (get status g))
        )
        (match player2-opt player2
          (if (is-eq status "active")
            (let (
                (bet (get bet-amount g))
                (total (* bet u2))
                (winner (if (is-eq sender player1) player2 player1))
              )
              (begin
                (try! (stx-transfer? total sender winner))
                (map-set games
                  ((game-id game-id))
                  (
                    (player1 player1)
                    (player2 (some player2))
                    (board (get board g))
                    (turn (get turn g))
                    (status "resigned")
                    (move-history (get move-history g))
                    (last-move-time (get last-move-time g))
                    (bet-amount u0)
                  )
                )
                (ok true)
              )
            )
            (err u501)
          )
        )
      )
    )
  )
)



;; draw game 
(define-map draw-proposals
  ((game-id uint))
  ((proposer principal))
)

(define-public (propose-draw (game-id uint))
  (let ((sender tx-sender))
    (map-set draw-proposals ((game-id game-id)) ((proposer sender)))
    (ok true)
  )
)

(define-public (accept-draw (game-id uint))
  (let (
      (sender tx-sender)
      (proposal (map-get? draw-proposals ((game-id game-id))))
      (game (map-get? games ((game-id game-id))))
    )
    (match proposal p
      (match game g
        (let (
            (proposer (get proposer p))
            (player1 (get player1 g))
            (player2-opt (get player2 g))
            (bet (get bet-amount g))
            (status (get status g))
          )
          (match player2-opt player2
            (if (and (is-eq status "active") (not (is-eq proposer sender)))
              (let (
                  (half (* bet u1))
                )
                (begin
                  (try! (stx-transfer? half contract-principal sender))
                  (try! (stx-transfer? half contract-principal proposer))

                  (map-set games
                    ((game-id game-id))
                    (
                      (player1 player1)
                      (player2 (some player2))
                      (board (get board g))
                      (turn (get turn g))
                      (status "draw")
                      (move-history (get move-history g))
                      (last-move-time (get last-move-time g))
                      (bet-amount u0)
                    )
                  )
                  (ok true)
                )
              )
              (err u601)
            )
          )
        )
      )
      (err u602)
    )
  )
  )

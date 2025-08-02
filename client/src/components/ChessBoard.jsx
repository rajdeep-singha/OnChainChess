import React from "react";

const initialBoard = [
  ["♜", "♞", "♝", "♛", "♚", "♝", "♞", "♜"],
  ["♟", "♟", "♟", "♟", "♟", "♟", "♟", "♟"],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["", "", "", "", "", "", "", ""],
  ["♙", "♙", "♙", "♙", "♙", "♙", "♙", "♙"],
  ["♖", "♘", "♗", "♕", "♔", "♗", "♘", "♖"],
];

const ChessBoard = () => {
  return (
    <div className="grid grid-cols-8 border-4 border-black">
      {initialBoard.flat().map((piece, idx) => {
        const row = Math.floor(idx / 8);
        const col = idx % 8;
        const isWhiteSquare = (row + col) % 2 === 0;

        // Determine color of the piece
        const isBlackPiece = row < 2; // Top two rows
        const pieceColor = isBlackPiece ? "text-violet-500" : "text-white";

        return (
          <div
            key={idx}
            className={`w-16 h-16 flex items-center justify-center text-2xl font-bold ${
              isWhiteSquare ? "bg-black" : "bg-gray-700"
            } ${piece ? pieceColor : ""}`}
          >
            {piece}
          </div>
        );
      })}
    </div>
  );
};

export default ChessBoard;

import React from "react";

export default function ChessBoard() {
  return (
    <div className="grid grid-cols-8 w-96 h-96 border-2 border-white">
      {[...Array(64)].map((_, i) => {
        const isDark = (Math.floor(i / 8) + i) % 2 === 1;
        return (
          <div
            key={i}
            className={`w-full h-full ${isDark ? "bg-gray-700" : "bg-white"}`}
          ></div>
        );
      })}
    </div>
  );
}

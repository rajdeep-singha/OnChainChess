import React, { useState } from "react";
import { showConnect } from "@stacks/connect";
import { appDetails } from "./stacks-config"; // Ensure this is properly exported
import Chessboard from "./components/ChessBoard"; // Your custom chessboard component

export default function App() {
  const [address, setAddress] = useState(null);
  // const [walletConnected, setWalletConnected] = useState(false);
  // const [playWithBot, setPlayWithBot] = useState(false);

  const handleConnect = () => {
    showConnect({
      appDetails,
      onFinish: ({ userSession }) => {
        const stxAddress = userSession.loadUserData().profile.stxAddress.testnet;
        setAddress(stxAddress);
      },
    });
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-900 text-white">
      {!address ? (
        <button
          className="bg-blue-600 text-white px-4 py-2 rounded"
          onClick={handleConnect}
        >
          Connect Wallet
        </button>
      ) : (
        <>
          <p className="mb-4 text-green-400">Connected as: {address}</p>
          <Chessboard /> {/* Visible only after wallet connection */}
        </>
      )}
    </div>
  );
}

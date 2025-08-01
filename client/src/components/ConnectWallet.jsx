import { showConnect } from "@stacks/connect";
import { userSession } from "../stacks-config"; // adjust path if needed
import { useState } from "react";
import { appDetails } from "../stacks-config"; // your appDetails config

export default function ConnectWalletButton() {
  const [address, setAddress] = useState("");

  const connectWallet = () => {
    showConnect({
      appDetails, // name and icon
      userSession,
      onFinish: () => {
        const userData = userSession.loadUserData();
        const stxAddress = userData.profile.stxAddress?.testnet;
        setAddress(stxAddress);
        console.log("Connected STX Address:", stxAddress);
      },
      onCancel: () => {
        console.log("User canceled connection.");
      },
    });
  };

  return (
    <button
      className="bg-blue-600 text-white px-4 py-2 rounded"
      onClick={connectWallet}
    >
      {address ? `Connected: ${address.slice(0, 10)}...` : "Connect Wallet"}
    </button>
  );
}

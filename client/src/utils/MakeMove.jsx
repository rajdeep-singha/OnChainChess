import {
    makeContractCall,
    uintCV,
    PostConditionMode,
  } from "@stacks/transactions";
//   import { userSession } from "./userSession";
//   import { CONTRACT_ADDRESS, CONTRACT_NAME, NETWORK, appDetails } from "../stacks-config.js";
  
  export async function MakeMove(gameId, from, to) {
    const txOptions = {
      contractAddress: CONTRACT_ADDRESS,
      contractName: CONTRACT_NAME,
      functionName: "make-move",
      functionArgs: [uintCV(gameId), uintCV(from), uintCV(to)],
      network: NETWORK,
      postConditionMode: PostConditionMode.Deny,
      appDetails,
      userSession,
    };
  
    const tx = await makeContractCall(txOptions);
    await tx.openSTXTransferPopup();
  }
  
import {
    makeContractCall,
    PostConditionMode,
  } from "@stacks/transactions";
//   import { userSession } from "./userSession";
//   import { CONTRACT_ADDRESS, CONTRACT_NAME, NETWORK, appDetails } from "../stacks-config.js";
  
  export async function createGame() {
    const txOptions = {
      contractAddress: CONTRACT_ADDRESS,
      contractName: CONTRACT_NAME,
      functionName: "create-game",
      functionArgs: [],
      network: NETWORK,
      postConditionMode: PostConditionMode.Deny,
      appDetails,
      userSession,
    };
  
    const tx = await makeContractCall(txOptions);
    await tx.openSTXTransferPopup();
  }
  
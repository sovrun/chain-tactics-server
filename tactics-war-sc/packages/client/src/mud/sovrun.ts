import * as viem_chains from "viem/chains";
// import { Chain } from "viem/chains";
import * as viem from "viem";
import * as viem_op_stack from "viem/op-stack";

declare const sovrun: {
  readonly id: 8202496;
  readonly sourceId: 17000;
  readonly name: "Sovrun Testnet";
  readonly testnet: true;
  readonly nativeCurrency: {
    readonly name: "Sovrun";
    readonly symbol: "SOVRUN";
    readonly decimals: 18;
  };
  readonly rpcUrls: {
    readonly default: {
      readonly http: readonly ["https://sovruntest.rpc.caldera.xyz/http"];
      readonly webSocket: readonly ["wss://sovruntest.rpc.caldera.xyz/ws"];
    };
  };
  readonly blockExplorers: {
    readonly default: {
      readonly name: "Caldera";
      readonly url: "https://sovruntest.explorer.caldera.xyz/";
    };
  };

  readonly iconUrls: readonly [
    "https://sovruntest.hub.caldera.xyz/svgs/frameworks/optimism.svg",
  ];
  readonly indexerUrl: "http://54.179.163.100";
  readonly formatters: {
    readonly block: {
      exclude: [] | undefined;
      format: (
        args: viem_chains.Assign<
          viem.ExactPartial<
            viem.RpcBlock<viem.BlockTag, boolean, viem.RpcTransaction<boolean>>
          >,
          viem_op_stack.OpStackRpcBlockOverrides & {
            transactions:
              | `0x${string}`[]
              | viem_op_stack.OpStackRpcTransaction<boolean>[];
          }
        >
      ) => {
        baseFeePerGas: bigint | null;
        blobGasUsed: bigint;
        difficulty: bigint;
        excessBlobGas: bigint;
        extraData: `0x${string}`;
        gasLimit: bigint;
        gasUsed: bigint;
        hash: `0x${string}` | null;
        logsBloom: `0x${string}` | null;
        miner: `0x${string}`;
        mixHash: `0x${string}`;
        nonce: `0x${string}` | null;
        number: bigint | null;
        parentHash: `0x${string}`;
        receiptsRoot: `0x${string}`;
        sealFields: `0x${string}`[];
        sha3Uncles: `0x${string}`;
        size: bigint;
        stateRoot: `0x${string}`;
        timestamp: bigint;
        totalDifficulty: bigint | null;
        transactions:
          | `0x${string}`[]
          | viem_op_stack.OpStackTransaction<boolean>[];
        transactionsRoot: `0x${string}`;
        uncles: `0x${string}`[];
        withdrawals?: viem.Withdrawal[] | undefined;
        withdrawalsRoot?: `0x${string}` | undefined;
      };
      type: "block";
    };
    readonly transaction: {
      exclude: [] | undefined;
      format: (
        args:
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  r: `0x${string}`;
                  s: `0x${string}`;
                  v: `0x${string}`;
                  to: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  nonce: `0x${string}`;
                  value: `0x${string}`;
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList?: undefined;
                  blobVersionedHashes?: undefined;
                  chainId?: `0x${string}` | undefined;
                  yParity?: undefined;
                  type: "0x0";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & Omit<
              viem.TransactionBase<`0x${string}`, `0x${string}`, boolean>,
              "typeHex"
            > &
              viem.FeeValuesEIP1559<`0x${string}`> & {
                isSystemTx?: boolean | undefined;
                mint?: `0x${string}` | undefined;
                sourceHash: `0x${string}`;
                type: "0x7e";
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  r: `0x${string}`;
                  s: `0x${string}`;
                  v: `0x${string}`;
                  to: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  nonce: `0x${string}`;
                  value: `0x${string}`;
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList?: undefined;
                  blobVersionedHashes?: undefined;
                  chainId?: `0x${string}` | undefined;
                  yParity?: undefined;
                  type: "0x0";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList: viem.AccessList;
                  blobVersionedHashes?: undefined;
                  chainId: `0x${string}`;
                  type: "0x1";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice?: undefined;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas: `0x${string}`;
                  maxPriorityFeePerGas: `0x${string}`;
                  accessList: viem.AccessList;
                  blobVersionedHashes?: undefined;
                  chainId: `0x${string}`;
                  type: "0x2";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & Omit<
              viem.TransactionBase<`0x${string}`, `0x${string}`, boolean>,
              "typeHex"
            > &
              viem.FeeValuesEIP1559<`0x${string}`> & {
                isSystemTx?: boolean | undefined;
                mint?: `0x${string}` | undefined;
                sourceHash: `0x${string}`;
                type: "0x7e";
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  r: `0x${string}`;
                  s: `0x${string}`;
                  v: `0x${string}`;
                  to: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  nonce: `0x${string}`;
                  value: `0x${string}`;
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList?: undefined;
                  blobVersionedHashes?: undefined;
                  chainId?: `0x${string}` | undefined;
                  yParity?: undefined;
                  type: "0x0";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList: viem.AccessList;
                  blobVersionedHashes?: undefined;
                  chainId: `0x${string}`;
                  type: "0x1";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice?: undefined;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas: `0x${string}`;
                  maxPriorityFeePerGas: `0x${string}`;
                  accessList: viem.AccessList;
                  blobVersionedHashes?: undefined;
                  chainId: `0x${string}`;
                  type: "0x2";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & Omit<
              viem.TransactionBase<`0x${string}`, `0x${string}`, boolean>,
              "typeHex"
            > &
              viem.FeeValuesEIP1559<`0x${string}`> & {
                isSystemTx?: boolean | undefined;
                mint?: `0x${string}` | undefined;
                sourceHash: `0x${string}`;
                type: "0x7e";
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: `0x${string}`[] | undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  r: `0x${string}`;
                  s: `0x${string}`;
                  v: `0x${string}`;
                  to: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  nonce: `0x${string}`;
                  value: `0x${string}`;
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList?: undefined;
                  blobVersionedHashes?: undefined;
                  chainId?: `0x${string}` | undefined;
                  yParity?: undefined;
                  type: "0x0";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: `0x${string}`[] | undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice: `0x${string}`;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas?: undefined;
                  maxPriorityFeePerGas?: undefined;
                  accessList: viem.AccessList;
                  blobVersionedHashes?: undefined;
                  chainId: `0x${string}`;
                  type: "0x1";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: `0x${string}`[] | undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice?: undefined;
                  maxFeePerBlobGas?: undefined;
                  maxFeePerGas: `0x${string}`;
                  maxPriorityFeePerGas: `0x${string}`;
                  accessList: viem.AccessList;
                  blobVersionedHashes?: undefined;
                  chainId: `0x${string}`;
                  type: "0x2";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: `0x${string}`[] | undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & viem_chains.Omit<
              viem_chains.PartialBy<
                {
                  blockHash: `0x${string}` | null;
                  blockNumber: `0x${string}` | null;
                  from: `0x${string}`;
                  gas: `0x${string}`;
                  hash: `0x${string}`;
                  input: `0x${string}`;
                  nonce: `0x${string}`;
                  r: `0x${string}`;
                  s: `0x${string}`;
                  to: `0x${string}` | null;
                  transactionIndex: `0x${string}` | null;
                  typeHex: `0x${string}` | null;
                  v: `0x${string}`;
                  value: `0x${string}`;
                  yParity: `0x${string}`;
                  gasPrice?: undefined;
                  maxFeePerBlobGas: `0x${string}`;
                  maxFeePerGas: `0x${string}`;
                  maxPriorityFeePerGas: `0x${string}`;
                  accessList: viem.AccessList;
                  blobVersionedHashes: `0x${string}`[];
                  chainId: `0x${string}`;
                  type: "0x3";
                },
                "yParity"
              >,
              "typeHex"
            > & {
                isSystemTx?: undefined;
                mint?: undefined;
                sourceHash?: undefined;
              })
          | ({
              r?: `0x${string}` | undefined;
              s?: `0x${string}` | undefined;
              v?: `0x${string}` | undefined;
              yParity?: `0x${string}` | undefined;
              gasPrice?: `0x${string}` | undefined;
              maxFeePerBlobGas?: `0x${string}` | undefined;
              maxFeePerGas?: `0x${string}` | undefined;
              maxPriorityFeePerGas?: `0x${string}` | undefined;
              to?: `0x${string}` | null | undefined;
              from?: `0x${string}` | undefined;
              gas?: `0x${string}` | undefined;
              nonce?: `0x${string}` | undefined;
              value?: `0x${string}` | undefined;
              type?: "0x0" | "0x1" | "0x2" | "0x3" | "0x7e" | undefined;
              accessList?: viem.AccessList | undefined;
              blobVersionedHashes?: `0x${string}`[] | undefined;
              blockHash?: `0x${string}` | null | undefined;
              blockNumber?: `0x${string}` | null | undefined;
              hash?: `0x${string}` | undefined;
              input?: `0x${string}` | undefined;
              transactionIndex?: `0x${string}` | null | undefined;
              chainId?: `0x${string}` | undefined;
            } & Omit<
              viem.TransactionBase<`0x${string}`, `0x${string}`, boolean>,
              "typeHex"
            > &
              viem.FeeValuesEIP1559<`0x${string}`> & {
                isSystemTx?: boolean | undefined;
                mint?: `0x${string}` | undefined;
                sourceHash: `0x${string}`;
                type: "0x7e";
              })
      ) =>
        | {
            r: `0x${string}`;
            s: `0x${string}`;
            v: bigint;
            to: `0x${string}` | null;
            from: `0x${string}`;
            gas: bigint;
            nonce: number;
            value: bigint;
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            hash: `0x${string}`;
            input: `0x${string}`;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            gasPrice: bigint;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas?: undefined;
            maxPriorityFeePerGas?: undefined;
            accessList?: undefined;
            blobVersionedHashes?: undefined;
            chainId?: number | undefined;
            yParity?: undefined;
            type: "legacy";
            isSystemTx?: undefined;
            mint?: undefined;
            sourceHash?: undefined;
          }
        | {
            r: `0x${string}`;
            s: `0x${string}`;
            v: bigint;
            to: `0x${string}` | null;
            from: `0x${string}`;
            gas: bigint;
            nonce: number;
            value: bigint;
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            hash: `0x${string}`;
            input: `0x${string}`;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            gasPrice: undefined;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList?: undefined;
            blobVersionedHashes?: undefined;
            chainId?: number | undefined;
            yParity: number;
            type: "deposit";
            isSystemTx?: boolean | undefined;
            mint?: bigint | undefined;
            sourceHash: `0x${string}`;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice: bigint;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas?: undefined;
            maxPriorityFeePerGas?: undefined;
            accessList: viem.AccessList;
            blobVersionedHashes?: undefined;
            chainId: number;
            type: "eip2930";
            isSystemTx?: undefined;
            mint?: undefined;
            sourceHash?: undefined;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice: undefined;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList: viem.AccessList;
            blobVersionedHashes?: undefined;
            chainId: number;
            type: "eip1559";
            isSystemTx?: undefined;
            mint?: undefined;
            sourceHash?: undefined;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice: undefined;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList: viem.AccessList;
            blobVersionedHashes?: undefined;
            chainId: number;
            type: "deposit";
            isSystemTx?: boolean | undefined;
            mint?: bigint | undefined;
            sourceHash: `0x${string}`;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice: bigint;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas: undefined;
            maxPriorityFeePerGas: undefined;
            accessList: viem.AccessList;
            blobVersionedHashes?: undefined;
            chainId: number;
            type: "eip2930";
            isSystemTx?: undefined;
            mint?: undefined;
            sourceHash?: undefined;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice?: undefined;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList: viem.AccessList;
            blobVersionedHashes?: undefined;
            chainId: number;
            type: "eip1559";
            isSystemTx?: undefined;
            mint?: undefined;
            sourceHash?: undefined;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice?: undefined;
            maxFeePerBlobGas?: undefined;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList: viem.AccessList;
            blobVersionedHashes?: undefined;
            chainId: number;
            type: "deposit";
            isSystemTx?: boolean | undefined;
            mint?: bigint | undefined;
            sourceHash: `0x${string}`;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice?: undefined;
            maxFeePerBlobGas: bigint;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList: viem.AccessList;
            blobVersionedHashes: `0x${string}`[];
            chainId: number;
            type: "eip4844";
            isSystemTx?: undefined;
            mint?: undefined;
            sourceHash?: undefined;
          }
        | {
            blockHash: `0x${string}` | null;
            blockNumber: bigint | null;
            from: `0x${string}`;
            gas: bigint;
            hash: `0x${string}`;
            input: `0x${string}`;
            nonce: number;
            r: `0x${string}`;
            s: `0x${string}`;
            to: `0x${string}` | null;
            transactionIndex: number | null;
            typeHex: `0x${string}` | null;
            v: bigint;
            value: bigint;
            yParity: number;
            gasPrice?: undefined;
            maxFeePerBlobGas: undefined;
            maxFeePerGas: bigint;
            maxPriorityFeePerGas: bigint;
            accessList: viem.AccessList;
            blobVersionedHashes: `0x${string}`[];
            chainId: number;
            type: "deposit";
            isSystemTx?: boolean | undefined;
            mint?: bigint | undefined;
            sourceHash: `0x${string}`;
          };
      type: "transaction";
    };
    readonly transactionReceipt: {
      exclude: [] | undefined;
      format: (
        args: viem_chains.Assign<
          viem.ExactPartial<viem.RpcTransactionReceipt>,
          viem_op_stack.OpStackRpcTransactionReceiptOverrides
        >
      ) => {
        blobGasPrice?: bigint | undefined;
        blobGasUsed?: bigint | undefined;
        blockHash: `0x${string}`;
        blockNumber: bigint;
        contractAddress: `0x${string}` | null | undefined;
        cumulativeGasUsed: bigint;
        effectiveGasPrice: bigint;
        from: `0x${string}`;
        gasUsed: bigint;
        logs: viem.Log<
          bigint,
          number,
          false,
          undefined,
          undefined,
          undefined,
          undefined
        >[];
        logsBloom: `0x${string}`;
        root?: `0x${string}` | undefined;
        status: "success" | "reverted";
        to: `0x${string}` | null;
        transactionHash: `0x${string}`;
        transactionIndex: number;
        type: viem.TransactionType;
        l1GasPrice: bigint | null;
        l1GasUsed: bigint | null;
        l1Fee: bigint | null;
        l1FeeScalar: number | null;
      };
      type: "transactionReceipt";
    };
  };
  readonly serializers: {
    readonly transaction: typeof viem_op_stack.serializeTransaction;
  };
};

export { sovrun };

export default sovrun;

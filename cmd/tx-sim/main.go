package main

import (
	"context"
	"fmt"
	"os"

	"github.com/cosmos/cosmos-sdk/types/tx"
	"google.golang.org/grpc"
)

func main() {
	simulateTx()
}

func simulateTx() error {

	// Create connection to the gRPC server.
	grpcConn, err := grpc.Dial(
		"localhost:9081",
		grpc.WithInsecure(),
		grpc.WithDefaultCallOptions(grpc.MaxCallRecvMsgSize(1024*1024*1024), grpc.MaxCallSendMsgSize(1024*1024*1024)),
	)

	// check if connection was successful
	if err != nil {
		fmt.Println(err)
		return err
	} else {
		fmt.Println("successfully connected")
	}
	// defer close the connection
	defer grpcConn.Close()

	//create a new client for the Protobuf Txservice.
	txClient := tx.NewServiceClient(grpcConn)

	txBytes, err := os.ReadFile("../../scripts/standalone-node/tx-data/encoded-signed-tx.txt") // read protobuf-encoded txytes from file
	if err != nil {
		fmt.Print(err)
		return err
	}

	fmt.Print(txBytes)

	// We then call the Simulate method on this client.
	grpcRes, err := txClient.Simulate(
		context.Background(),
		&tx.SimulateRequest{
			TxBytes: txBytes,
		},
	)
	if err != nil {
		fmt.Println(err) // print any error
		return err
	} else {
		fmt.Println(grpcRes.GasInfo) // Prints estimated gas used.
	}

	return nil
}

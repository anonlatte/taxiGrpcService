package main

const (
	// apiVersion is version of API is provided by server
	apiVersion = "v1"
)

func main() {
	/*	// get configuration
		address := flag.String("server", "", "gRPC server in format host:port")
		flag.Parse()

		// Set up a connection to the server.
		conn, err := grpc.Dial(*address, grpc.WithInsecure())
		if err != nil {
			log.Fatalf("did not connect: %v", err)
		}
		defer conn.Close()

		c := v1.NewTaxiServiceClient(conn)

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		t := time.Now().In(time.UTC)
		pfx := t.Format(time.RFC3339Nano)

		// Call Create
		req1 := v1.CreateUserRequest{
			Api: apiVersion,
			User: &v1.User{
				Login:    "login" + pfx,
				Password: "password" + pfx + "",
				Email:    "example_" + pfx + "@example.com",
			},
		}
		res1, err := c.CreateUser(ctx, &req1)
		if err != nil {
			log.Fatalf("Create failed: %v", err)
		}
		log.Printf("Create result: <%+v>\n\n", res1)

		req2 := v1.CreatePaymentMethodRequest{
			Api: apiVersion,
			PaymentMethod: &v1.PaymentMethod{
				TypeName: "Webmoney",
			},
		}
		res2, err := c.CreatePaymentMethod(ctx, &req2)
		if err != nil {
			log.Fatalf("Create failed: %v", err)
		}
			log.Printf("Create result: <%+v>\n\n", res2)*/

}

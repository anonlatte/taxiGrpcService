package v1

import (
	"context"
	"crypto/sha512"
	"database/sql"
	"fmt"
	"golangService/pkg/api/v1"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"math/rand"
	"time"
)

const (
	// apiVersion is version of API is provided by server
	apiVersion = "v1"
)

// TODO: validate request data on server

// taxiServiceServer is implementation of v1.taxiServiceServer proto interface
type taxiServiceServer struct {
	db *sql.DB
}

// NewTaxiServiceServer creates taxi service
func NewTaxiServiceServer(db *sql.DB) v1.TaxiServiceServer {
	return &taxiServiceServer{db: db}
}

// checkAPI checks if the API version requested by client is supported by server
func (s *taxiServiceServer) checkAPI(api string) error {
	// API version is "" means use current version of the service
	if len(api) > 0 {
		if apiVersion != api {
			return status.Errorf(codes.Unimplemented,
				"unsupported API version: service implements API version '%s', but asked for '%s'", apiVersion, api)
		}
	}
	return nil
}

// connect returns SQL database connection from the pool
func (s *taxiServiceServer) connect(ctx context.Context) (*sql.Conn, error) {
	c, err := s.db.Conn(ctx)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to connect to database-> "+err.Error())
	}
	return c, nil
}

func RandStringBytesMaskImprSrc(n int) string {
	const letterBytes = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	const (
		letterIdxBits = 6                    // 6 bits to represent a letter index
		letterIdxMask = 1<<letterIdxBits - 1 // All 1-bits, as many as letterIdxBits
		letterIdxMax  = 63 / letterIdxBits   // # of letter indices fitting in 63 bits
	)

	var src = rand.NewSource(time.Now().UnixNano())
	b := make([]byte, n)
	// A src.Int63() generates 63 random bits, enough for letterIdxMax characters!
	for i, cache, remain := n-1, src.Int63(), letterIdxMax; i >= 0; {
		if remain == 0 {
			cache, remain = src.Int63(), letterIdxMax
		}
		if idx := int(cache & letterIdxMask); idx < len(letterBytes) {
			b[i] = letterBytes[idx]
			i--
		}
		cache >>= letterIdxBits
		remain--
	}
	return string(b)
}

func (s *taxiServiceServer) LoginUser(ctx context.Context, req *v1.LoginRequest) (*v1.LoginResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}
	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	if req.UserType == 0 { // For customer data
		rows, err := c.QueryContext(ctx, "SELECT password, id FROM taxi.customer WHERE `phone_number`=?",
			req.Login)

		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to select from Customer-> "+err.Error())
		}
		defer rows.Close()

		if !rows.Next() {
			if err := rows.Err(); err != nil {
				return nil, status.Error(codes.Unknown, "failed to retrieve data from Customer-> "+err.Error())
			}
			return nil, status.Error(codes.NotFound, fmt.Sprintf("Customer with phone_number='%s' is not found",
				req.Login))
		}

		var td v1.Customer
		if err := rows.Scan(&td.Password, &td.Id); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Customer row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Customer rows with phone_number='%s'",
				req.Login))
		}
		passwordSha512 := sha512.New()
		passwordSha512.Write([]byte(req.Password))
		hashedPass := fmt.Sprintf("%x", passwordSha512.Sum(nil))
		authToken := RandStringBytesMaskImprSrc(32)
		if hashedPass == td.Password {
			rows, err := c.QueryContext(ctx, "UPDATE customer SET authToken=? WHERE `phone_number`=?",
				authToken, req.Login)
			if err != nil {
				return nil, status.Error(codes.Unknown, "failed to set token to Customer-> "+err.Error())
			}
			defer rows.Close()
			return &v1.LoginResponse{
				Api:       apiVersion,
				AuthToken: authToken,
				UserId:    int32(td.Id),
			}, nil
		} else {
			return nil, status.Error(codes.PermissionDenied, fmt.Sprintf("Wrong password!"))
		}
	} else if req.UserType == 1 {
		rows, err := c.QueryContext(ctx, "SELECT password, id FROM taxi.driver WHERE `phone_number`=?",
			req.Login)

		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to select from Driver-> "+err.Error())
		}
		defer rows.Close()

		if !rows.Next() {
			if err := rows.Err(); err != nil {
				return nil, status.Error(codes.Unknown, "failed to retrieve data from Driver-> "+err.Error())
			}
			return nil, status.Error(codes.NotFound, fmt.Sprintf("Driver with phone_number='%s' is not found",
				req.Login))
		}

		var td v1.Driver
		if err := rows.Scan(&td.Password, &td.Id); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Driver row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Driver rows with phone_number='%s'",
				req.Login))
		}
		passwordSha512 := sha512.New()
		passwordSha512.Write([]byte(req.Password))
		hashedPass := fmt.Sprintf("%x", passwordSha512.Sum(nil))
		authToken := RandStringBytesMaskImprSrc(32)
		if hashedPass == td.Password {
			rows, err := c.QueryContext(ctx, "UPDATE driver SET authToken=? WHERE `phone_number`=?",
				authToken, req.Login)
			if err != nil {
				return nil, status.Error(codes.Unknown, "failed to set token to Driver-> "+err.Error())
			}
			defer rows.Close()
			return &v1.LoginResponse{
				Api:       apiVersion,
				AuthToken: authToken,
				UserId:    int32(td.Id),
			}, nil
		} else {
			return nil, status.Error(codes.PermissionDenied, fmt.Sprintf("Wrong password!"))
		}
	} else {
		rows, err := c.QueryContext(ctx, "SELECT password, id FROM taxi.dispatcher WHERE `phone_number`=?",
			req.Login)

		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to select from Dispatcher-> "+err.Error())
		}
		defer rows.Close()

		if !rows.Next() {
			if err := rows.Err(); err != nil {
				return nil, status.Error(codes.Unknown, "failed to retrieve data from Dispatcher-> "+err.Error())
			}
			return nil, status.Error(codes.NotFound, fmt.Sprintf("Dispatcher with phone_number='%s' is not found",
				req.Login))
		}

		var td v1.Dispatcher
		if err := rows.Scan(&td.Password, &td.Id); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Dispatcher row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Dispatcher rows with phone_number='%s'",
				req.Login))
		}
		passwordSha512 := sha512.New()
		passwordSha512.Write([]byte(req.Password))
		hashedPass := fmt.Sprintf("%x", passwordSha512.Sum(nil))
		authToken := RandStringBytesMaskImprSrc(32)
		if hashedPass == td.Password {
			rows, err := c.QueryContext(ctx, "UPDATE dispatcher SET authToken=? WHERE `phone_number`=?",
				authToken, req.Login)
			if err != nil {
				return nil, status.Error(codes.Unknown, "failed to set token to Dispatcher-> "+err.Error())
			}
			defer rows.Close()
			return &v1.LoginResponse{
				Api:       apiVersion,
				AuthToken: authToken,
				UserId:    int32(td.Id),
			}, nil
		} else {
			return nil, status.Error(codes.PermissionDenied, fmt.Sprintf("Wrong password!"))
		}

	}
}

func (s *taxiServiceServer) TokenCheck(ctx context.Context, req *v1.TokenCheckRequest) (*v1.TokenCheckResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	if req.UserType == 0 { // Customer
		rows, err := c.QueryContext(ctx, "SELECT authToken FROM taxi.customer WHERE `phone_number`=?",
			req.Login)

		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to select from Customer-> "+err.Error())
		}
		defer rows.Close()

		if !rows.Next() {
			if err := rows.Err(); err != nil {
				return nil, status.Error(codes.Unknown, "failed to retrieve data from Customer-> "+err.Error())
			}
			return nil, status.Error(codes.NotFound, fmt.Sprintf("Customer with phone_number='%s' is not found",
				req.Login))
		}

		var td v1.Customer
		if err := rows.Scan(&td.AuthToken); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Customer row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Customer rows with phone_number='%s'",
				req.Login))
		}
		if req.AuthToken == td.AuthToken {
			if err != nil {
				return nil, status.Error(codes.Unknown, "failed to set token to Customer-> "+err.Error())
			}
			defer rows.Close()
			return &v1.TokenCheckResponse{
				Api:          apiVersion,
				IsValidToken: true,
			}, nil
		} else {
			return nil, status.Error(codes.Unauthenticated, fmt.Sprintf("Wrong token!"))
		}
	} else if req.UserType == 1 { // Driver
		rows, err := c.QueryContext(ctx, "SELECT authToken FROM taxi.driver WHERE `phone_number`=?",
			req.Login)
		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to select from Driver-> "+err.Error())
		}
		defer rows.Close()

		if !rows.Next() {
			if err := rows.Err(); err != nil {
				return nil, status.Error(codes.Unknown, "failed to retrieve data from Driver-> "+err.Error())
			}
			return nil, status.Error(codes.NotFound, fmt.Sprintf("Driver with phone_number='%s' is not found",
				req.Login))
		}

		var td v1.Driver
		if err := rows.Scan(&td.AuthToken); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Driver row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Driver rows with phone_number='%s'",
				req.Login))
		}
		if req.AuthToken == td.AuthToken {
			if err != nil {
				return nil, status.Error(codes.Unknown, "failed to set token to Driver-> "+err.Error())
			}
			defer rows.Close()
			return &v1.TokenCheckResponse{
				Api:          apiVersion,
				IsValidToken: true,
			}, nil
		} else {
			return nil, status.Error(codes.Unauthenticated, fmt.Sprintf("Wrong token!"))
		}
	} else { // Dispatcher
		rows, err := c.QueryContext(ctx, "SELECT authToken FROM taxi.dispatcher WHERE `phone_number`=?",
			req.Login)

		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to select from Dispatcher-> "+err.Error())
		}
		defer rows.Close()

		if !rows.Next() {
			if err := rows.Err(); err != nil {
				return nil, status.Error(codes.Unknown, "failed to retrieve data from Dispatcher-> "+err.Error())
			}
			return nil, status.Error(codes.NotFound, fmt.Sprintf("Dispatcher with phone_number='%s' is not found",
				req.Login))
		}

		var td v1.Dispatcher
		if err := rows.Scan(&td.AuthToken); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Dispatcher row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Dispatcher rows with phone_number='%s'",
				req.Login))
		}
		if req.AuthToken == td.AuthToken {
			if err != nil {
				return nil, status.Error(codes.Unknown, "failed to set token to Dispatcher-> "+err.Error())
			}
			defer rows.Close()
			return &v1.TokenCheckResponse{
				Api:          apiVersion,
				IsValidToken: true,
			}, nil
		} else {
			return nil, status.Error(codes.Unauthenticated, fmt.Sprintf("Wrong token!"))
		}
	}
}

// customer CRUD
func (s *taxiServiceServer) CreateCustomer(ctx context.Context, req *v1.CreateCustomerRequest) (*v1.CreateCustomerResponse, error) {
	// check if the API version requested by client is supported by server
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	// get SQL connection from pool
	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// insert user entity data
	// SHA512 Encrypt
	authToken := RandStringBytesMaskImprSrc(32)
	passwordSha512 := sha512.New()
	passwordSha512.Write([]byte(req.Customer.Password))
	hashedPass := fmt.Sprintf("%x", passwordSha512.Sum(nil))
	res, err := c.ExecContext(ctx, "INSERT INTO customer(name, phone_number, email, password, authToken) VALUES(?, ?, ?, ?, ?)",
		req.Customer.Name, req.Customer.PhoneNumber, req.Customer.Email, hashedPass, authToken)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into Customer -> "+err.Error())
	}

	// get ID of creates user
	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created Customer -> "+err.Error())
	}
	fmt.Println("Customer \"" + req.Customer.PhoneNumber + "\" has been created!")
	return &v1.CreateCustomerResponse{
		Api:       apiVersion,
		Id:        int32(id),
		AuthToken: authToken,
	}, nil
}

// TODO: requests with token
func (s *taxiServiceServer) ReadCustomer(ctx context.Context, req *v1.ReadCustomerRequest) (*v1.ReadCustomerResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	// query Customer by phone_number
	rows, err := c.QueryContext(ctx, "SELECT id, name, phone_number, email FROM taxi.customer WHERE `phone_number`=?",
		req.Customer.PhoneNumber)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Customer-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Customer-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("Customer with phone_number='%s' is not found",
			req.Customer.PhoneNumber))
	}

	// get user data
	var td v1.Customer
	if err := rows.Scan(&td.Id, &td.Name, &td.PhoneNumber, &td.Email); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from Customer row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Customer rows with phone_number='%s'",
			req.Customer.PhoneNumber))
	}

	return &v1.ReadCustomerResponse{
		Api:      apiVersion,
		Customer: &td,
	}, nil
}

func (s *taxiServiceServer) UpdateCustomer(ctx context.Context, req *v1.UpdateCustomerRequest) (*v1.UpdateCustomerResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// update Customer password
	// TODO: check what to update - email or password?
	sha_512 := sha512.New()
	sha_512.Write([]byte(req.Customer.Password))
	hashedPass := fmt.Sprintf("%x", sha_512.Sum(nil))
	res, err := c.ExecContext(ctx, "UPDATE customer SET `email`=?, `password`=? WHERE `phone_number`=?",
		req.Customer.Email, hashedPass, req.Customer.PhoneNumber)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update Customer-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("Customer with login='%d' is not found",
			req.Customer.Id))
	}

	return &v1.UpdateCustomerResponse{
		Api:     apiVersion,
		Updated: int32(rows),
	}, nil
}

func (s *taxiServiceServer) DeleteCustomer(ctx context.Context, req *v1.DeleteCustomerRequest) (*v1.DeleteCustomerResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// delete user
	res, err := c.ExecContext(ctx, "DELETE FROM customer WHERE `phone_number`=?", req.Customer.PhoneNumber)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to delete Customer-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("Customer with phone_number='%s' is not found",
			req.Customer.PhoneNumber))
	}

	return &v1.DeleteCustomerResponse{
		Api:     apiVersion,
		Deleted: int32(rows),
	}, nil
}

func (s *taxiServiceServer) CreateCabRide(ctx context.Context, req *v1.CreateCabRideRequest) (*v1.CreateCabRideResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}
	// TODO: Test this func
	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	res, err := c.ExecContext(ctx, "INSERT INTO cab_ride(customer_id, GPS_starting_point, entrance, GPS_destination, order_for_another, pending_order, payment_type_id, comment) VALUES(?, ?, ? ,?, ?, ?, ?, ?)",
		req.CabRide.CustomerId, req.CabRide.StartingPoint, req.CabRide.Entrance, req.CabRide.EndingPoint, req.CabRide.OrderForAnother, req.CabRide.PendingOrder, req.CabRide.PaymentTypeId, req.CabRide.Comment)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into cab_ride -> "+err.Error())
	}

	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created cab_ride -> "+err.Error())
	}
	fmt.Println("cab_ride \"" + string(req.CabRide.Id) + "\" has been created!")

	res, err = c.ExecContext(ctx, "INSERT INTO cab_ride_status(cab_ride_id) VALUES(?)", id)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into cab_ride_status -> "+err.Error())
	}

	fmt.Println("cab_ride_status \"" + string(req.CabRide.Id) + "\" has been created!")

	return &v1.CreateCabRideResponse{
		Api:       apiVersion,
		CabRideId: int32(id),
	}, nil
}
func (s *taxiServiceServer) DeleteCabRide(ctx context.Context, req *v1.DeleteCabRideRequest) (*v1.DeleteCabRideResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}
	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// Token check
	rows, err := c.QueryContext(ctx, "SELECT authToken FROM taxi.customer WHERE `id`=?",
		req.CustomerId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Customer-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Customer-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("Customer with id='%d' is not found",
			req.CustomerId))
	}

	var td v1.Customer
	if err := rows.Scan(&td.AuthToken); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from Customer row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Customer rows with id='%d'",
			req.CustomerId))
	}
	if req.AuthToken == td.AuthToken {
		defer rows.Close()
		// Deleting cab_ride
		res, err := c.ExecContext(ctx, "DELETE FROM cab_ride WHERE `id`=?", req.CabRideId)
		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to delete cab_ride-> "+err.Error())
		}

		rows, err := res.RowsAffected()
		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
		}

		if rows == 0 {
			return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
				req.CabRideId))
		}
		return &v1.DeleteCabRideResponse{
			Api:              apiVersion,
			IsSuccessDeleted: true,
		}, nil
	} else {
		return nil, status.Error(codes.Unauthenticated, fmt.Sprintf("Wrong token!"))
	}
}

// TODO: update cab_ride
/*func (s *taxiServiceServer) UpdateCabRide(ctx context.Context, req *v1.UpdateCabRideRequest) (*v1.UpdateCabRideResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

}
*/

func (s *taxiServiceServer) CheckCabRideStatus(ctx context.Context, req *v1.CheckCabRideStatusRequest) (*v1.CheckCabRideStatusResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	// query Customer by phone_number
	rows, err := c.QueryContext(ctx, "call taxi.cabRideStatusCheck(?)",
		req.CabRideId)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from cab_ride-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from cab_ride-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.CabRideId))
	}

	// get user data
	type responseTD struct {
		FirstName    string
		Surname      string
		PhoneNumber  string
		LicensePlate int32
		Color        string
		ModelName    string
		BrandName    string
		RideStatus   int32
	}
	var td responseTD
	if err := rows.Scan(&td.FirstName, &td.Surname, &td.PhoneNumber, &td.LicensePlate, &td.Color, &td.ModelName, &td.BrandName, &td.RideStatus); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from tables row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple cab_rides rows with id='%d'",
			req.CabRideId))
	}
	return &v1.CheckCabRideStatusResponse{
		Api:          apiVersion,
		FirstName:    td.FirstName,
		Surname:      td.Surname,
		PhoneNumber:  td.PhoneNumber,
		LicensePlate: td.LicensePlate,
		Color:        td.Color,
		ModelName:    td.ModelName,
		BrandName:    td.BrandName,
		RideStatus:   td.RideStatus,
	}, nil
}

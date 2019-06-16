package v1

import (
	"context"
	"crypto/sha512"
	"database/sql"
	"fmt"
	"github.com/go-sql-driver/mysql"
	"github.com/golang/protobuf/ptypes"
	"github.com/golang/protobuf/ptypes/timestamp"
	v1 "golang-service/src/pkg/api/v1"
	_ "golang.org/x/net/context"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"io/ioutil"
	"math/rand"
	"os"
	"strconv"
	"time"
)

const (
	// apiVersion is version of API is provided by server
	apiVersion     = "v1"
	DOCUMENTS_PATH = "documents/"
)

// TODO: validate request data on server
// FIXME: LastInsertID returns invalid value

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

func passwordGenerate(unhashedPassword string) string {
	passwordSha512 := sha512.New()
	passwordSha512.Write([]byte(unhashedPassword))
	hashedPass := fmt.Sprintf("%x", passwordSha512.Sum(nil))
	return hashedPass
}

func savePhoto(byteArray []byte, path string) (string, error) {
	fileName := RandStringBytesMaskImprSrc(32) + ".webp"
	err := ioutil.WriteFile(path+fileName, byteArray, os.ModePerm)
	if err != nil {
		return "", status.Error(codes.InvalidArgument, "Failed to save a photo "+err.Error())
	}
	return fileName, nil
}

// TODO: cleanup excess checkApi && checkConnection code
// TODO: cleanup excess tokenCheck code
/*func (s *taxiServiceServer) isTokenValid (ctx context.Context) bool {

}*/

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

		hashedPass := passwordGenerate(req.Password)
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
		hashedPass := passwordGenerate(req.Password)
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
		hashedPass := passwordGenerate(req.Password)
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
	hashedPass := passwordGenerate(req.Customer.Password)
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

func (s *taxiServiceServer) ReadAllCustomers(ctx context.Context, req *v1.ReadAllCustomersRequest) (*v1.ReadAllCustomersResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT id, name, phone_number, email, create_time FROM customer")

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Car_model -> "+err.Error())
	}
	defer rows.Close()

	var customers []*v1.Customer
	var createTime time.Time
	for rows.Next() {
		td := new(v1.Customer)
		if err := rows.Scan(&td.Id, &td.Name, &td.PhoneNumber, &td.Email, &createTime); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Driver-> "+err.Error())
		}
		td.CreateTime = parseDate(createTime)
		customers = append(customers, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Driver-> "+err.Error())
	}

	return &v1.ReadAllCustomersResponse{
		Api:      apiVersion,
		Customer: customers,
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
	hashedPass := passwordGenerate(req.Customer.Password)
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
	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	res, err := c.ExecContext(ctx, "INSERT INTO cab_ride(customer_id, GPS_starting_point, entrance, GPS_destination, order_for_another, pending_order, payment_type_id, price, comment) VALUES(?, ?, ?, ? ,?, ?, ?, ?, ?)",
		req.CabRide.CustomerId, req.CabRide.StartingPoint, req.CabRide.Entrance, req.CabRide.EndingPoint, req.CabRide.OrderForAnother, req.CabRide.PendingOrder, req.CabRide.PaymentTypeId, req.Price, req.CabRide.Comment)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into cab_ride -> "+err.Error())
	}

	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created cab_ride -> "+err.Error())
	}
	fmt.Println("cab_ride " + string(id) + " has been created!")

	res, err = c.ExecContext(ctx, "INSERT INTO cab_ride_status(cab_ride_id) VALUES(?)", id)

	if res != nil {
		id, err = res.LastInsertId()
	}
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into cab_ride_status -> "+err.Error())
	}

	fmt.Println("cab_ride_status " + string(id) + " has been created!")

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
	/*
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
		}*/

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

}

// TODO: update cab_ride
func (s *taxiServiceServer) UpdateCabRide(ctx context.Context, req *v1.UpdateCabRideRequest) (*v1.UpdateCabRideResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) CreateDriver(ctx context.Context, req *v1.CreateDriverRequest) (*v1.CreateDriverResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	// Parse unix timestamp from request and format to mysql timestamp. Divide by 1000 because Android sends milliseconds
	birthDate, err := strconv.ParseInt(fmt.Sprintf("%d", req.Driver.BirthDate.GetSeconds()/1000), 10, 64)
	if err != nil {
		panic(err)
	}
	parsedBirthDate := time.Unix(birthDate, 0).Format("2006-01-02 15:04:05")
	expiryDate, err := strconv.ParseInt(fmt.Sprintf("%d", req.Driver.BirthDate.GetSeconds()/1000), 10, 64)
	if err != nil {
		panic(err)
	}
	parsedExpiryDate := time.Unix(expiryDate, 0).Format("2006-01-02 15:04:05")

	authToken := RandStringBytesMaskImprSrc(32)
	hashedPass := passwordGenerate(req.Driver.Password)
	res, err := c.ExecContext(ctx, "INSERT INTO driver(first_name, surname, patronymic, birth_date, phone_number, email, password, authToken) VALUES(?, ?, ?, ?, ?, ?, ?, ?)",
		req.Driver.FirstName, req.Driver.Surname, req.Driver.Partronymic, parsedBirthDate, req.Driver.PhoneNumber, req.Driver.Email, hashedPass, authToken)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into Driver -> "+err.Error())
	}

	driverId, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created Driver -> "+err.Error())
	}
	fmt.Println("Driver \"" + req.Driver.PhoneNumber + "\" has been created!")

	folderPath := fmt.Sprintf(DOCUMENTS_PATH+"/drivers/%d/", driverId)
	if _, err = os.Stat(folderPath); os.IsNotExist(err) {
		err = os.MkdirAll(folderPath, os.ModePerm)
		if err != nil {
			println("Filed to create dir " + fmt.Sprintf("documents/%d", driverId))
			return nil, err
		}
	} else {
		println("Dir " + folderPath + " is exists")
		return nil, err
	}

	passportImagePath, err := savePhoto(req.DriverDocuments.PassportImage, folderPath)
	if err != nil {
		println("Filed to load passport photo")
		return nil, err
	}

	drivingLicenseImagePath, err := savePhoto(req.DriverDocuments.DrivingLicenseImage, folderPath)
	if err != nil {
		println("Filed to load passport driving_license")
		return nil, err
	}

	stsImagePath, err := savePhoto(req.DriverDocuments.StsPhoto, folderPath)
	if err != nil {
		println("Filed to load passport vehicle_registration")
		return nil, err
	}
	res, err = c.ExecContext(ctx, "INSERT INTO driver_documents(driver_id, passport_number, passport_image, driving_license_number, expiry_date, driving_license_image, sts_photo) VALUES(?, ?, ?, ?, ?, ?, ?)",
		driverId, req.DriverDocuments.PassportNumber, passportImagePath, req.DriverDocuments.DrivingLicenseNumber, parsedExpiryDate,
		drivingLicenseImagePath, stsImagePath)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into DriverDocuments -> "+err.Error())
	}

	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created DriverDocuments -> "+err.Error())
	}
	println("Driver documents" + strconv.FormatInt(id, 10) + "has been added to driver!")

	return &v1.CreateDriverResponse{
		Api:       apiVersion,
		Id:        int32(driverId),
		AuthToken: authToken,
	}, nil
}

func (s *taxiServiceServer) ReadDriver(ctx context.Context, req *v1.ReadDriverRequest) (*v1.ReadDriverResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) UpdateDriver(ctx context.Context, req *v1.UpdateDriverRequest) (*v1.UpdateDriverResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) DeleteDriver(ctx context.Context, req *v1.DeleteDriverRequest) (*v1.DeleteDriverResponse, error) {
	panic("implement me")
}

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
		FirstName    sql.NullString
		Surname      sql.NullString
		PhoneNumber  sql.NullString
		LicensePlate sql.NullString
		Color        sql.NullString
		ModelName    sql.NullString
		BrandName    sql.NullString
		RideStatus   sql.NullInt64
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
		FirstName:    td.FirstName.String,
		Surname:      td.Surname.String,
		PhoneNumber:  td.PhoneNumber.String,
		LicensePlate: td.LicensePlate.String,
		Color:        td.Color.String,
		ModelName:    td.ModelName.String,
		BrandName:    td.BrandName.String,
		RideStatus:   int32(td.RideStatus.Int64),
	}, nil
}

func (s *taxiServiceServer) ReadAllCarBrands(ctx context.Context, req *v1.ReadAllCarBrandsRequest) (*v1.ReadAllCarBrandsResponse, error) {

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT * FROM car_brand")
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Car_brand -> "+err.Error())
	}
	defer rows.Close()

	var brands []*v1.CarBrand

	for rows.Next() {
		td := new(v1.CarBrand)
		if err := rows.Scan(&td.Id, &td.BrandName); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_brand-> "+err.Error())
		}
		brands = append(brands, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_brand-> "+err.Error())
	}

	return &v1.ReadAllCarBrandsResponse{
		Api:      apiVersion,
		CarBrand: brands,
	}, nil

}

func (s *taxiServiceServer) ReadAllCarModels(ctx context.Context, req *v1.ReadAllCarModelsRequest) (*v1.ReadAllCarModelsResponse, error) {

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT * FROM car_model WHERE car_brand_id = ?", req.CarBrandId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Car_model -> "+err.Error())
	}
	defer rows.Close()

	var models []*v1.CarModel

	for rows.Next() {
		td := new(v1.CarModel)
		if err := rows.Scan(&td.Id, &td.ModelName, &td.CarBrandId); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
		}
		models = append(models, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
	}

	return &v1.ReadAllCarModelsResponse{
		Api:       apiVersion,
		CarModels: models,
	}, nil

}

func (s *taxiServiceServer) GetColors(ctx context.Context, req *v1.ReadAllColorsRequest) (*v1.ReadAllColorsResponse, error) {

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT * FROM color")

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from color -> "+err.Error())
	}
	defer rows.Close()

	var colors []*v1.Color

	for rows.Next() {
		td := new(v1.Color)
		if err := rows.Scan(&td.Code, &td.Description); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
		}
		colors = append(colors, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
	}

	return &v1.ReadAllColorsResponse{
		Api:   apiVersion,
		Color: colors,
	}, nil

}

/*func (s *taxiServiceServer) ChangeDriverStatus(ctx context.Context, req *v1.ChangeStatusRequest) (*v1.ChangeStatusResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()


	res, err := c.ExecContext(ctx, "UPDATE driver SET working=1 WHERE id=?",
		req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update Customer-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("Driver with id='%d' is not found",
			req.DriverId))
	}

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}



	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from color -> "+err.Error())
	}
	defer c.Close()

	res, err = c.ExecContext(ctx, "SELECT * FROM shift WHERE shift.driver_id = ?", req.DriverId)
	if err == nil {
		res, err = c.ExecContext(ctx, "INSERT INTO shift(driver_id, shift_end_time) VALUES(?, NOW())", req.DriverId)
		id, err := res.LastInsertId()
	} else {
		res, err = c.ExecContext(ctx, "INSERT INTO shift(driver_id) VALUES(?)", req.DriverId)
		id, err := res.LastInsertId()
	}
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update driver status-> "+err.Error())
	}

	return &v1.ChangeStatusResponse{
		Api:       apiVersion,
		IsChanged: true,
		ShiftId: id,
	}, nil
}
*/

// TODO: add cab to driver

func (s *taxiServiceServer) CreateCab(ctx context.Context, req *v1.CreateCabRequest) (*v1.CreateCabResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// Finding model and color by name
	rows, err := c.QueryContext(ctx, "SELECT car_model.id, color.id FROM car_model, car_brand, color WHERE `model_name`=? AND `brand_name`=? AND `car_brand_id`=car_brand.id AND color.description=?",
		req.CarModelName, req.CarBrandName, req.ColorDescription)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select car_model.id from car_model-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from car_model-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("car_model with name='%s' is not found",
			req.CarModelName))
	}

	var carModelId, colorId int64
	if err := rows.Scan(&carModelId, &colorId); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from car_model or color row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple car_models rows with name='%s'",
			req.CarModelName))
	}

	res, err := c.ExecContext(ctx, "INSERT INTO cab(color_id, license_plate, car_model_id, driver_id) VALUES(?, ?, ?, ?)",
		colorId, req.LicensePlate, carModelId, req.DriverId)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into Customer -> "+err.Error())
	}

	// get ID of creates user
	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created Customer -> "+err.Error())
	}
	fmt.Println("Cab " + fmt.Sprintf("%d", id) + " has been created!")
	return &v1.CreateCabResponse{
		Api:   apiVersion,
		CabId: int32(id),
	}, nil

}

func (s *taxiServiceServer) GetDriversCabs(ctx context.Context, req *v1.GetDriversCabsRequest) (*v1.GetDriversCabsResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, `SELECT cab.id, color.description, cab.license_plate, car_model.model_name, car_brand.brand_name 
											FROM cab, color, car_model, car_brand 
											WHERE driver_id=? AND color_id=color.id AND cab.car_model_id=car_model.id AND car_model.car_brand_id=car_brand.id`)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from color -> "+err.Error())
	}
	defer rows.Close()

	var colors []*v1.Color

	for rows.Next() {
		td := new(v1.Color)
		if err := rows.Scan(&td.Code, &td.Description); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
		}
		colors = append(colors, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
	}

	return &v1.GetDriversCabsResponse{
		Api: apiVersion,
		// TODO this method
	}, nil
}

// Drivers shift starting
func (s *taxiServiceServer) StartShift(ctx context.Context, req *v1.StartShiftRequest) (*v1.StartShiftResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	res, err := c.ExecContext(ctx, "INSERT INTO shift(driver_id) VALUES(?)",
		req.DriverId)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into shift -> "+err.Error())
	}

	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created shift -> "+err.Error())
	}
	fmt.Println("Shift " + fmt.Sprintf("%d", id) + " has been started!")

	// Change driver working status
	res, err = c.ExecContext(ctx, "UPDATE driver SET `working`=1 WHERE `id`=?",
		req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to change driver status -> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 { // if working status is already set
		return &v1.StartShiftResponse{
			Api:       apiVersion,
			IsStarted: true,
		}, nil
	}

	fmt.Println("Driver " + fmt.Sprintf("%d", req.DriverId) + " now is working!")

	return &v1.StartShiftResponse{
		Api:       apiVersion,
		IsStarted: true,
	}, nil
}

// Drivers shift ending
func (s *taxiServiceServer) StopShift(ctx context.Context, req *v1.StopShiftRequest) (*v1.StopShiftResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	res, err := c.ExecContext(ctx, "UPDATE shift SET `shift_end_time`=NOW() WHERE `driver_id`=?",
		req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to change driver status -> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("shift with driver_id='%d' is not found",
			req.DriverId))
	}
	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created shift -> "+err.Error())
	}
	fmt.Println("Shift " + fmt.Sprintf("%d", id) + " has been stopped!")

	// Change driver working status
	res, err = c.ExecContext(ctx, "UPDATE driver SET `working`=0 WHERE `id`=?",
		req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to change driver status -> "+err.Error())
	}

	rows, err = res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("driver with id='%d' is not found",
			req.DriverId))
	}

	fmt.Println("Driver " + fmt.Sprintf("%d", req.DriverId) + " stops working!")

	return &v1.StopShiftResponse{
		Api:       apiVersion,
		IsStopped: true,
	}, nil
}

func (s *taxiServiceServer) CheckAvailableOrders(ctx context.Context, req *v1.CheckAvailableOrdersRequest) (*v1.CheckAvailableOrdersResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	/*var ignoredOrders string
	if req.IgnoredOrder != nil {
		for _, value := range req.IgnoredOrder {
			ignoredOrders += strconv.Itoa(int(value)) + ","
		}
		fmt.Println("SQL:", ignoredOrders)
	}*/
	// TODO check gps of driver in area
	/*
		north: N+0.01,
		south: S-0.01,
		east: E+0.02,
		west: W-0.02
	*/
	// TODO send ignored orders
	var rows *sql.Rows
	rows, err = c.QueryContext(ctx, "SELECT id, GPS_starting_point, entrance, GPS_destination, order_for_another, pending_order, payment_type_id, price, comment FROM cab_ride WHERE shift_id IS NULL")

	/*	if len(ignoredOrders) <= 0{
			rows, err = c.QueryContext(ctx, "SELECT id, GPS_starting_point, entrance, GPS_destination, order_for_another, pending_order, payment_type_id, price, comment FROM cab_ride WHERE shift_id IS NULL AND id NOT IN ("+ignoredOrders[:len(ignoredOrders)-1]+")")
		} else {
			rows, err = c.QueryContext(ctx, "SELECT id, GPS_starting_point, entrance, GPS_destination, order_for_another, pending_order, payment_type_id, price, comment FROM cab_ride WHERE shift_id IS NULL")
		}
	*/
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select car_model.id from car_model-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from car_model-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("There is no available cab rides with this "+
			"ignored values: %v",
			req.IgnoredOrder))
	}

	type CabRidesNull struct {
		ShiftId       sql.NullInt64
		RideStartTime mysql.NullTime
		RideEndTime   mysql.NullTime
		Entrance      sql.NullInt64
		Comment       sql.NullString
		FeedBack      sql.NullString
	}
	var cabRidesNull CabRidesNull

	var td v1.CabRide
	if err := rows.Scan(&td.Id, &td.StartingPoint, &cabRidesNull.Entrance, &td.EndingPoint, &td.OrderForAnother, &td.PendingOrder, &td.PaymentTypeId, &td.Price, &cabRidesNull.Comment); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from car_model or color row-> "+err.Error())
	}
	td.Entrance = int32(cabRidesNull.Entrance.Int64)
	td.Comment = cabRidesNull.Comment.String
	if rows.Next() {
		return &v1.CheckAvailableOrdersResponse{
			Api:     apiVersion,
			CabRide: &td,
		}, nil
	}
	return &v1.CheckAvailableOrdersResponse{
		Api:     apiVersion,
		CabRide: &td,
	}, nil
}

// TODO: test order accepting
func (s *taxiServiceServer) IsAccountActivated(ctx context.Context, req *v1.IsAccountActivatedRequest) (*v1.IsAccountActivatedResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT activated FROM taxi.driver WHERE `phone_number`=?",
		req.DriverLogin)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Customer-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Customer-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("Driver with phone_number='%s' is not found",
			req.DriverLogin))
	}

	// get user data
	var isActivated bool
	if err := rows.Scan(&isActivated); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from Driver row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Driver rows with phone_number='%s'",
			req.DriverLogin))
	}

	return &v1.IsAccountActivatedResponse{
		Api:         apiVersion,
		IsActivated: isActivated,
	}, nil
}

func (s *taxiServiceServer) AcceptOrder(ctx context.Context, req *v1.AcceptOrderRequest) (*v1.AcceptOrderResponse, error) {

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// changing shift id in cab_ride
	res, err := c.ExecContext(ctx, "UPDATE cab_ride, shift SET cab_ride.shift_id=shift.id WHERE cab_ride.id=? AND driver_id=? AND shift_end_time IS NULL", req.CabRideId, req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update cab_ride-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.CabRideId))
	}

	return &v1.AcceptOrderResponse{
		Api:        apiVersion,
		IsAccepted: true,
	}, nil

}

func (s *taxiServiceServer) CancelOrder(ctx context.Context, req *v1.CancelOrderRequest) (*v1.CancelOrderResponse, error) {

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// changing shift id in cab_ride
	res, err := c.ExecContext(ctx, "UPDATE cab_ride, shift SET cab_ride.shift_id=NULL WHERE cab_ride.id=? AND driver_id=? ", req.CabRideId, req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update cab_ride-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.CabRideId))
	}

	return &v1.CancelOrderResponse{
		Api:        apiVersion,
		IsCanceled: true,
	}, nil

}

func (s *taxiServiceServer) StartTrip(ctx context.Context, req *v1.StartTripRequest) (*v1.StartTripResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// changing shift id in cab_ride
	res, err := c.ExecContext(ctx, "UPDATE cab_ride, cab_ride_status SET cab_ride.ride_start_time=CURRENT_TIMESTAMP, ride_status=1 WHERE cab_ride.id=?", req.CabRideId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update cab_ride-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.CabRideId))
	}

	return &v1.StartTripResponse{
		Api:       apiVersion,
		IsStarted: true,
	}, nil

}

func (s *taxiServiceServer) EndTrip(ctx context.Context, req *v1.EndTripRequest) (*v1.EndTripResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// changing shift id in cab_ride
	res, err := c.ExecContext(ctx, "UPDATE cab_ride, cab_ride_status SET cab_ride.ride_end_time=CURRENT_TIMESTAMP, ride_status=2 WHERE cab_ride.id=?", req.CabRideId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update cab_ride-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.CabRideId))
	}

	return &v1.EndTripResponse{
		Api:     apiVersion,
		IsEnded: true,
	}, nil

}

// Dispatcher functions

func (s *taxiServiceServer) CreateDispatcher(ctx context.Context, req *v1.CreateDispatcherRequest) (*v1.CreateDispatcherResponse, error) {

	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	authToken := RandStringBytesMaskImprSrc(32)
	hashedPass := passwordGenerate(req.Dispatcher.Password)
	res, err := c.ExecContext(ctx, "INSERT INTO dispatcher(first_name, last_name, patronymic, phone_number, email, password, authToken) VALUES(?, ?, ?, ?, ?, ?, ?)",
		req.Dispatcher.FirstName, req.Dispatcher.Surname, req.Dispatcher.Partronymic, req.Dispatcher.PhoneNumber,
		req.Dispatcher.Email, hashedPass, authToken)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into Dispatcher -> "+err.Error())
	}

	// get ID of creates user
	id, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created Dispatcher -> "+err.Error())
	}
	fmt.Println("Dispatcher \"" + req.Dispatcher.PhoneNumber + "\" has been created!")
	return &v1.CreateDispatcherResponse{
		Api:       apiVersion,
		Id:        int32(id),
		AuthToken: authToken,
	}, nil

}

func (s *taxiServiceServer) CreateCabRideDispatcher(ctx context.Context, req *v1.CreateCabRideDispatcherRequest) (*v1.CreateCabRideDispatcherResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// Check is user registered in service by phone_number

	rows, err := c.QueryContext(ctx, "SELECT id FROM taxi.customer WHERE `phone_number`=?",
		req.Customer.PhoneNumber)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Customer-> "+err.Error())
	}
	defer rows.Close()

	var customerId int64
	// Create or select customer from DB

	// If user is not registered
	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Customer-> "+err.Error())
		}
		hashedPass := passwordGenerate(RandStringBytesMaskImprSrc(8))
		res, err := c.ExecContext(ctx, "INSERT INTO customer(phone_number, password) VALUES(?, ?)",
			req.Customer.PhoneNumber, hashedPass)
		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to insert into Customer -> "+err.Error())
		}

		customerId, err = res.LastInsertId()
		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve id for created Customer -> "+err.Error())
		}
		fmt.Println("Customer \"" + req.Customer.PhoneNumber + "\" has been created!")

	} else {
		if err = rows.Scan(&customerId); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve field values from Customer row-> "+err.Error())
		}
		if rows.Next() {
			return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Customer rows with phone_number='%s'",
				req.Customer.PhoneNumber))
		}
	}
	res, err := c.ExecContext(ctx, "INSERT INTO cab_ride(customer_id, GPS_starting_point, GPS_destination) VALUES(?,?,?)",
		int32(customerId), req.CabRide.StartingPoint, req.CabRide.EndingPoint)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to insert into cab_ride -> "+err.Error())
	}

	cabRideId, err := res.LastInsertId()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve id for created cab_ride -> "+err.Error())
	}
	fmt.Println("cab_ride " + string(cabRideId) + " has been created!")

	res, err = c.ExecContext(ctx, "INSERT INTO cab_ride_status(cab_ride_id) VALUES(?)", cabRideId)

	if res != nil {
		id, err := res.LastInsertId()
		if err != nil {
			return nil, status.Error(codes.Unknown, "failed to insert into cab_ride_status -> "+err.Error())
		}
		fmt.Println("cab_ride_status " + string(id) + " has been created!")
	}

	return &v1.CreateCabRideDispatcherResponse{
		Api:       apiVersion,
		IsCreated: true,
		CabRideId: int32(cabRideId),
	}, nil
}

// TODO check добавление сведений по заказу
func (s *taxiServiceServer) SetDetailsToOrder(ctx context.Context, req *v1.SetDetailsToOrderRequest) (*v1.SetDetailsToOrderResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	res, err := c.ExecContext(ctx, "UPDATE cab_ride_status SET cab_ride_status.status_details=? WHERE cab_ride_status.cab_ride_id=?", req.Message, req.CabRideId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update cab_ride-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.CabRideId))
	}

	return &v1.SetDetailsToOrderResponse{
		Api:       apiVersion,
		IsUpdated: true,
	}, nil

}

func (s *taxiServiceServer) ReadAllDrivers(ctx context.Context, req *v1.ReadAllDriversRequest) (*v1.ReadAllDriversResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT id, first_name, surname, patronymic, birth_date, phone_number, working, email, activated, create_time FROM driver")

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Car_model -> "+err.Error())
	}
	defer rows.Close()

	var drivers []*v1.Driver
	var birthDate, createTime time.Time
	for rows.Next() {
		td := new(v1.Driver)
		if err := rows.Scan(&td.Id, &td.FirstName, &td.Surname, &td.Partronymic, &birthDate, &td.PhoneNumber,
			&td.Working, &td.Email, &td.Activated, &createTime); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Driver-> "+err.Error())
		}
		td.BirthDate = parseDate(birthDate)
		td.CreateTime = parseDate(createTime)
		drivers = append(drivers, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Driver-> "+err.Error())
	}

	return &v1.ReadAllDriversResponse{
		Api:    apiVersion,
		Driver: drivers,
	}, nil

}

func parseDate(birthDate time.Time) *timestamp.Timestamp {
	parsedBirthDate := &timestamp.Timestamp{
		Seconds: birthDate.Unix(),
		Nanos:   int32(birthDate.Nanosecond()),
	}
	return parsedBirthDate
}

// TODO подтверждение аккаунта таксиста
func (s *taxiServiceServer) VerifyDriversAccount(ctx context.Context, req *v1.VerifyDriversAccountRequest) (*v1.VerifyDriversAccountResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	res, err := c.ExecContext(ctx, "UPDATE driver SET activated=1 WHERE id=?", req.DriverId)

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to update cab_ride-> "+err.Error())
	}

	rows, err := res.RowsAffected()
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve rows affected value-> "+err.Error())
	}

	if rows == 0 {
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with id='%d' is not found",
			req.DriverId))
	}

	return &v1.VerifyDriversAccountResponse{
		Api:        apiVersion,
		IsVerified: true,
	}, nil

}

// TODO получение сведений по заказам отдельного таксиста
// TODO получение сведений по сменам таксиста
// TODO получение сведений о заказах клиента

func (s *taxiServiceServer) ReadAllCabRides(ctx context.Context, req *v1.ReadAllCabRidesRequest) (*v1.ReadAllCabRidesResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	rows, err := c.QueryContext(ctx, "SELECT id, customer_id, shift_id, ride_start_time, ride_end_time, GPS_starting_point, entrance, GPS_destination, canceled, order_for_another, pending_order, payment_type_id, price, comment, feedback FROM cab_ride")

	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from Cab_ride -> "+err.Error())
	}
	defer rows.Close()

	var cabRides []*v1.CabRide
	var rideStartTime time.Time
	var rideEndTime time.Time
	type CabRidesNull struct {
		ShiftId       sql.NullInt64
		RideStartTime mysql.NullTime
		RideEndTime   mysql.NullTime
		Entrance      sql.NullInt64
		Comment       sql.NullString
		FeedBack      sql.NullString
	}
	var cabRidesNull CabRidesNull
	for rows.Next() {
		td := new(v1.CabRide)
		if err := rows.Scan(&td.Id, &td.CustomerId, &cabRidesNull.ShiftId, &cabRidesNull.RideStartTime, &cabRidesNull.RideEndTime, &td.StartingPoint,
			&cabRidesNull.Entrance, &td.EndingPoint, &td.Canceled, &td.OrderForAnother, &td.PendingOrder, &td.PaymentTypeId,
			&td.Price, &cabRidesNull.Comment, &cabRidesNull.FeedBack); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Cab_ride-> "+err.Error())
		}
		td.RideStartTime = parseDate(rideStartTime)
		td.RideEndTime = parseDate(rideEndTime)
		td.ShiftId = int32(cabRidesNull.ShiftId.Int64)
		if cabRidesNull.RideStartTime.Time.Unix() > 1 {
			td.RideStartTime, _ = ptypes.TimestampProto(cabRidesNull.RideStartTime.Time)
		}
		if cabRidesNull.RideEndTime.Time.Unix() > 1 {
			td.RideEndTime, _ = ptypes.TimestampProto(cabRidesNull.RideEndTime.Time)
		}
		td.Entrance = int32(cabRidesNull.Entrance.Int64)
		td.Comment = cabRidesNull.Comment.String
		td.Feedback = cabRidesNull.FeedBack.String
		cabRides = append(cabRides, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Cab_ride-> "+err.Error())
	}

	return &v1.ReadAllCabRidesResponse{
		Api:     apiVersion,
		CabRide: cabRides,
	}, nil

}

func (s *taxiServiceServer) ReadCabRideStatus(ctx context.Context, req *v1.ReadCabRideStatusRequest) (*v1.ReadCabRideStatusResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	rows, err := c.QueryContext(ctx, "SELECT id, cab_ride_id, shift_id, ride_status, status_details FROM taxi.cab_ride_status WHERE `cab_ride_id`=?",
		req.CabRideId)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from cab_ride_status-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from cab_ride_status-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride_status with phone_number='%s' is not found",
			req.CabRideId))
	}

	var td v1.CabRideStatus
	if err := rows.Scan(&td.Id, &td.CabRideId, &td.ShiftId, &td.RideStatus, &td.StatusDetails); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from cab_ride_status row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple cab_ride_status rows with phone_number='%s'",
			req.CabRideId))
	}

	return &v1.ReadCabRideStatusResponse{
		Api:           apiVersion,
		CabRideStatus: &td,
	}, nil

}

func (s *taxiServiceServer) ReadDriverStatistic(ctx context.Context, req *v1.ReadDriverStatisticRequest) (*v1.ReadDriverStatisticResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	rows, err := c.QueryContext(ctx, "SELECT COUNT(*) FROM cab_ride, taxi.shift WHERE `shift_id`=shift.id AND driver_id=?",
		req.DriverId)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from cab_ride-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from cab_ride-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with driver_id='%d' is not found",
			req.DriverId))
	}

	var cabRideCount sql.NullInt64
	if err := rows.Scan(&cabRideCount); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from cab_ride_status row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple cab_ride rows with driver_id='%d'",
			req.DriverId))
	}

	if _, err := cabRideCount.Value(); err != nil {
		return &v1.ReadDriverStatisticResponse{
			Api:           apiVersion,
			EndedCabRides: 0,
		}, nil
	} else {
		return &v1.ReadDriverStatisticResponse{
			Api:           apiVersion,
			EndedCabRides: int32(cabRideCount.Int64),
		}, nil
	}

}

func (s *taxiServiceServer) ReadCustomerStatistic(ctx context.Context, req *v1.ReadCustomerStatisticRequest) (*v1.ReadCustomerStatisticResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}

	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()
	rows, err := c.QueryContext(ctx, "SELECT COUNT(*) FROM cab_ride WHERE `customer_id`=?",
		req.CustomerId)
	if err != nil {
		return nil, status.Error(codes.Unknown, "failed to select from cab_ride-> "+err.Error())
	}
	defer rows.Close()

	if !rows.Next() {
		if err := rows.Err(); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from cab_ride-> "+err.Error())
		}
		return nil, status.Error(codes.NotFound, fmt.Sprintf("cab_ride with customer_id='%d' is not found",
			req.CustomerId))
	}

	var cabRideCount sql.NullInt64
	if err := rows.Scan(&cabRideCount); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from cab_ride_status row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple cab_ride rows with customer_id='%d'",
			req.CustomerId))
	}

	if _, err := cabRideCount.Value(); err != nil {
		return &v1.ReadCustomerStatisticResponse{
			Api:             apiVersion,
			OrderedCabRides: 0,
		}, nil
	} else {
		return &v1.ReadCustomerStatisticResponse{
			Api:             apiVersion,
			OrderedCabRides: int32(cabRideCount.Int64),
		}, nil
	}
}

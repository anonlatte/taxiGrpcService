package v1

import (
	"context"
	"crypto/sha512"
	"database/sql"
	"fmt"
	v12 "golang-service/src/pkg/api/v1"
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
func NewTaxiServiceServer(db *sql.DB) v12.TaxiServiceServer {
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

// TODO: cleanup excess checkApi && checkConnection code
// TODO: cleanup excess tokenCheck code
/*func (s *taxiServiceServer) isTokenValid (ctx context.Context) bool {

}*/

func (s *taxiServiceServer) LoginUser(ctx context.Context, req *v12.LoginRequest) (*v12.LoginResponse, error) {

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

		var td v12.Customer
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
			return &v12.LoginResponse{
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

		var td v12.Driver
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
			return &v12.LoginResponse{
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

		var td v12.Dispatcher
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
			return &v12.LoginResponse{
				Api:       apiVersion,
				AuthToken: authToken,
				UserId:    int32(td.Id),
			}, nil
		} else {
			return nil, status.Error(codes.PermissionDenied, fmt.Sprintf("Wrong password!"))
		}

	}
}

func (s *taxiServiceServer) TokenCheck(ctx context.Context, req *v12.TokenCheckRequest) (*v12.TokenCheckResponse, error) {
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

		var td v12.Customer
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
			return &v12.TokenCheckResponse{
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

		var td v12.Driver
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
			return &v12.TokenCheckResponse{
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

		var td v12.Dispatcher
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
			return &v12.TokenCheckResponse{
				Api:          apiVersion,
				IsValidToken: true,
			}, nil
		} else {
			return nil, status.Error(codes.Unauthenticated, fmt.Sprintf("Wrong token!"))
		}
	}
}

// customer CRUD
func (s *taxiServiceServer) CreateCustomer(ctx context.Context, req *v12.CreateCustomerRequest) (*v12.CreateCustomerResponse, error) {
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
	return &v12.CreateCustomerResponse{
		Api:       apiVersion,
		Id:        int32(id),
		AuthToken: authToken,
	}, nil
}

func (s *taxiServiceServer) ReadCustomer(ctx context.Context, req *v12.ReadCustomerRequest) (*v12.ReadCustomerResponse, error) {
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
	var td v12.Customer
	if err := rows.Scan(&td.Id, &td.Name, &td.PhoneNumber, &td.Email); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from Customer row-> "+err.Error())
	}
	if rows.Next() {
		return nil, status.Error(codes.Unknown, fmt.Sprintf("found multiple Customer rows with phone_number='%s'",
			req.Customer.PhoneNumber))
	}

	return &v12.ReadCustomerResponse{
		Api:      apiVersion,
		Customer: &td,
	}, nil
}

func (s *taxiServiceServer) UpdateCustomer(ctx context.Context, req *v12.UpdateCustomerRequest) (*v12.UpdateCustomerResponse, error) {
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

	return &v12.UpdateCustomerResponse{
		Api:     apiVersion,
		Updated: int32(rows),
	}, nil
}

func (s *taxiServiceServer) DeleteCustomer(ctx context.Context, req *v12.DeleteCustomerRequest) (*v12.DeleteCustomerResponse, error) {
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

	return &v12.DeleteCustomerResponse{
		Api:     apiVersion,
		Deleted: int32(rows),
	}, nil
}

func (s *taxiServiceServer) CreateCabRide(ctx context.Context, req *v12.CreateCabRideRequest) (*v12.CreateCabRideResponse, error) {
	if err := s.checkAPI(req.Api); err != nil {
		return nil, err
	}
	// TODO: Test this func
	c, err := s.connect(ctx)
	if err != nil {
		return nil, err
	}
	defer c.Close()

	// TODO check price set
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

	return &v12.CreateCabRideResponse{
		Api:       apiVersion,
		CabRideId: int32(id),
	}, nil
}

func (s *taxiServiceServer) DeleteCabRide(ctx context.Context, req *v12.DeleteCabRideRequest) (*v12.DeleteCabRideResponse, error) {
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

	var td v12.Customer
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
		return &v12.DeleteCabRideResponse{
			Api:              apiVersion,
			IsSuccessDeleted: true,
		}, nil
	} else {
		return nil, status.Error(codes.Unauthenticated, fmt.Sprintf("Wrong token!"))
	}
}

// TODO: update cab_ride
func (s *taxiServiceServer) UpdateCabRide(ctx context.Context, req *v12.UpdateCabRideRequest) (*v12.UpdateCabRideResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) CreateDriver(ctx context.Context, req *v12.CreateDriverRequest) (*v12.CreateDriverResponse, error) {
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

	return &v12.CreateDriverResponse{
		Api:       apiVersion,
		Id:        int32(driverId),
		AuthToken: authToken,
	}, nil
}

func (s *taxiServiceServer) ReadDriver(ctx context.Context, req *v12.ReadDriverRequest) (*v12.ReadDriverResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) UpdateDriver(ctx context.Context, req *v12.UpdateDriverRequest) (*v12.UpdateDriverResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) DeleteDriver(ctx context.Context, req *v12.DeleteDriverRequest) (*v12.DeleteDriverResponse, error) {
	panic("implement me")
}

func (s *taxiServiceServer) CheckCabRideStatus(ctx context.Context, req *v12.CheckCabRideStatusRequest) (*v12.CheckCabRideStatusResponse, error) {
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
		LicensePlate string
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
	return &v12.CheckCabRideStatusResponse{
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

func savePhoto(byteArray []byte, path string) (string, error) {
	fileName := RandStringBytesMaskImprSrc(32) + ".webp"
	err := ioutil.WriteFile(path+fileName, byteArray, os.ModePerm)
	if err != nil {
		return "", status.Error(codes.InvalidArgument, "Failed to save a photo "+err.Error())
	}
	return fileName, nil
}

func (s *taxiServiceServer) ReadAllCarBrands(ctx context.Context, req *v12.ReadAllCarBrandsRequest) (*v12.ReadAllCarBrandsResponse, error) {

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

	var brands []*v12.CarBrand

	for rows.Next() {
		td := new(v12.CarBrand)
		if err := rows.Scan(&td.Id, &td.BrandName); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_brand-> "+err.Error())
		}
		brands = append(brands, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_brand-> "+err.Error())
	}

	return &v12.ReadAllCarBrandsResponse{
		Api:      apiVersion,
		CarBrand: brands,
	}, nil

}

func (s *taxiServiceServer) ReadAllCarModels(ctx context.Context, req *v12.ReadAllCarModelsRequest) (*v12.ReadAllCarModelsResponse, error) {

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

	var models []*v12.CarModel

	for rows.Next() {
		td := new(v12.CarModel)
		if err := rows.Scan(&td.Id, &td.ModelName, &td.CarBrandId); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
		}
		models = append(models, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
	}

	return &v12.ReadAllCarModelsResponse{
		Api:       apiVersion,
		CarModels: models,
	}, nil

}

func (s *taxiServiceServer) GetColors(ctx context.Context, req *v12.ReadAllColorsRequest) (*v12.ReadAllColorsResponse, error) {

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

	var colors []*v12.Color

	for rows.Next() {
		td := new(v12.Color)
		if err := rows.Scan(&td.Code, &td.Description); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
		}
		colors = append(colors, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
	}

	return &v12.ReadAllColorsResponse{
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

func (s *taxiServiceServer) CreateCab(ctx context.Context, req *v12.CreateCabRequest) (*v12.CreateCabResponse, error) {
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
	return &v12.CreateCabResponse{
		Api:   apiVersion,
		CabId: int32(id),
	}, nil

}

func (s *taxiServiceServer) GetDriversCabs(ctx context.Context, req *v12.GetDriversCabsRequest) (*v12.GetDriversCabsResponse, error) {
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

	var colors []*v12.Color

	for rows.Next() {
		td := new(v12.Color)
		if err := rows.Scan(&td.Code, &td.Description); err != nil {
			return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
		}
		colors = append(colors, td)
	}

	if err := rows.Err(); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve data from Car_model-> "+err.Error())
	}

	return &v12.GetDriversCabsResponse{
		Api: apiVersion,
		// TODO this method
	}, nil
}

// Drivers shift starting
func (s *taxiServiceServer) StartShift(ctx context.Context, req *v12.StartShiftRequest) (*v12.StartShiftResponse, error) {
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
		return &v12.StartShiftResponse{
			Api:       apiVersion,
			IsStarted: true,
		}, nil
	}

	fmt.Println("Driver " + fmt.Sprintf("%d", req.DriverId) + " now is working!")

	return &v12.StartShiftResponse{
		Api:       apiVersion,
		IsStarted: true,
	}, nil
}

// Drivers shift ending
func (s *taxiServiceServer) StopShift(ctx context.Context, req *v12.StopShiftRequest) (*v12.StopShiftResponse, error) {
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

	return &v12.StopShiftResponse{
		Api:       apiVersion,
		IsStopped: true,
	}, nil
}

func (s *taxiServiceServer) CheckAvailableOrders(ctx context.Context, req *v12.CheckAvailableOrdersRequest) (*v12.CheckAvailableOrdersResponse, error) {
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

	var td v12.CabRide
	if err := rows.Scan(&td.Id, &td.StartingPoint, &td.Entrance, &td.EndingPoint, &td.OrderForAnother, &td.PendingOrder, &td.PaymentTypeId, &td.Price, &td.Comment); err != nil {
		return nil, status.Error(codes.Unknown, "failed to retrieve field values from car_model or color row-> "+err.Error())
	}
	if rows.Next() {
		return &v12.CheckAvailableOrdersResponse{
			Api:     apiVersion,
			CabRide: &td,
		}, nil
	}
	return &v12.CheckAvailableOrdersResponse{
		Api:     apiVersion,
		CabRide: &td,
	}, nil
}

// TODO: test order accepting
func (s *taxiServiceServer) AcceptOrder(ctx context.Context, req *v12.AcceptOrderRequest) (*v12.AcceptOrderResponse, error) {

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

	return &v12.AcceptOrderResponse{
		Api:        apiVersion,
		IsAccepted: true,
	}, nil

}

func (s *taxiServiceServer) CancelOrder(ctx context.Context, req *v12.CancelOrderRequest) (*v12.CancelOrderResponse, error) {

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

	return &v12.CancelOrderResponse{
		Api:        apiVersion,
		IsCanceled: true,
	}, nil

}

func (s *taxiServiceServer) StartTrip(ctx context.Context, req *v12.StartTripRequest) (*v12.StartTripResponse, error) {
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

	return &v12.StartTripResponse{
		Api:       apiVersion,
		IsStarted: true,
	}, nil

}

func (s *taxiServiceServer) EndTrip(ctx context.Context, req *v12.EndTripRequest) (*v12.EndTripResponse, error) {
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

	return &v12.EndTripResponse{
		Api:     apiVersion,
		IsEnded: true,
	}, nil

}

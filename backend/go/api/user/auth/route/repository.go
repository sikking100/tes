package route

import (
	"context"

	"github.com/grocee-project/dairyfood/backend/go/api/user/auth/entity"
)

type repository interface {
	Login(ctx context.Context, data entity.Login) (string, error)
	Verify(ctx context.Context, data entity.Verify) (string, error)
}

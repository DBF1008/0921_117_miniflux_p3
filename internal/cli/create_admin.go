// SPDX-FileCopyrightText: Copyright The Miniflux Authors. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

package cli // import "miniflux.app/v2/internal/cli"

import (
	"context"
	"log/slog"

	"miniflux.app/v2/internal/config"
	"miniflux.app/v2/internal/model"
	"miniflux.app/v2/internal/storage"
	"miniflux.app/v2/internal/validator"
)

func createAdminUserFromEnvironmentVariables(ctx context.Context, store *storage.Storage) {
	createAdminUser(ctx, store, config.Opts.AdminUsername(), config.Opts.AdminPassword())
}

func createAdminUserFromInteractiveTerminal(ctx context.Context, store *storage.Storage) {
	username, password := askCredentials()
	createAdminUser(ctx, store, username, password)
}

func createAdminUser(ctx context.Context, store *storage.Storage, username, password string) {
	userCreationRequest := &model.UserCreationRequest{
		Username: username,
		Password: password,
		IsAdmin:  true,
	}

	if store.UserExists(ctx, userCreationRequest.Username) {
		slog.Info("Skipping admin user creation because it already exists",
			slog.String("username", userCreationRequest.Username),
		)
		return
	}

	if validationErr := validator.ValidateUserCreationWithPassword(ctx, store, userCreationRequest); validationErr != nil {
		printErrorAndExit(validationErr.Error())
	}

	if user, err := store.CreateUser(ctx, userCreationRequest); err != nil {
		printErrorAndExit(err)
	} else {
		slog.Info("Created new admin user",
			slog.String("username", user.Username),
			slog.Int64("user_id", user.ID),
		)
	}
}

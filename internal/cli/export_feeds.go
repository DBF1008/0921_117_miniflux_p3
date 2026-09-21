// SPDX-FileCopyrightText: Copyright The Miniflux Authors. All rights reserved.
// SPDX-License-Identifier: Apache-2.0

package cli // import "miniflux.app/v2/internal/cli"

import (
	"context"
	"fmt"

	"miniflux.app/v2/internal/reader/opml"
	"miniflux.app/v2/internal/storage"
)

func exportUserFeeds(ctx context.Context, store *storage.Storage, username string) {
	user, err := store.UserByUsername(ctx, username)
	if err != nil {
		printErrorAndExit(fmt.Errorf("unable to find user: %w", err))
	}

	if user == nil {
		printErrorAndExit(fmt.Errorf("user %q not found", username))
	}

	opmlHandler := opml.NewHandler(store)
	opmlExport, err := opmlHandler.Export(ctx, user.ID)
	if err != nil {
		printErrorAndExit(fmt.Errorf("unable to export feeds: %w", err))
	}

	fmt.Println(opmlExport)
}

#!/bin/sh
SUBID="yourSubscriptionID"
# Create Azure AD service principal in subscription $SUBID
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBID"
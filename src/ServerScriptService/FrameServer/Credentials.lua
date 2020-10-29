local realmUrl = "https://webhooks.mongodb-realm.com/api/client/v2.0/app/cloudentertainment-byxjq/service/"

return {

    sentryToken = "https://22d4726dd7e748e7854fd0bc7ae42491:4e9ee3fee5264de5a4321c64e7e2cb33@o396313.ingest.sentry.io/5249476",
    syncLiveOps = realmUrl .. "HTTP/incoming_webhook/sync-live-ops",
    database = {
        marketplace = {
            getUserPurchases = realmUrl .. "Marketplace/incoming_webhook/get-user-purchases",
            saveUserPurchase = realmUrl .. "Marketplace/incoming_webhook/save-user-purchase"
        }
    }
}
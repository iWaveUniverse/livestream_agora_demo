const admin = require("firebase-admin")
const serviceAccount = require("./agoralive-banga-firebase-adminsdk-8kd4v-18ce1a7f5c.json")
const adminInitApp = () => {
  let defaultApp
  if (!admin.apps.length) {
    defaultApp = admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    })
  } else {
    defaultApp = admin.app()
  }
  return defaultApp
}
module.exports = {
  adminInitApp,
}
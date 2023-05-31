const functions = require('firebase-functions')
const admin = require('firebase-admin')
const {
  RtcTokenBuilder,
  RtcRole,
  RtmTokenBuilder,
} = require('agora-access-token')
const { adminInitApp } = require('./adminInitApp')
const defaultApp = adminInitApp()
const db = admin.firestore()
const createCallsWithTokens = functions.https.onCall(async (data,
  context) => {
  try {
    const appId = "c3af12ef08924782acb30d8cc2123cea"
    const appertificate = "9edffba2c0f34582b92f0fbe2f8acbc4"
    const role = RtcRole.PUBLISHER
    const expirationTimeInSeconds = 60*60*24
    const currentTimestamp = Math.floor(Date.now() / 1000)
    const privilegeExpired = currentTimestamp +
      expirationTimeInSeconds
    const uid = 0
    const channelId = Math.floor(Math.random() * 100).toString()
    const token = RtcTokenBuilder.buildTokenWithUid(
      appId,
      appertificate,
      channelId,
      uid,
      role,
      privilegeExpired
    )
    return {
      data: {
        token: token,
        appId: appId,
        channelId: channelId,
      },
    }
  } catch (error) { }
})

module.exports = {
  createCallsWithTokens,
}
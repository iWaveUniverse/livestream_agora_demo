const functions = require("firebase-functions")
const { createCallsWithTokens } = require('./createCallsWithToken')
const { adminInitApp } = require('./adminInitApp')

adminInitApp()

module.exports = {
  createCallsWithTokens,
}
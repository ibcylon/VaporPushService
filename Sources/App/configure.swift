import Vapor
import APNS
import VaporAPNS
import APNSCore

// configures your application
public func configure(_ app: Application) async throws {
  // uncomment to serve files from /Public folder
  // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
  try configureAPNS(app)
  // register routes
  try routes(app)
}
fileprivate enum EnvironmentKey: String {
  case keyID = "KEY_ID"
  case teamID = "TEAM_ID"
  case apnsKey = "PRIVATE_KEY"
}

private func configureAPNS(_ app: Application) throws {
  guard
  let keyID = Environment.get(EnvironmentKey.keyID.rawValue),
  let teamID = Environment.get(EnvironmentKey.teamID.rawValue),
  let privateKey = Environment.get(EnvironmentKey.apnsKey.rawValue) 
  else {
    throw Abort(.internalServerError, reason: "Missing APNS credentials")
  }
  
  let apnsConfig = APNSClientConfiguration(
    authenticationMethod: .jwt(
      privateKey: try P256.Signing.PrivateKey.loadFrom(string: privateKey),
      keyIdentifier: keyID,
      teamIdentifier: teamID
    ),
    environment: .sandbox)
  
  app.apns.containers.use(
    apnsConfig,
    eventLoopGroupProvider: .shared(app.eventLoopGroup),
    responseDecoder: JSONDecoder(),
    requestEncoder: JSONEncoder(),
    as: .default)
}

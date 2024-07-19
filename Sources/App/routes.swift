import Vapor
import VaporAPNS
import APNSCore

func routes(_ app: Application) throws {
  app.get { req async throws -> HTTPStatus in
    do {
      try await req.apns.client.sendAlertNotification(
        makeAlert(Payload(acme1: "HI", acme2: 2)),
        deviceToken: "b5f87db265cf02ccb2cd7c8efe21ea410516f815d44b8448695fb4261ef3e686"
      )
    }catch {
      print(error.localizedDescription)
      return .ok
    }
    return .ok
  }
  
  app.get("hello") { req async -> String in
    "Hello, world!"
  }
  
  app.get("test-push") { req async throws -> HTTPStatus in
    try await req.apns.client.sendAlertNotification(
      makeAlert(Payload(acme1: "HI", acme2: 2)),
      deviceToken: "b5f87db265cf02ccb2cd7c8efe21ea410516f815d44b8448695fb4261ef3e686"
    )
    return .ok
  }
}

func makeAlert<Payload: Encodable & Sendable>(_ payload: Payload) -> APNSAlertNotification<Payload> {
  return APNSAlertNotification(
    alert: .init(
      title: .raw("Hey"),
      subtitle: .raw("This is a test from vapor/apns")
    ),
    expiration: .immediately,
    priority: .immediately,
    topic: "com.tht.falling.chat.FallingChat",
    payload: payload
  )
}

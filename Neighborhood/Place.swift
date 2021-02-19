import UIKit

public struct Place: Codable, Equatable {
  public var id: String

  public var name: String

  public var address: String

  public var stars: Int

  public var reviews: Int

  public var price: String

  public var description: String

  public var imageURL: URL?
}

private struct PlaceResult: Codable {
  var places: [Place]
}

private struct ImageResult: Codable {
  var image: URL

  enum CodingKeys: String, CodingKey {
    case image = "img"
  }
}

public class PlaceFetcher {
  /// Fetches the list of places.
  ///
  /// - Parameters:
  ///   - queue:    The `DispatchQueue` on which the `callback` is called. Default is
  ///               `DispatchQueue.main`.
  ///   - callback: The callback that will be invoked with the list of places or an empty Array in
  ///               case of an error.
  static func loadPlaces(queue: DispatchQueue = .main, callback: @escaping ([Place]) -> Void) {
    let url = URL(string: "https://byteboard.dev/api/data/places")!

    let task = URLSession.shared.dataTask(with: url) { data, response, err in
      let result: [Place]

      if let data = data, err == nil {
        let decoder = JSONDecoder()

        result = (try? decoder.decode(PlaceResult.self, from: data).places) ?? []
      } else {
        result = []
      }

      queue.async {
        callback(result)
      }
    }

    task.resume()
  }

  /// Fetches the image URL for a `Place` with a given ID.
  ///
  /// - Parameters:
  ///   - placeID:  The ID of the place for which to fetch the image URL.
  ///   - queue:    The `DispatchQueue` on which the `callback` is called. Default is
  ///               `DispatchQueue.main`.
  ///   - callback: The callback that will be invoked with the resulting image URL or `nil` in case
  ///               of an error.
  static func loadImageURL(forPlaceID placeID: String, queue: DispatchQueue = .main, callback: @escaping (URL?) -> Void) {
    let url = URL(string: "https://byteboard.dev/api/data/img")!.appendingPathComponent(placeID)

    let task = URLSession.shared.dataTask(with: url) { data, response, err in
      let result: URL?

      if let data = data, err == nil {
        let decoder = JSONDecoder()

        result = try? decoder.decode(ImageResult.self, from: data).image
      } else {
        result = nil
      }

      queue.async {
        callback(result)
      }
    }

    task.resume()
  }
}

extension PlaceFetcher {
  /// Fetches a list of `Place`s with their `imageURL` property set.
  ///
  /// - Parameters:
  ///   - queue:    The `DispatchQueue` on which the `callback` is called. Default is
  ///               `DispatchQueue.main`.
  ///   - callback: The callback that will be invoked with the list of places or an empty Array in
  ///               case of an error.
  static func loadPlacesWithImages(queue: DispatchQueue = .main, callback: @escaping ([Place]) -> Void) {
    let group = DispatchGroup()
    var updatePlaces: [Place] = []
    PlaceFetcher.loadPlaces(queue: queue) { places in
      places.forEach { place in
        group.enter()
        PlaceFetcher.loadImageURL(forPlaceID: place.id, queue: queue) { url in
          var newPlace = place
          newPlace.imageURL = url
          updatePlaces.append(newPlace)
          group.leave()
        }
      }

      group.notify(queue: .main) {
          callback(updatePlaces)
      }
    }
  }
}

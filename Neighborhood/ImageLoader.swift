import UIKit

public class ImageLoader {
  /// Fetches an image from a given URL.
  ///
  /// - Parameters:
  ///   - url:      The URL of the image to fetch.
  ///   - queue:    The `DispatchQueue` on which the `callback` is called. Default is
  ///               `DispatchQueue.main`.
  ///   - callback: The callback that will be invoked with the resulting image or `nil` in case of
  ///               an error.
  ///
  /// - Returns: An already started `URLSessionTask` that can be used to cancel the operation
  ///            mid-flight.
  @discardableResult
  static func loadImage(forURL url: URL, queue: DispatchQueue = .main, callback: @escaping (UIImage?) -> Void) -> URLSessionTask {
    let task = URLSession.shared.dataTask(with: url) { data, response, err in
      let result: UIImage?

      if let data = data, err == nil {
        result = UIImage(data: data)
      } else {
        result = nil
      }

      queue.async {
        callback(result)
      }
    }

    task.resume()

    return task
  }
}

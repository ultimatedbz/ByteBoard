import UIKit

private let kImageHeight: CGFloat = 300
private let kPadding: CGFloat = 20

/// A view controller that displays information for a given `Place`.
public class PlaceViewController: UIViewController {
  public let place: Place

  private let imageView = UIImageView()
  private let detailStackView = UIStackView()
  private let nameLabel = UILabel()
  private let addressLabel = UILabel()
  private let starsView = StarsView()
  private let reviewsLabel = UILabel()
  private let priceLabel = UILabel()
  private let descriptionLabel = UILabel()

  /// Used to keep track of the current image fetching task.
  ///
  /// Changing this value will automatically cancel the currently running task, if it exists.
  var imageFetchingTask: URLSessionTask? {
    didSet {
      guard imageFetchingTask != oldValue else { return }

      oldValue?.cancel()
    }
  }

  public init(place: Place) {
    self.place = place

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    self.updateWithPlace(self.place)
  }

  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.setupView()
  }

  private func setupView() {
    self.view.addSubview(imageView)
    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor).activate()
    self.imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
    self.imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()
    self.imageView.heightAnchor.constraint(equalToConstant: kImageHeight).activate()

    self.detailStackView.axis = .vertical
    self.detailStackView.spacing = 5
    self.view.addSubview(self.detailStackView)
    self.detailStackView.translatesAutoresizingMaskIntoConstraints = false
    self.detailStackView.topAnchor.constraint(equalTo: self.imageView.bottomAnchor,
                                              constant: kPadding).activate()
    self.detailStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).activate()
    self.detailStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).activate()

    self.detailStackView.addArrangedSubview(self.nameLabel)
    self.detailStackView.addArrangedSubview(self.addressLabel)

    let metaStackView = UIStackView()
    metaStackView.addArrangedSubview(self.starsView)
    metaStackView.addArrangedSubview(self.reviewsLabel)
    metaStackView.addArrangedSubview(self.priceLabel)

    self.detailStackView.addArrangedSubview(metaStackView)

    self.detailStackView.addArrangedSubview(self.descriptionLabel)
    self.descriptionLabel.lineBreakMode = .byWordWrapping
    self.descriptionLabel.numberOfLines = 0
  }

  /// Updates the receiver with the data of a given place.
  private func updateWithPlace(_ place: Place) {
    self.nameLabel.text = place.name
    self.addressLabel.text = place.address
    self.starsView.rating = place.stars
    self.reviewsLabel.text = "(\(place.reviews))"
    self.priceLabel.text = place.price
    self.descriptionLabel.text = place.description

    guard let url = place.imageURL else { return }

    imageFetchingTask = ImageLoader.loadImage(forURL: url) { [weak self] image in
      self?.imageView.image = image
    }
  }
}
